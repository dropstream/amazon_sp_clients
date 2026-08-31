require 'spec_helper'

# Characterization specs: pin current behavior of the module-level
# helpers in lib/amazon_sp_clients.rb before the modernization refactor.
RSpec.describe AmazonSpClients do
  let(:token_url) { 'https://api.amazon.com/auth/o2/token' }
  let(:access_token) { 'Atza|IQEBLjAsAhRmHjNgHpi0U-Dme37rR6CuUpSREXAMPLE' }

  before do
    AmazonSpClients.configure do |c|
      c.client_id = 'CLIENT_ID'
      c.client_secret = 'CLIENT_SECRET'
      # Skips the eager STS AssumeRole request in Session#initialize.
      c.credentials_provider = Aws::Credentials.new('key', 'secret')
      c.logger = Logger.new(File::NULL)
    end
  end

  # The default configuration is thread-local global state.
  after { Thread.current[:amazon_sp_configuration] = nil }

  describe '.configure' do
    it 'returns the default configuration' do
      expect(AmazonSpClients.configure).to be(AmazonSpClients::Configuration.default)
    end

    it 'returns the same object each call' do
      expect(AmazonSpClients.configure).to be(AmazonSpClients.configure)
    end

    it 'yields the default configuration to the block' do
      yielded = nil
      AmazonSpClients.configure { |c| yielded = c }

      expect(yielded).to be(AmazonSpClients::Configuration.default)
    end
  end

  describe '.new_session' do
    it 'exchanges the refresh token and returns a session' do
      stub_request(:post, token_url)
        .with(
          body: {
            'grant_type' => 'refresh_token',
            'refresh_token' => 'REFRESH_TOKEN',
            'client_id' => 'CLIENT_ID',
            'client_secret' => 'CLIENT_SECRET'
          }
        )
        .to_return(status: 200, body: fixture('token_success.json'))

      session = AmazonSpClients.new_session('REFRESH_TOKEN')

      expect(session).to be_a(AmazonSpClients::Session)
      expect(session.access_token).to eq(access_token)
    end
  end

  describe '.new_migration_session' do
    it 'makes a grantless exchange with the migration scope' do
      token_stub =
        stub_request(:post, token_url)
        .with(
          body: {
            'grant_type' => 'client_credentials',
            'scope' => 'sellingpartnerapi::migration',
            'client_id' => 'CLIENT_ID',
            'client_secret' => 'CLIENT_SECRET'
          }
        )
        .to_return(status: 200, body: fixture('token_success.json'))

      session = AmazonSpClients.new_migration_session

      expect(token_stub).to have_been_requested
      expect(session).to be_a(AmazonSpClients::Session)
      expect(session.access_token).to eq(access_token)
    end
  end

  describe '.new_callback_session' do
    it 'returns a session that takes its token from the callback' do
      session = AmazonSpClients.new_callback_session { 'CALLBACK_TOKEN' }

      expect(session).to be_a(AmazonSpClients::Session)
      # The callback is not called at creation, only on refresh.
      expect(session.access_token).to be_nil

      session.refresh

      expect(session.access_token).to eq('CALLBACK_TOKEN')
    end
  end

  describe '.upload_feed_data' do
    it 'puts the payload to the document url and returns the response' do
      feed_doc = { url: 'https://example.com/upload' }
      payload = '<root><item>test</item></root>'

      stub_request(:put, feed_doc[:url]).to_return(status: 200, body: '')

      response =
        AmazonSpClients.upload_feed_data(feed_doc, 'application/xml', payload)

      expect(WebMock).to have_requested(:put, feed_doc[:url])
        .with(body: payload, headers: { 'Content-Type' => 'application/xml' })
      expect(response).to be_a(Faraday::Response)
      expect(response.status).to eq(200)
    end
  end

  describe '.download_feed_report' do
    it 'downloads and parses a plain json report' do
      report = { feedDocumentId: 'doc1', url: 'https://example.com/report' }

      stub_request(:get, report[:url]).to_return(
        status: 200,
        body: '{"header":{"status":"DONE"}}',
        headers: { 'Content-Type' => 'application/json' }
      )

      result = AmazonSpClients.download_feed_report(report)

      expect(result).to eq('header' => { 'status' => 'DONE' })
    end
  end

  describe '.download_report_document' do
    let(:doc_url) { 'https://example.com/document' }

    it 'gets the document url and returns the raw body' do
      stub_request(:get, doc_url)
        .to_return(status: 200, body: "sku\tqty\nA1\t2\n")

      body = AmazonSpClients.download_report_document(url: doc_url)

      expect(body).to eq("sku\tqty\nA1\t2\n")
      expect(WebMock).to have_requested(:get, doc_url)
    end

    it 'raises not found error on 404' do
      stub_request(:get, doc_url).to_return(status: 404, body: 'gone')

      expect { AmazonSpClients.download_report_document(url: doc_url) }
        .to raise_error(
          Faraday::ResourceNotFound,
          'the server responded with status 404'
        )
    end

    it 'raises server error on 500' do
      stub_request(:get, doc_url).to_return(status: 500, body: 'boom')

      expect { AmazonSpClients.download_report_document(url: doc_url) }
        .to raise_error(
          Faraday::ServerError,
          'the server responded with status 500'
        )
    end
  end
end
