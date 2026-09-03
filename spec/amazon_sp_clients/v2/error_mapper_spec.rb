require 'spec_helper'
require 'amazon_sp_clients/v2'

RSpec.describe AmazonSpClients::V2::ErrorMapper do
  v2 = AmazonSpClients::V2

  let(:base_url) { 'https://api.example.test' }
  let(:conn) { Faraday.new(url: base_url) }

  def mapper(service)
    described_class.new(service)
  end

  # Stubs one response, runs the request through a bare connection and
  # returns the V2 error the mapper raises for it (nil when it passes).
  def error_for(service, status:, body: '', response_headers: {}, request_headers: {},
                method: :get, path: '/thing', request_body: nil)
    stub_request(method, "#{base_url}#{path}")
      .to_return(status: status, body: body, headers: response_headers)
    response = conn.run_request(method, path, request_body, request_headers)

    mapper(service).check!(response)
    nil
  rescue AmazonSpClients::V2::Error => e
    e
  end

  # Raises +exception+, wraps it the way the client does, and returns
  # the wrapper so specs can look at its cause.
  def wrapped(exception, service: :api, url: "#{base_url}/thing")
    raise exception
  rescue StandardError => e
    begin
      raise mapper(service).transport_error(e, method: :get, url: url)
    rescue AmazonSpClients::V2::Error => wrapper
      wrapper
    end
  end

  describe 'constructor' do
    it 'accepts only the services V2 uses' do
      expect(described_class::SERVICES).to eq(%i[api lwa documents])
      expect { described_class.new(:bogus) }.to raise_error(ArgumentError, /bogus/)
    end
  end

  describe '#check! for the API service' do
    {
      400 => v2::BadRequestError,
      401 => v2::UnauthorizedError,
      403 => v2::ForbiddenError,
      404 => v2::NotFoundError,
      429 => v2::ThrottledError,
      418 => v2::ClientError,
      500 => v2::ServerError,
      503 => v2::ServerError
    }.each do |status, klass|
      it "raises #{klass} on #{status}" do
        expect(error_for(:api, status: status)).to be_an_instance_of(klass)
      end
    end

    it 'returns the response on 2xx' do
      stub_request(:get, "#{base_url}/thing").to_return(status: 200, body: 'ok')
      response = conn.get('/thing')

      expect(mapper(:api).check!(response)).to be(response)
    end

    it 'formats the message from the SP-API error body' do
      body = '{"errors":[{"code":"InvalidInput","message":"Invalid Input"}]}'

      err = error_for(:api, status: 400, body: body)

      expect(err.message).to eq('400 InvalidInput: Invalid Input')
      expect(err.code).to eq('InvalidInput')
      expect(err.errors.map(&:message)).to eq(['Invalid Input'])
    end

    it 'joins several errors and keeps details' do
      body =
        '{"errors":[{"code":"QuotaExceeded","message":"slow down"},' \
        '{"code":"InvalidInput","message":"bad asin","details":"asin B0"}]}'

      err = error_for(:api, status: 429, body: body)

      expect(err.message).to eq('429 QuotaExceeded: slow down; InvalidInput: bad asin (asin B0)')
      expect(err.errors.size).to eq(2)
    end

    it 'survives an errors array with entries that are not objects' do
      body = '{"errors":["oops",null,{"code":"X","message":"m"}]}'

      err = error_for(:api, status: 500, body: body)

      expect(err).to be_an_instance_of(v2::ServerError)
      expect(err.errors.map(&:code)).to eq(['X'])
      expect(err.message).to eq('500 X: m')
    end

    it 'says so when the body is empty or not JSON' do
      expect(error_for(:api, status: 500, body: '').message).to eq('500 (no body)')
      expect(error_for(:api, status: 502, body: '<html>').message).to eq('502 (body is not JSON)')
    end

    it 'reads the request id and rate limit headers in any case' do
      err = error_for(
        :api, status: 429,
              response_headers: { 'x-amzn-requestid' => 'req-1', 'x-amzn-ratelimit-limit' => '0.5' }
      )

      expect(err.status).to eq(429)
      expect(err.request_id).to eq('req-1')
      expect(err.rate_limit).to eq(0.5)
    end

    it 'has no rate limit when the header is absent' do
      expect(error_for(:api, status: 400).rate_limit).to be_nil
    end

    # Consumers log these errors; tokens must not leak through them.
    it 'keeps the response and a redacted copy of the request' do
      err = error_for(
        :api, status: 400, body: 'oops', method: :post, path: '/orders/v0/orders',
              request_body: 'req',
              request_headers: {
                'x-amz-access-token' => 'SECRET', 'authorization' => 'AWS secret',
                'x-amz-security-token' => 'STS', 'X-Custom' => 'kept'
              }
      )

      expect(err.response).to include(status: 400, body: 'oops')
      expect(err.request).to include(method: :post, path: '/orders/v0/orders', body: 'req')
      headers = err.request[:headers]
      expect(headers['x-amz-access-token']).to eq('[FILTERED]')
      expect(headers['authorization']).to eq('[FILTERED]')
      expect(headers['X-Amz-Security-Token']).to eq('[FILTERED]')
      expect(headers['x-custom']).to eq('kept')
    end

    it 'keeps the query string in the request url' do
      err = error_for(:api, status: 400, path: '/orders?MarketplaceIds=ATVPDKIKX0DER')

      expect(err.request[:url]).to eq("#{base_url}/orders?MarketplaceIds=ATVPDKIKX0DER")
    end

    it 'treats a response without status as a connection error' do
      env = Faraday::Env.from(
        method: :get, url: URI("#{base_url}/thing"), status: nil,
        request_headers: Faraday::Utils::Headers.new, response_headers: Faraday::Utils::Headers.new
      )

      expect { mapper(:api).check!(Faraday::Response.new(env)) }
        .to raise_error(v2::ConnectionError, /no status/)
    end
  end

  describe '#check! for the LWA service' do
    let(:token_path) { '/auth/o2/token' }

    it 'maps invalid_grant to InvalidGrantError with code and description' do
      body = '{"error":"invalid_grant",' \
             '"error_description":"The request has an invalid grant parameter : refresh_token"}'

      err = error_for(:lwa, status: 400, body: body, method: :post, path: token_path)

      expect(err).to be_an_instance_of(v2::InvalidGrantError)
      expect(err.code).to eq('invalid_grant')
      expect(err.description).to eq('The request has an invalid grant parameter : refresh_token')
      expect(err.message)
        .to eq('400 invalid_grant: The request has an invalid grant parameter : refresh_token')
    end

    it 'maps invalid_client to InvalidClientError' do
      err = error_for(:lwa, status: 401, body: fixture('token_error.json'), method: :post,
                            path: token_path)

      expect(err).to be_an_instance_of(v2::InvalidClientError)
      expect(err.message).to eq('401 invalid_client: Client authentication failed')
    end

    it 'maps other 4xx codes to AuthError' do
      body = '{"error":"unauthorized_client","error_description":"no"}'

      err = error_for(:lwa, status: 400, body: body, method: :post, path: token_path)

      expect(err).to be_an_instance_of(v2::AuthError)
      expect(err.code).to eq('unauthorized_client')
    end

    it 'maps 5xx to ServerError' do
      expect(error_for(:lwa, status: 500, method: :post, path: token_path))
        .to be_an_instance_of(v2::ServerError)
    end

    # A throttled token request is not a credentials problem.
    it 'maps 429 to ThrottledError' do
      err = error_for(:lwa, status: 429, body: '{"error":"TooManyRequests"}', method: :post,
                            path: token_path)

      expect(err).to be_an_instance_of(v2::ThrottledError)
      expect(err.request[:body]).to eq('[FILTERED]')
    end

    # The token request body carries client_secret and refresh_token.
    it 'filters the request body' do
      err = error_for(:lwa, status: 400, body: '{"error":"invalid_grant"}', method: :post,
                            path: token_path, request_body: 'client_secret=SECRET')

      expect(err.request[:body]).to eq('[FILTERED]')
    end
  end

  describe '#check! for the documents service' do
    # Presigned S3 urls carry their credential in the query string.
    it 'raises DocumentError with the status and reason, query stripped' do
      err = error_for(:documents, status: [403, 'Forbidden'], path: '/doc?X-Amz-Signature=SECRET')

      expect(err).to be_an_instance_of(v2::DocumentError)
      expect(err.message).to eq('403 Forbidden')
      expect(err.request[:url]).to eq("#{base_url}/doc")
      expect(err.request[:path]).to eq('/doc')
    end

    it 'reports only the status when there is no reason phrase' do
      expect(error_for(:documents, status: 500).message).to eq('500')
    end
  end

  describe '#parse_error' do
    it 'builds a ParseError that carries the redacted request context' do
      stub_request(:post, "#{base_url}/auth/o2/token")
        .to_return(status: 200, body: 'x', headers: { 'x-amzn-RequestId' => 'RID' })
      response = conn.run_request(:post, '/auth/o2/token', 'client_secret=S', {})

      err = mapper(:lwa).parse_error('bad body', response)

      expect(err).to be_a(v2::ParseError)
      expect(err.message).to eq('bad body')
      expect(err.status).to eq(200)
      expect(err.request_id).to eq('RID')
      expect(err.request[:path]).to eq('/auth/o2/token')
      expect(err.request[:body]).to eq('[FILTERED]')
      expect(err.response[:body]).to eq('x')
    end
  end

  describe '#transport_error' do
    it 'wraps timeouts as TimeoutError and keeps the cause' do
      err = wrapped(Faraday::TimeoutError.new('slow'))

      expect(err).to be_an_instance_of(v2::TimeoutError)
      expect(err.cause).to be_a(Faraday::TimeoutError)
      expect(err.message).to eq('Faraday::TimeoutError: slow')
      expect(err.request).to eq(method: :get, url: "#{base_url}/thing", path: '/thing')
    end

    it 'wraps the other transport failures as ConnectionError' do
      [
        Faraday::ConnectionFailed.new('refused'),
        Faraday::ClientError.new('bad response'),
        HTTPClient::KeepAliveDisconnected.new,
        Errno::EHOSTUNREACH.new,
        SocketError.new('dns')
      ].each do |exception|
        expect(wrapped(exception)).to be_an_instance_of(v2::ConnectionError)
      end
    end

    it 'strips the query from document urls' do
      url = "#{base_url}/doc?X-Amz-Signature=SECRET"

      err = wrapped(Faraday::ConnectionFailed.new('x'), service: :documents, url: url)

      expect(err.request[:url]).to eq("#{base_url}/doc")
    end

    # beagle_worker cancels a task by raising into the cart's thread; a
    # blanket rescue would turn that into a connection error.
    it 'names only transport exceptions, never StandardError' do
      list = described_class::TRANSPORT_ERRORS

      expect(list).to include(Faraday::Error, HTTPClient::KeepAliveDisconnected,
                              SystemCallError, IOError, SocketError)
      expect(list).not_to include(StandardError)
      expect(list.any? { |klass| klass >= RuntimeError }).to be(false)
    end
  end
end
