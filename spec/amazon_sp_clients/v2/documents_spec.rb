require 'spec_helper'
require 'amazon_sp_clients/v2'
require 'socket'
require 'zlib'

RSpec.describe AmazonSpClients::V2::Documents do
  v2 = AmazonSpClients::V2

  let(:config) { v2::Config.new(timeout: 5, open_timeout: 2) }
  let(:documents) { described_class.new(config) }
  let(:url) { 'https://tortuga-prod-na.s3.amazonaws.com/doc?X-Amz-Signature=SECRET' }
  let(:document) { { url: url, feedDocumentId: 'amzn1.tortuga.3.x' } }

  describe '#upload' do
    it 'PUTs the body to the presigned url with the content type' do
      stub = stub_request(:put, url)
             .with(body: '<xml/>', headers: { 'Content-Type' => 'text/xml; charset=UTF-8' })
             .to_return(status: 200, body: '')

      expect(documents.upload(document, 'text/xml; charset=UTF-8', '<xml/>')).to be_nil
      expect(stub).to have_been_requested
    end

    it 'raises DocumentError with the credential stripped from the url' do
      stub_request(:put, url).to_return(status: [403, 'Forbidden'], body: '<Error/>')

      expect { documents.upload(document, 'text/xml', '<xml/>') }
        .to raise_error(v2::DocumentError, '403 Forbidden') do |err|
          expect(err.request[:url]).not_to include('SECRET')
        end
    end
  end

  describe '#download_feed_result' do
    it 'parses a JSON document into a string-keyed Hash' do
      stub_request(:get, url).to_return(
        status: 200, body: '{"header":{"sellerId":"A1"},"issues":[]}',
        headers: { 'Content-Type' => 'application/json' }
      )

      expect(documents.download_feed_result(document))
        .to eq('header' => { 'sellerId' => 'A1' }, 'issues' => [])
    end

    it 'parses an XML document' do
      xml = '<AmazonEnvelope><Message><ProcessingReport/></Message></AmazonEnvelope>'
      stub_request(:get, url).to_return(status: 200, body: xml,
                                        headers: { 'Content-Type' => 'text/xml' })

      result = documents.download_feed_result(document)

      expect(result.dig('AmazonEnvelope', 'Message')).to have_key('ProcessingReport')
    end

    it 'raises DocumentError on a body that does not parse' do
      stub_request(:get, url).to_return(status: 200, body: 'not json',
                                        headers: { 'Content-Type' => 'application/json' })

      expect { documents.download_feed_result(document) }
        .to raise_error(v2::DocumentError, /parse/) { |err| expect(err.cause).to be_a(JSON::ParserError) }
    end

    it 'raises DocumentError on XML that does not parse' do
      stub_request(:get, url).to_return(status: 200, body: '<a><b></a>',
                                        headers: { 'Content-Type' => 'text/xml' })

      expect { documents.download_feed_result(document) }.to raise_error(v2::DocumentError)
    end

    it 'inflates a gzipped document first' do
      stub_request(:get, url).to_return(status: 200, body: Zlib.gzip('{"ok":true}'),
                                        headers: { 'Content-Type' => 'application/json' })

      result = documents.download_feed_result(document.merge(compressionAlgorithm: 'GZIP'))

      expect(result).to eq('ok' => true)
    end
  end

  describe '#download_report_document' do
    it 'returns an uncompressed body as delivered' do
      stub_request(:get, url).to_return(status: 200, body: "sku\tqty\nA\t1\n")

      expect(documents.download_report_document(document)).to eq("sku\tqty\nA\t1\n")
    end

    it 'inflates a gzipped body and tags it UTF-8' do
      stub_request(:get, url).to_return(status: 200, body: Zlib.gzip("sku\nCAFÉ-1\n"))

      result = documents.download_report_document(document.merge(compressionAlgorithm: 'GZIP'))

      expect(result).to eq("sku\nCAFÉ-1\n")
      expect(result.encoding).to eq(Encoding::UTF_8)
      expect(result).to be_valid_encoding
    end

    it 'raises DocumentError when a document marked GZIP is not gzipped' do
      stub_request(:get, url).to_return(status: 200, body: 'plain text')

      expect { documents.download_report_document(document.merge(compressionAlgorithm: 'GZIP')) }
        .to raise_error(v2::DocumentError, /inflate/) { |err| expect(err.cause).to be_a(Zlib::Error) }
    end

    it 'raises DocumentError on a failed download' do
      stub_request(:get, url).to_return(status: 404, body: '')

      expect { documents.download_report_document(document) }.to raise_error(v2::DocumentError)
    end

    it 'wraps a timeout as TimeoutError' do
      stub_request(:get, url).to_timeout

      expect { documents.download_report_document(document) }.to raise_error(v2::TimeoutError)
    end
  end

  # WebMock hides how the adapter puts bytes on the wire, so these talk
  # to a real local socket.
  describe 'on a real socket' do
    around do |example|
      WebMock.disable_net_connect!(allow_localhost: true)
      example.run
    ensure
      WebMock.disable_net_connect!
    end

    # Serves exactly one connection with +handler+, then yields the base url.
    def with_server(handler)
      server = TCPServer.new('127.0.0.1', 0)
      thread = Thread.new do
        socket = server.accept
        begin
          handler.call(socket)
        ensure
          socket.close
        end
      end

      yield "http://127.0.0.1:#{server.addr[1]}"
      thread.join(2)
    ensure
      server.close
    end

    def read_request(socket)
      head = +''
      head << socket.readpartial(4096) until head.include?("\r\n\r\n")
      headers, body = head.split("\r\n\r\n", 2)
      length = headers[/^Content-Length: (\d+)/i, 1].to_i
      body << socket.read(length - body.bytesize) if body.bytesize < length
      [headers, body]
    end

    it 'sends the upload body and headers intact' do
      seen = nil
      handler = lambda do |socket|
        seen = read_request(socket)
        socket.write("HTTP/1.1 200 OK\r\nContent-Length: 0\r\nConnection: close\r\n\r\n")
      end

      with_server(handler) do |base|
        documents.upload({ url: "#{base}/doc?sig=1" }, 'text/xml; charset=UTF-8', "<a>é</a>\n")
      end

      headers, body = seen
      expect(headers).to start_with('PUT /doc?sig=1 HTTP/1.1')
      expect(headers).to include("\r\nContent-Type: text/xml; charset=UTF-8\r\n")
      expect(headers).to include("\r\nContent-Length: 10\r\n")
      expect(body.b).to eq("<a>é</a>\n".b)
    end

    # Runs one download against a server driven by +handler+ and returns
    # the V2 error it raised.
    def download_error(handler)
      with_server(handler) do |base|
        documents.download_report_document({ url: "#{base}/doc" })
      rescue AmazonSpClients::V2::Error => e
        return e
      end
      nil
    end

    it 'wraps a connection the server drops before answering' do
      err = download_error(->(_socket) {})

      expect(err).to be_a(v2::ConnectionError)
      expect(v2::ErrorMapper::TRANSPORT_ERRORS.any? { |klass| err.cause.is_a?(klass) }).to be(true)
    end

    it 'wraps a response cut off inside the headers' do
      handler = lambda do |socket|
        read_request(socket)
        socket.write("HTTP/1.1 200 OK\r\nX-A: 1\r\n")
      end

      err = download_error(handler)

      expect(err).to be_a(v2::ConnectionError)
      expect(err.status).to be_nil
      expect(err.cause).to be_a(Faraday::ClientError)
    end
  end
end

RSpec.describe AmazonSpClients::V2::Client, 'documents' do
  let(:client) { described_class.new(AmazonSpClients::V2::Config.new) { 'ACCESS' } }
  let(:url) { 'https://tortuga-prod-na.s3.amazonaws.com/doc?X-Amz-Signature=SECRET' }

  it 'uploads, downloads feed results and downloads report documents' do
    put = stub_request(:put, url).with(body: 'feed').to_return(status: 200, body: '')
    stub_request(:get, url).to_return(status: 200, body: '{"a":1}',
                                      headers: { 'Content-Type' => 'application/json' })

    client.upload_feed_document({ url: url }, 'text/xml', 'feed')

    expect(put).to have_been_requested
    expect(client.download_feed_result({ url: url })).to eq('a' => 1)
    expect(client.download_report_document({ url: url })).to eq('{"a":1}')
  end

  it 'does not send the access token to S3' do
    stub = stub_request(:get, url).with { |req| !req.headers.key?('X-Amz-Access-Token') }
                                  .to_return(status: 200, body: '')

    client.download_report_document({ url: url })

    expect(stub).to have_been_requested
  end
end
