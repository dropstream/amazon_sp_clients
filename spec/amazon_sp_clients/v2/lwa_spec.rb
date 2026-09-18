require 'spec_helper'
require 'amazon_sp_clients/v2'

RSpec.describe AmazonSpClients::V2::LWA do
  v2 = AmazonSpClients::V2

  let(:token_url) { 'https://api.amazon.com/auth/o2/token' }
  let(:now) { Time.utc(2026, 9, 3, 12, 0, 0) }
  let(:config) do
    v2::Config.new(client_id: 'CLIENT_ID', client_secret: 'CLIENT_SECRET',
                   timeout: 7, open_timeout: 3)
  end
  let(:lwa) { described_class.new(config) }

  before { Timecop.freeze(now) }

  it 'needs the app credentials' do
    expect { described_class.new(v2::Config.new) }
      .to raise_error(ArgumentError, /client_id and client_secret/)
  end

  describe '#exchange' do
    it 'posts the refresh token grant as a form' do
      stub =
        stub_request(:post, token_url)
        .with(
          body: {
            'grant_type' => 'refresh_token',
            'client_id' => 'CLIENT_ID',
            'client_secret' => 'CLIENT_SECRET',
            'refresh_token' => 'REFRESH_TOKEN'
          },
          headers: {
            'Content-Type' => 'application/x-www-form-urlencoded',
            'User-Agent' => config.user_agent
          }
        )
        .to_return(status: 200, body: fixture('token_success.json'))

      lwa.exchange(refresh_token: 'REFRESH_TOKEN')

      expect(stub).to have_been_requested
    end

    it 'returns a frozen Token with the response fields and an absolute expiry' do
      stub_request(:post, token_url).to_return(status: 200, body: fixture('token_success.json'))

      token = lwa.exchange(refresh_token: 'REFRESH_TOKEN')

      expect(token).to be_a(v2::Token).and be_frozen
      expect(token.access_token).to eq('Atza|IQEBLjAsAhRmHjNgHpi0U-Dme37rR6CuUpSREXAMPLE')
      expect(token.token_type).to eq('bearer')
      expect(token.expires_in).to eq(3600)
      expect(token.expires_at).to eq(now + 3600)
      expect(token.refresh_token).to eq('Atzr|IQEBLzAtAhRPpMJxdwVz2Nn6f2y-tpJX2DeXEXAMPLE')
    end

    it 'raises the typed auth error with the request body filtered' do
      stub_request(:post, token_url).to_return(status: 400, body: fixture('token_error.json'))

      expect { lwa.exchange(refresh_token: 'REFRESH_TOKEN') }
        .to raise_error(v2::InvalidClientError) do |err|
          expect(err.code).to eq('invalid_client')
          expect(err.request[:body]).to eq('[FILTERED]')
        end
    end

    it 'raises ParseError with a redacted request on a 2xx body that is not JSON' do
      stub_request(:post, token_url).to_return(status: 200, body: '<html>')

      expect { lwa.exchange(refresh_token: 'REFRESH_TOKEN') }
        .to raise_error(v2::ParseError) do |err|
          expect(err.status).to eq(200)
          expect(err.request[:path]).to eq('/auth/o2/token')
          expect(err.request[:body]).to eq('[FILTERED]')
        end
    end

    it 'raises ParseError on a 2xx body without an access token' do
      stub_request(:post, token_url).to_return(status: 200, body: '{"token_type":"bearer"}')

      expect { lwa.exchange(refresh_token: 'REFRESH_TOKEN') }
        .to raise_error(v2::ParseError, /access_token/)
    end

    it 'wraps a timeout as TimeoutError' do
      stub_request(:post, token_url).to_timeout

      expect { lwa.exchange(refresh_token: 'REFRESH_TOKEN') }
        .to raise_error(v2::TimeoutError) do |err|
          expect(err.request[:path]).to eq('/auth/o2/token')
        end
    end

    it 'wraps a refused connection as ConnectionError' do
      stub_request(:post, token_url).to_raise(Errno::ECONNREFUSED)

      expect { lwa.exchange(refresh_token: 'REFRESH_TOKEN') }.to raise_error(v2::ConnectionError)
    end
  end

  it 'applies the config timeouts to its connection' do
    conn = lwa.instance_variable_get(:@conn)

    expect(conn.options.timeout).to eq(7)
    expect(conn.options.open_timeout).to eq(3)
  end
end
