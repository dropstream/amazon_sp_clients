require 'spec_helper'
require 'logger'
require 'dotenv/load'
require 'ostruct'

require 'amazon_sp_clients/sp_orders_v0'
require 'amazon_sp_clients/sp_tokens_2021'

class NullSession
  def authenticate(*args); end

  def refresh; end

  def ask_for_restricted_data_token; end

  def access_token
    'oaisdhgoajsdfoahgasd'
  end

  def restricted_data_token
    'RESTRTOKENosdfjaoighasdf'
  end
end

RSpec.describe AmazonSpClients do
  before do
    new_time = Time.local(2018, 9, 1, 12, 0, 0)
    Timecop.freeze(new_time)

    AmazonSpClients.configure do |c|
      c.client_id = ENV['AMZ_CLIENT_ID'] || 'CLIENT_ID'
      c.client_secret = ENV['AMZ_CLIENT_SECRET'] || 'CLIENT_SECRET'

      c.sandbox_env!
    end
  end

  # The default config is thread-local and shared across examples;
  # drop it so endpoint or credential changes cannot leak.
  after { Thread.current[:amazon_sp_configuration] = nil }

  class Resources
    def to_json(*_opts)
      '{"method":"GET","path":"/orders/v0/orders","dataElements":["buyerInfo","shippingAddress"]},{"method":"GET","path":"/orders/v0/orders/{orderId}/orderItems","dataElements":["buyerInfo"]}'
    end
  end

  describe 'restricted access resources' do
    context 'success path' do
      it 'returns success response with PII data' do
        stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(
          status: 200,
          body: fixture('token_success.json')
        )

        stub_request(
          :post,
          'https://sandbox.sellingpartnerapi-na.amazon.com/tokens/2021-03-01/restrictedDataToken'
        )
          .with(
            body:
            '{"restrictedResources":[{"method":"GET","path":"/orders/v0/orders","dataElements":["buyerInfo","shippingAddress"]},{"method":"GET","path":"/orders/v0/orders/{orderId}/orderItems","dataElements":["buyerInfo"]}]}'
          )
          .to_return(
            status: 200,
            body: '{"payload":{"restrictedDataToken":"RESTRICTED_TOKEN","expiresIn":3600}}'
          )

        stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders/marketplace_id'
        ).to_return(status: 200, body: '{"payload":{}}', headers: { 'x-amzn-RateLimit-Limit' => '0.2' })

        refresh_token = ENV['AMZ_REFRESH_TOKEN'] || 'REFRESH_TOKEN'
        session = AmazonSpClients.new_session(refresh_token)

        orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new(session)
        resource = Resources.new
        opts = { auth_names: resource }
        order_resp = orders_api.get_order('marketplace_id', opts)

        expect(order_resp.payload).not_to be_nil
        expect(order_resp.reported_rate_limit).to eq(0.2)
        expect(session.restricted_data_token).to be_a(Hash)
        expect(session.restricted_data_token[resource]).to eq('RESTRICTED_TOKEN')
      end
    end
  end

  describe 'complete flow test' do
    context 'success path' do
      it 'returns success responses' do
        stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(
          status: 200,
          body: fixture('token_success.json')
        )

        stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders?CreatedAfter=TEST_CASE_200&MarketplaceIds=ATVPDKIKX0DER'
        ).to_return(status: 200, body: fixture('orders_200_response.json'))

        refresh_token = ENV['AMZ_REFRESH_TOKEN'] || 'REFRESH_TOKEN'

        session, err = AmazonSpClients.new_session(refresh_token)
        orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new(session)
        get_orders_response =
          orders_api.get_orders(['ATVPDKIKX0DER'], created_after: 'TEST_CASE_200')

        expect(err).to be_nil
        expect(get_orders_response).to be_instance_of(AmazonSpClients::ApiResponse)
        expect(get_orders_response.payload).to be_a(Hash)
        expect(get_orders_response.payload[:Orders].first).to be_a(Hash)
        expect(get_orders_response.payload[:Orders].count).to eq 1
        expect(get_orders_response.errors).to be_nil
      end
    end

    context 'success path with different region' do
      it 'returns success responses' do
        stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(
          status: 200,
          body: fixture('token_success.json')
        )

        stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-eu.amazon.com/orders/v0/orders?CreatedAfter=TEST_CASE_200&MarketplaceIds=ATVPDKIKX0DER'
        ).to_return(status: 200, body: fixture('orders_200_response.json'))

        refresh_token = ENV['AMZ_REFRESH_TOKEN'] || 'REFRESH_TOKEN'

        AmazonSpClients.configure.set_endpoint_by_marketplace_id('A1RKKUPIHCS9HS')

        session, err = AmazonSpClients.new_session(refresh_token)
        orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new(session)
        get_orders_response =
          orders_api.get_orders(['ATVPDKIKX0DER'], created_after: 'TEST_CASE_200')

        expect(err).to be_nil
        expect(get_orders_response).to be_instance_of(AmazonSpClients::ApiResponse)
        expect(get_orders_response.payload).to be_a(Hash)
        expect(get_orders_response.payload[:Orders].first).to be_a(Hash)
        expect(get_orders_response.payload[:Orders].count).to eq 1
        expect(get_orders_response.errors).to be_nil
      end
    end

    context 'with token error' do
      it 'session never runs and returns error' do
        stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(
          status: 400,
          body: fixture('token_error.json')
        )

        refresh_token = ENV['AMZ_REFRESH_TOKEN'] || 'REFRESH_TOKEN'

        expect do
          AmazonSpClients.new_session(refresh_token)
        end.to raise_error Faraday::BadRequestError
      end
    end

    context 'error api response' do
      it 'returns error response' do
        stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders?CreatedAfter=TEST_CASE_400&MarketplaceIds=ATVPDKIKX0DER'
        ).to_return(
          status: 400,
          body: '{"errors":[{"code":"InvalidInput","message":"Invalid Input"}]}',
          headers: {
            'Date' => 'Wed, 09 Jun 2021 09:16:55 GMT',
            'Content-Type' => 'application/json',
            'Content-Length' => '62',
            'Connection' => 'keep-alive',
            'x-amzn-RequestId' => '3b9f0d8b-0b92-4582-8152-a5c56b5c998d',
            'x-amz-apigw-id' => 'ApoJKGnsIAMF7Xw=',
            'X-Amzn-Trace-Id' => 'Root=1-60c08707-4aade6f26fc77d032b0ccefe;Sampled=0'
          }
        )

        orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new(NullSession.new)

        expect do
          orders_api.get_orders(['ATVPDKIKX0DER'], created_after: 'TEST_CASE_400')
        end.to raise_error Faraday::BadRequestError
      end
    end
  end

  describe 'new_callback_session' do
    let(:api_client) { AmazonSpClients::ApiClient.new(session) }
    let(:session) { AmazonSpClients.new_callback_session(&callback) }
    let(:callback) { -> { access_token } }
    let(:access_token) { 'initial_access_token' }

    before do
      stub_request(:get, %r{https://sandbox\.sellingpartnerapi-na\.amazon\.com/.*})
        .to_return(status: 200, body: '{}')
    end

    it 'calls the callback before each request' do
      expect(callback).to receive(:call).at_least(:twice).and_return(access_token)

      api_client.call_api(:get, '/test/endpoint1')
      api_client.call_api(:get, '/test/endpoint2')
    end

    it 'uses the access token returned by the callback' do
      expect(session).to receive(:access_token).at_least(:twice).and_return(access_token)

      api_client.call_api(:get, '/test/endpoint1')
      api_client.call_api(:get, '/test/endpoint2')
    end

    context 'when the callback returns a new access token each time' do
      let(:counter) do
        Enumerator.new do |yielder|
          count = 0
          loop do
            count += 1
            yielder.yield count
          end
        end
      end

      let(:callback) { -> { counter.next } }

      it 'uses a different access token for each request' do
        api_client.call_api(:get, '/test/endpoint1')
        api_client.call_api(:get, '/test/endpoint2')

        expect(session.access_token).to eq(2)
      end
    end
  end
end
