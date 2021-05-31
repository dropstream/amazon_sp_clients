require 'spec_helper'
require 'webmock/rspec'
# require 'pry-byebug'

require 'amazon_sp_clients/sp_orders_v0'

def fixture(name)
  File.read(File.expand_path("../../spec/fixtures/#{name}.json", __FILE__))
end

RSpec.describe AmazonSpClients do
  before { AmazonSpClients.configure.sandbox_env! }

  describe 'smoke tests' do
    it 'success response' do
      stub_request(
        :get,
        'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders/TEST_CASE_200'
      ).to_return(status: 200, body: fixture('order_200_response'))

      orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new
      get_order_response = orders_api.get_order('TEST_CASE_200')

      expect(get_order_response).to be_instance_of(
        AmazonSpClients::SpOrdersV0::GetOrderResponse
      )
      expect(get_order_response.payload).to be_a(Hash)
      expect(get_order_response.payload[:OrderStatus]).to eq 'Pending'
      expect(get_order_response.errors).to be_nil

      # Yes, this is the only way to create a model from response...
      order_model =
        AmazonSpClients::SpOrdersV0::Order.build_from_hash(
          get_order_response.payload
        )

      expect(order_model.order_status).to eq 'Pending'
      expect(order_model.amazon_order_id).to eq '902-3159896-1390916'
      expect(order_model.fulfillment_channel).to eq 'AFN'
      expect(order_model.seller_order_id).to be_nil

      expect(order_model.to_hash).to be_a(Hash)

      # the mapping is still CamelCase
      expect(order_model.to_hash[:OrderStatus]).to eq 'Pending'

      # to find by snake_case attrib
      attribute_map = AmazonSpClients::SpOrdersV0::Order.attribute_map
      expect(
        order_model.to_hash[attribute_map[:order_status]]
      ).to eq 'Pending'
    end
  end
end
