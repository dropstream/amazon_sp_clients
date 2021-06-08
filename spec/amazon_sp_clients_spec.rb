require 'spec_helper'
require 'webmock/rspec'
require 'logger'

require 'amazon_sp_clients/sp_orders_v0'

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
      c.debugging = true
    end
  end

  describe 'orders smoke tests' do
    context 'success conditions' do
      it 'returns list of orders' do
        stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders?CreatedAfter=TEST_CASE_200&MarketplaceIds=ATVPDKIKX0DER'
        ).to_return(status: 200, body: fixture('orders_200_response.json'))

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

        orders = AmazonSpClients::SpOrdersV0::OrdersList.build_from_hash(
          get_orders_response.payload
        )

        expect(orders.orders.first[:OrderStatus]).to eq 'Pending'
      end
    end
  end
end
