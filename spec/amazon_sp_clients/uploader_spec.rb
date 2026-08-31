require 'spec_helper'
require 'amazon_sp_clients/uploader'

RSpec.describe AmazonSpClients::Uploader do
  let(:logger) { instance_double(Logger, info: nil) }

  before do
    allow(AmazonSpClients).to receive_message_chain(:configure, :logger).and_return(logger)
  end

  describe '#upload' do
    let(:feed_doc) { { url: 'https://example.com/upload' } }
    let(:doc_content_type) { 'application/xml' }
    let(:payload) { '<root><item>test</item></root>' }
    let(:uploader) { described_class.new }

    it 'uploads the payload to the specified URL with the correct content type' do
      stub_request(:put, feed_doc[:url])
        .with(
          body: payload,
          headers: { 'Content-Type' => doc_content_type }
        )
        .to_return(status: 200, body: '', headers: {})

      uploader.upload(feed_doc, doc_content_type, payload)
      expect(WebMock).to have_requested(:put, feed_doc[:url])
        .with(body: payload, headers: { 'Content-Type' => doc_content_type })
    end
  end
end

RSpec.describe AmazonSpClients::Downloader do
  let(:logger) { instance_double(Logger, info: nil) }

  before do
    allow(AmazonSpClients).to receive_message_chain(:configure, :logger).and_return(logger)
  end

  describe '#download' do
    let(:feed_url) { 'https://example.com/download' }

    context 'with gzipped JSON content' do
      let(:json_content) { '{"result":"success"}' }
      let(:gzipped_content) { Zlib.gzip(json_content) }
      let(:feed_processing_report) do
        {
          feedDocumentId: 'doc123',
          url: feed_url,
          compressionAlgorithm: 'GZIP'
        }
      end
      let(:downloader) { described_class.new(feed_processing_report) }

      it 'downloads and decompresses the JSON content' do
        stub_request(:get, feed_url)
          .to_return(status: 200, body: gzipped_content, headers: { 'Content-Type' => 'application/json' })

        result = downloader.download
        expect(result).to eq({ 'result' => 'success' })
      end
    end

    context 'with gzipped XML content' do
      let(:xml_content) { '<root><result>success</result></root>' }
      let(:gzipped_content) { Zlib.gzip(xml_content) }
      let(:feed_processing_report) do
        {
          feedDocumentId: 'doc456',
          url: feed_url,
          compressionAlgorithm: 'GZIP'
        }
      end
      let(:downloader) { described_class.new(feed_processing_report) }

      it 'downloads and decompresses the XML content' do
        stub_request(:get, feed_url)
          .to_return(status: 200, body: gzipped_content, headers: { 'Content-Type' => 'application/xml' })

        result = downloader.download
        expect(result).to have_key('root')
        expect(result['root']['result']).to eq('success')
      end
    end

    context 'with uncompressed JSON content' do
      let(:json_content) { '{"result":"success"}' }
      let(:feed_processing_report) do
        {
          feedDocumentId: 'doc789',
          url: feed_url
        }
      end
      let(:downloader) { described_class.new(feed_processing_report) }

      it 'downloads and processes the uncompressed JSON content' do
        stub_request(:get, feed_url)
          .to_return(status: 200, body: json_content, headers: { 'Content-Type' => 'application/json' })

        result = downloader.download
        expect(result).to eq({ 'result' => 'success' })
      end
    end

    context 'with uncompressed XML content' do
      let(:xml_content) { '<root><result>success</result></root>' }
      let(:feed_processing_report) do
        {
          feedDocumentId: 'doc101',
          url: feed_url
        }
      end
      let(:downloader) { described_class.new(feed_processing_report) }

      it 'downloads and processes the uncompressed XML content' do
        stub_request(:get, feed_url)
          .to_return(status: 200, body: xml_content, headers: { 'Content-Type' => 'application/xml' })

        result = downloader.download
        expect(result).to have_key('root')
        expect(result['root']['result']).to eq('success')
      end
    end
  end
end
