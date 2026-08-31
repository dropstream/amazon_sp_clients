require 'spec_helper'

RSpec.describe AmazonSpClients::Middlewares::RaiseError do
  let(:base_url) { 'https://api.example.test' }

  def conn(service)
    Faraday.new(url: base_url) do |c|
      c.use described_class, { service: service }
      c.adapter :net_http
    end
  end

  # Runs the block and returns the Faraday error it raised.
  def rescued_error
    yield
    nil
  rescue Faraday::Error => e
    e
  end

  describe 'constructor' do
    let(:app) { proc {} }

    it 'raises when the service option is missing' do
      expect { described_class.new(app, {}) }.to raise_error(KeyError)
    end

    it 'raises when the service is unknown' do
      expect { described_class.new(app, { service: :bogus }) }
        .to raise_error(an_instance_of(RuntimeError))
    end
  end

  describe 'status to error map' do
    {
      400 => Faraday::BadRequestError,
      401 => Faraday::UnauthorizedError,
      403 => Faraday::ForbiddenError,
      404 => Faraday::ResourceNotFound,
      407 => Faraday::ProxyAuthError,
      409 => Faraday::ConflictError,
      422 => Faraday::UnprocessableEntityError,
      429 => Faraday::RetriableResponse,
      418 => Faraday::ClientError,
      500 => Faraday::ServerError,
      503 => Faraday::ServerError
    }.each do |status, error_class|
      it "raises #{error_class} on #{status}" do
        stub_request(:get, "#{base_url}/thing").to_return(status: status)

        expect { conn(:uploads).get('/thing') }
          .to raise_error(an_instance_of(error_class))
      end
    end

    it 'raises nothing on 200' do
      stub_request(:get, "#{base_url}/thing")
        .to_return(status: 200, body: 'ok')

      expect(conn(:uploads).get('/thing').body).to eq('ok')
    end
  end

  describe 'error message' do
    # Callers (active_cart) match on the "Service 'token'" prefix.
    it 'formats token errors from the JSON body' do
      stub_request(:post, "#{base_url}/auth/o2/token")
        .to_return(status: 400, body: fixture('token_error.json'))

      expect { conn(:token).post('/auth/o2/token') }.to raise_error(
        Faraday::BadRequestError,
        "Service 'token' ERR: error: invalid_client " \
        'description: Client authentication failed'
      )
    end

    it 'formats spapi errors from the JSON body' do
      body = '{"errors":[{"code":"InvalidInput","message":"Invalid Input"}]}'
      stub_request(:get, "#{base_url}/orders").to_return(status: 400, body: body)

      expect { conn(:spapi).get('/orders') }.to raise_error(
        Faraday::BadRequestError,
        "Service 'spapi' ERR: InvalidInput: Invalid Input"
      )
    end

    it 'joins multiple spapi errors with a comma' do
      body =
        '{"errors":[{"code":"QuotaExceeded","message":"slow down"},' \
        '{"code":"InvalidInput","message":"bad asin"}]}'
      stub_request(:get, "#{base_url}/orders").to_return(status: 429, body: body)

      expect { conn(:spapi).get('/orders') }.to raise_error(
        Faraday::RetriableResponse,
        "Service 'spapi' ERR: QuotaExceeded: slow down, InvalidInput: bad asin"
      )
    end

    it 'says (no body) when the body is empty' do
      stub_request(:get, "#{base_url}/thing").to_return(status: 400, body: '')

      expect { conn(:token).get('/thing') }.to raise_error(
        Faraday::BadRequestError,
        'the server responded with status 400 (no body)'
      )
    end

    it 'reports only the status for other services' do
      stub_request(:get, "#{base_url}/thing")
        .to_return(status: 418, body: 'teapot')

      expect { conn(:uploads).get('/thing') }.to raise_error(
        Faraday::ClientError,
        'the server responded with status 418'
      )
    end

    it 'falls back instead of raising on an unparseable body' do
      stub_request(:get, "#{base_url}/thing")
        .to_return(status: 400, body: 'not json')

      # The JSON parse error text lands inside the parentheses.
      expect { conn(:spapi).get('/thing') }.to raise_error(
        Faraday::BadRequestError,
        /\Athe server responded with status 400 \(unexpected token/
      )
    end

    it 'uses a fixed message for 407, ignoring the body' do
      stub_request(:get, "#{base_url}/thing")
        .to_return(status: 407, body: 'ignored')

      expect { conn(:uploads).get('/thing') }.to raise_error(
        Faraday::ProxyAuthError,
        '407 "Proxy Authentication Required"'
      )
    end
  end

  describe 'error payload' do
    it 'exposes service, response and request details' do
      stub_request(:post, "#{base_url}/orders/v0/orders").to_return(
        status: 400,
        body: 'oops',
        headers: { 'x-amzn-requestid' => 'req-id-1' }
      )

      err = rescued_error { conn(:uploads).post('/orders/v0/orders', 'req') }

      expect(err.response[:service]).to eq(:uploads)
      expect(err.response[:response][:status]).to eq(400)
      expect(err.response[:response][:body]).to eq('oops')
      expect(err.response[:response][:headers]['x-amzn-requestid'])
        .to eq('req-id-1')
      expect(err.response[:request][:method]).to eq(:post)
      expect(err.response[:request][:url_path]).to eq('/orders/v0/orders')
      expect(err.response[:request][:body]).to eq('req')
    end
  end
end
