require 'spec_helper'
require 'webmock/rspec'
require 'logger'

require 'amazon_sp_clients/sp_orders_v0'

def fixture(name)
  File.read(File.expand_path("../../spec/fixtures/#{name}.json", __FILE__))
end

RSpec.describe AmazonSpClients do
  before do
    AmazonSpClients.configure.sandbox_env!
    AmazonSpClients.configure do |c|
      c.marketplace = :us
      c.access_token = 'Azta|FooBar'
      c.access_key = 'FooBar'
      c.secret_key = 'SECRET_KEY'

      c.logger = Logger.new($stdout)
      c.logger.level = Logger::DEBUG
      # c.debugging = true
    end
  end

  describe 'orders smoke tests' do
    context 'success conditions' do
      it 'returns list of orders' do
        stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders?CreatedAfter=TEST_CASE_200&MarketplaceIds=ATVPDKIKX0DER'
        ).to_return(status: 200, body: fixture('orders_200_response'))

        # .with(
        #   headers: {
        #     'Accept' => 'application/json',
        #     'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        #     'Authorization' => 'AWS4-HMAC-SHA256 Credential=FooBar/20210603/us-east-1/execute-api/aws4_request, SignedHeaders=accept;content-type;host;user-agent;x-amz-access-token;x-amz-date, Signature=d4a72b2c79678336713c3d931d9610580d20edff69d7a80bbc2e2cbda06e9974',
        #     'Content-Type' => 'application/json',
        #     'Host' => 'sandbox.sellingpartnerapi-na.amazon.com',
        #     'User-Agent' => 'Dropstream/1.0 (Language=Ruby/2.5.8)',
        #     'X-Amz-Access-Token' => 'Azta|FooBar',
        #     'X-Amz-Date' => '20210603T105955Z'
        #   }
        # )

        orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new
        get_orders_response =
          orders_api.get_orders(
            ['ATVPDKIKX0DER'],
            created_after: 'TEST_CASE_200'
          )

        expect(get_orders_response).to be_instance_of(
          AmazonSpClients::SpOrdersV0::GetOrdersResponse
        )
        expect(get_orders_response.payload).to be_a(Hash)
        expect(get_orders_response.payload[:Orders].first).to be_a(Hash)
        expect(get_orders_response.payload[:Orders].count).to eq 1
        expect(get_orders_response.errors).to be_nil

        orders = get_orders_response.payload[:Orders].map do |hash|
          AmazonSpClients::SpOrdersV0::Order.build_from_hash(
            hash
          )
        end

        expect(orders.first.order_status).to eq 'Pending'
      end
    end
  end
end
