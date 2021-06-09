require 'spec_helper'
require 'webmock/rspec'
require 'logger'
require 'dotenv/load'
require 'awesome_print'

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
      c.debugging = false
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
          AmazonSpClients::ApiResponse
        )
        expect(get_orders_response.payload).to be_a(Hash)
        expect(get_orders_response.payload[:Orders].first).to be_a(Hash)
        expect(get_orders_response.payload[:Orders].count).to eq 1
        expect(get_orders_response.errors).to be_nil

        expect(get_orders_response.original_response.status).to eq 200
      end
    end

    context 'error conditions' do
      it 'returns error response' do
        stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders?CreatedAfter=TEST_CASE_400&MarketplaceIds=ATVPDKIKX0DER'
        ).to_return(
          status: 400,
          body: %q[{"errors":[{"code":"InvalidInput","message":"Invalid Input"}]}],
          headers: {
            'Date' => 'Wed, 09 Jun 2021 09:16:55 GMT',
            'Content-Type' => 'application/json',
            'Content-Length' => '62',
            'Connection' => 'keep-alive',
            'x-amzn-RequestId' => '3b9f0d8b-0b92-4582-8152-a5c56b5c998d',
            'x-amz-apigw-id' => 'ApoJKGnsIAMF7Xw=',
            'X-Amzn-Trace-Id' =>
              'Root=1-60c08707-4aade6f26fc77d032b0ccefe;Sampled=0'
          }
        )

        orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new
        get_orders_response =
          orders_api.get_orders(
            ['ATVPDKIKX0DER'],
            created_after: 'TEST_CASE_400'
          )

        expect(get_orders_response.errors).not_to be_nil
        expect(get_orders_response.payload).to be_nil
        expect(get_orders_response.errors).to be_instance_of(
          AmazonSpClients::ApiError
        )
        expect(get_orders_response.errors.full_messages).to eq(
          "InvalidInput: Invalid Input"
        )

        expect(get_orders_response.original_response.status).to eq 400
      end
    end
  end
end
