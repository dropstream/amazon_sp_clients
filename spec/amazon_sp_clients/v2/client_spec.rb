require 'spec_helper'
require 'amazon_sp_clients/v2'

RSpec.describe AmazonSpClients::V2::Client do
  v2 = AmazonSpClients::V2

  let(:base_url) { 'https://sellingpartnerapi-na.amazon.com' }
  let(:orders_url) { "#{base_url}/orders/v0/orders" }
  let(:tokens_url) { "#{base_url}/tokens/2021-03-01/restrictedDataToken" }
  let(:lwa_url) { 'https://api.amazon.com/auth/o2/token' }
  let(:now) { Time.utc(2026, 9, 3, 12, 0, 0) }
  let(:config) { v2::Config.new }
  let(:client) { described_class.new(config) { 'ACCESS' } }

  before { Timecop.freeze(now) }

  def rdt_body(token = 'RDT', expires_in: 3600)
    %({"restrictedDataToken":"#{token}","expiresIn":#{expires_in}})
  end

  describe 'construction' do
    it 'takes a block as the token source' do
      stub = stub_request(:get, orders_url).with(headers: { 'x-amz-access-token' => 'ACCESS' })
                                           .to_return(status: 200, body: '{}')

      client.request(:get, '/orders/v0/orders')

      expect(stub).to have_been_requested
    end

    it 'takes explicit credentials' do
      creds = v2::Credentials::Callback.new { 'FROM_CREDS' }
      stub = stub_request(:get, orders_url).with(headers: { 'x-amz-access-token' => 'FROM_CREDS' })
                                           .to_return(status: 200, body: '{}')

      described_class.new(config, credentials: creds).request(:get, '/orders/v0/orders')

      expect(stub).to have_been_requested
    end

    it 'needs exactly one token source' do
      creds = v2::Credentials::Callback.new { 'X' }

      expect { described_class.new(config) }.to raise_error(ArgumentError, /credentials/)
      expect { described_class.new(config, credentials: creds) { 'X' } }
        .to raise_error(ArgumentError, /credentials/)
    end

    it 'exposes its config' do
      expect(client.config).to be(config)
    end

    # beagle_event_logger injects its middleware when the stack is
    # locked, which must still happen at the first request, not at
    # construction.
    it 'leaves the middleware stack unlocked until the first request' do
      conn = client.instance_variable_get(:@api)

      expect(conn.builder.locked?).to be(false)
    end

    it 'applies the config timeouts to the connection' do
      client = described_class.new(v2::Config.new(timeout: 7, open_timeout: 3)) { 'X' }
      conn = client.instance_variable_get(:@api)

      expect(conn.options.timeout).to eq(7)
      expect(conn.options.open_timeout).to eq(3)
    end
  end

  describe '.with_refresh_token' do
    let(:config) { v2::Config.new(client_id: 'ID', client_secret: 'SECRET') }

    it 'exchanges through LWA once and sends the access token' do
      lwa = stub_request(:post, lwa_url)
            .with(body: hash_including('grant_type' => 'refresh_token', 'refresh_token' => 'RT'))
            .to_return(status: 200, body: fixture('token_success.json'))
      access_token = 'Atza|IQEBLjAsAhRmHjNgHpi0U-Dme37rR6CuUpSREXAMPLE'
      orders = stub_request(:get, orders_url)
               .with(headers: { 'x-amz-access-token' => access_token })
               .to_return(status: 200, body: '{}')

      client = described_class.with_refresh_token(config, 'RT')
      2.times { client.request(:get, '/orders/v0/orders') }

      expect(lwa).to have_been_requested.once
      expect(orders).to have_been_requested.twice
    end
  end

  describe '#request' do
    it 'sends the standard headers and a JSON body' do
      stub = stub_request(:post, orders_url)
             .with(
               body: '{"a":1}',
               headers: {
                 'x-amz-access-token' => 'ACCESS',
                 'x-amz-date' => '20260903T120000Z',
                 'Content-Type' => 'application/json',
                 'Accept' => 'application/json',
                 'User-Agent' => config.user_agent
               }
             )
             .to_return(status: 200, body: '{}')

      client.request(:post, '/orders/v0/orders', body: { a: 1 })

      expect(stub).to have_been_requested
    end

    it 'sends a String body as it is' do
      stub = stub_request(:put, orders_url).with(body: 'raw').to_return(status: 200, body: '{}')

      client.request(:put, '/orders/v0/orders', body: 'raw')

      expect(stub).to have_been_requested
    end

    it 'drops nil query values and sends false' do
      stub = stub_request(:get, orders_url)
             .with(query: { 'MarketplaceIds' => 'A', 'IsISPU' => 'false' })
             .to_return(status: 200, body: '{}')

      client.request(:get, '/orders/v0/orders',
                     query: { 'MarketplaceIds' => 'A', 'NextToken' => nil, 'IsISPU' => false })

      expect(stub).to have_been_requested
    end

    it 'merges per-request headers' do
      stub = stub_request(:get, orders_url).with(headers: { 'x-custom' => 'yes' })
                                           .to_return(status: 200, body: '{}')

      client.request(:get, '/orders/v0/orders', headers: { 'x-custom' => 'yes' })

      expect(stub).to have_been_requested
    end

    it 'returns an ApiResponse with symbol keys, pagination and the rate limit' do
      stub_request(:get, orders_url).to_return(
        status: 200,
        body: '{"payload":{"Orders":[{"AmazonOrderId":"1"}]},"pagination":{"nextToken":"N"}}',
        headers: { 'x-amzn-RateLimit-Limit' => '0.0167' }
      )

      response = client.request(:get, '/orders/v0/orders')

      expect(response).to be_a(AmazonSpClients::ApiResponse)
      expect(response.payload).to eq(Orders: [{ AmazonOrderId: '1' }])
      expect(response.pagination).to eq(nextToken: 'N')
      expect(response.reported_rate_limit).to eq(0.0167)
    end

    it 'returns an ApiResponse for an empty body' do
      stub_request(:post, orders_url).to_return(status: 204, body: '',
                                                headers: { 'x-amzn-RateLimit-Limit' => '2' })

      response = client.request(:post, '/orders/v0/orders')

      expect(response.payload).to eq({})
      expect(response.reported_rate_limit).to eq(2.0)
    end

    it 'wraps a non-object JSON body as the payload' do
      stub_request(:get, orders_url).to_return(status: 200, body: '[1,2]')

      expect(client.request(:get, '/orders/v0/orders').payload).to eq([1, 2])
    end

    it 'raises ParseError with the request context on a 2xx body that is not JSON' do
      stub_request(:get, orders_url)
        .to_return(status: 200, body: '<html>', headers: { 'x-amzn-RequestId' => 'RID' })

      expect { client.request(:get, '/orders/v0/orders') }.to raise_error(v2::ParseError) do |err|
        expect(err.status).to eq(200)
        expect(err.request_id).to eq('RID')
        expect(err.request[:path]).to eq('/orders/v0/orders')
        expect(err.request[:headers]['x-amz-access-token']).to eq('[FILTERED]')
      end
    end

    it 'raises the mapped error on a non-2xx response' do
      stub_request(:get, orders_url).to_return(
        status: 403, body: '{"errors":[{"code":"Unauthorized","message":"Access denied"}]}'
      )

      expect { client.request(:get, '/orders/v0/orders') }
        .to raise_error(v2::ForbiddenError, '403 Unauthorized: Access denied') do |err|
          expect(err.request[:path]).to eq('/orders/v0/orders')
          expect(err.request[:headers]['x-amz-access-token']).to eq('[FILTERED]')
        end
    end

    it 'wraps a timeout as TimeoutError' do
      stub_request(:get, orders_url).to_timeout

      expect { client.request(:get, '/orders/v0/orders') }.to raise_error(v2::TimeoutError)
    end

    it 'wraps a refused connection as ConnectionError' do
      stub_request(:get, orders_url).to_raise(Errno::ECONNREFUSED)

      expect { client.request(:get, '/orders/v0/orders') }.to raise_error(v2::ConnectionError)
    end

    # beagle_worker cancels a task by raising into the cart's thread.
    it 'lets a foreign exception from the transport through unwrapped' do
      cancel = Class.new(StandardError)
      stub_request(:get, orders_url).to_raise(cancel.new('cancelled'))

      expect { client.request(:get, '/orders/v0/orders') }.to raise_error(cancel, 'cancelled')
    end

    it 'sends each thread its own callback token' do
      client = described_class.new(config) { Thread.current[:token] }
      stub_request(:get, orders_url).to_return do |request|
        { status: 200, body: %({"echo":"#{request.headers['X-Amz-Access-Token']}"}) }
      end

      echoes = Array.new(8) do |i|
        Thread.new do
          Thread.current[:token] = "T#{i}"
          [Thread.current[:token], client.request(:get, '/orders/v0/orders').payload[:echo]]
        end
      end.map(&:value)

      echoes.each { |token, echo| expect(echo).to eq(token) }
    end
  end

  describe '#request with rdt:' do
    let(:resources) { v2::RDT::ORDERS_AND_ITEMS }

    it 'fetches a restricted token with the normal token, then uses it' do
      tokens = stub_request(:post, tokens_url)
               .with(
                 headers: { 'x-amz-access-token' => 'ACCESS' },
                 body: {
                   restrictedResources: [
                     { method: 'GET', path: '/orders/v0/orders',
                       dataElements: %w[buyerInfo shippingAddress] },
                     { method: 'GET', path: '/orders/v0/orders/{orderId}/orderItems',
                       dataElements: %w[buyerInfo] }
                   ]
                 }.to_json
               )
               .to_return(status: 200, body: rdt_body)
      orders = stub_request(:get, orders_url).with(headers: { 'x-amz-access-token' => 'RDT' })
                                             .to_return(status: 200, body: '{}')

      client.request(:get, '/orders/v0/orders', rdt: resources)

      expect(tokens).to have_been_requested
      expect(orders).to have_been_requested
    end

    it 'reuses the restricted token while it is fresh' do
      tokens = stub_request(:post, tokens_url).to_return(status: 200, body: rdt_body)
      stub_request(:get, orders_url).to_return(status: 200, body: '{}')

      3.times { client.request(:get, '/orders/v0/orders', rdt: resources) }

      expect(tokens).to have_been_requested.once
    end

    it 'fetches again once the restricted token counts as expired' do
      tokens = stub_request(:post, tokens_url)
               .to_return(status: 200, body: rdt_body(expires_in: 100))
      stub_request(:get, orders_url).to_return(status: 200, body: '{}')

      client.request(:get, '/orders/v0/orders', rdt: resources)
      Timecop.freeze(now + 100)
      client.request(:get, '/orders/v0/orders', rdt: resources)

      expect(tokens).to have_been_requested.twice
    end

    it 'keeps one token per document resource' do
      tokens = stub_request(:post, tokens_url).to_return(status: 200, body: rdt_body)
      stub_request(:get, %r{#{base_url}/reports/2021-06-30/documents/})
        .to_return(status: 200, body: '{}')

      %w[D1 D2 D1].each do |doc|
        path = "/reports/2021-06-30/documents/#{doc}"
        client.request(:get, path, rdt: [v2::RDT.resource('GET', path)])
      end

      expect(tokens).to have_been_requested.twice
    end

    it 'fetches once when many threads need the same restricted token' do
      fetches = 0
      lock = Mutex.new
      stub_request(:post, tokens_url).to_return do
        lock.synchronize { fetches += 1 }
        sleep(0.02)
        { status: 200, body: rdt_body }
      end
      stub_request(:get, orders_url).to_return(status: 200, body: '{}')

      Array.new(6) { Thread.new { client.request(:get, '/orders/v0/orders', rdt: resources) } }
           .each(&:join)

      expect(fetches).to eq(1)
    end

    it 'raises the mapped error when the token request fails' do
      stub_request(:post, tokens_url)
        .to_return(status: 403, body: '{"errors":[{"code":"Unauthorized","message":"no"}]}')

      expect { client.request(:get, '/orders/v0/orders', rdt: resources) }
        .to raise_error(v2::ForbiddenError) do |err|
          expect(err.request[:path]).to eq('/tokens/2021-03-01/restrictedDataToken')
        end
    end

    it 'raises ParseError when the token response has no token' do
      stub_request(:post, tokens_url).to_return(status: 200, body: '{"expiresIn":3600}')

      expect { client.request(:get, '/orders/v0/orders', rdt: resources) }
        .to raise_error(v2::ParseError, /restrictedDataToken/) do |err|
          expect(err.request[:path]).to eq('/tokens/2021-03-01/restrictedDataToken')
        end
    end

    # The cache lock is held while the token request runs, and that
    # request asks the credentials for the LWA token. Both locks nest in
    # that order only, so an expired LWA token on an RDT miss must not
    # deadlock.
    it 'refreshes an expired LWA token inside a restricted token fetch' do
      config = v2::Config.new(client_id: 'ID', client_secret: 'SECRET')
      lwa = stub_request(:post, lwa_url).to_return(status: 200, body: fixture('token_success.json'))
      tokens = stub_request(:post, tokens_url).to_return(status: 200, body: rdt_body)
      stub_request(:get, orders_url).to_return(status: 200, body: '{}')

      client = described_class.with_refresh_token(config, 'RT')
      client.request(:get, '/orders/v0/orders', rdt: resources)

      expect(lwa).to have_been_requested.once
      expect(tokens).to have_been_requested.once
    end
  end

  describe '#api' do
    let(:api_class) { Class.new(v2::Api) }

    it 'builds one instance per class and reuses it' do
      expect(client.api(api_class)).to be_a(api_class)
      expect(client.api(api_class)).to be(client.api(api_class))
    end

    it 'returns the same instance to every thread' do
      instances = Array.new(8) { Thread.new { client.api(api_class) } }.map(&:value)

      expect(instances.uniq.size).to eq(1)
    end
  end
end
