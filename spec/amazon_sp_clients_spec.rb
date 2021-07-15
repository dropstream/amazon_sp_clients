require 'spec_helper'
require 'webmock/rspec'
require 'logger'
require 'dotenv/load'
require 'awesome_print'
require 'timecop'
require 'ostruct'
require 'pry-byebug'

require 'amazon_sp_clients/sp_orders_v0'
require 'amazon_sp_clients/sp_tokens_2021'

class NullSession
  def authenticate(*args); end

  def refresh; end

  def ask_for_restricted_data_token; end

  def access_token
    'oaisdhgoajsdfoahgasd'
  end

  def role_credentials
    OpenStruct.new({})
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
      c.access_key = ENV['AMZ_ACCESS_KEY_ID'] || 'ACCESS_KEY'
      c.secret_key = ENV['AMZ_SECRET_ACCESS_KEY'] || 'SECRET_KEY'
      c.role_arn = ENV['AMZ_ROLE_ARN'] || 'arn:aws:iam::*'

      c.client_id = ENV['AMZ_CLIENT_ID'] || 'CLIENT_ID'
      c.client_secret = ENV['AMZ_CLIENT_SECRET'] || 'CLIENT_SECRET'

      c.sandbox_env!
      c.logger = Logger.new($stdout)
      c.logger.level = Logger::DEBUG
      c.debugging = true
    end
  end

  describe 'restricted access resources' do
    context 'success path' do
      it 'returns success response with PII data' do
        stub_request(:post, 'https://sts.amazonaws.com/').to_return(
          status: 200,
          body: fixture('sts_200_response.xml'),
        )

        stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(
          status: 200,
          body: fixture('token_success.json'),
        )
        stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders/113-1435144-7135426/address',
        ).to_return(status: 200, body: '{"payload": {}}', headers: {})
        orders_api =
          AmazonSpClients::SpOrdersV0::OrdersV0Api.new(NullSession.new)
        addr_resp =
          orders_api.get_order_address(
            '113-1435144-7135426',
            auth_names: [:pii],
          )
        expect(addr_resp.payload).not_to be_nil
      end
    end
  end

  describe 'complete flow test' do
    context 'success path' do
      it 'returns success responses' do
        stub_request(:post, 'https://sts.amazonaws.com/').to_return(
          status: 200,
          body: fixture('sts_200_response.xml'),
        )

        stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(
          status: 200,
          body: fixture('token_success.json'),
        )

        stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders?CreatedAfter=TEST_CASE_200&MarketplaceIds=ATVPDKIKX0DER',
        ).to_return(status: 200, body: fixture('orders_200_response.json'))

        refresh_token = ENV['AMZ_REFRESH_TOKEN'] || 'REFRESH_TOKEN'

        session, err = AmazonSpClients.new_session(refresh_token)
        orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new(session)
        get_orders_response =
          orders_api.get_orders(
            ['ATVPDKIKX0DER'],
            created_after: 'TEST_CASE_200',
          )

        expect(err).to be_nil
        expect(get_orders_response).to be_instance_of(
          AmazonSpClients::ApiResponse,
        )
        expect(get_orders_response.payload).to be_a(Hash)
        expect(get_orders_response.payload[:Orders].first).to be_a(Hash)
        expect(get_orders_response.payload[:Orders].count).to eq 1
        expect(get_orders_response.errors).to be_nil

        expect(get_orders_response.original_response.status).to eq 200
      end
    end

    context 'with sts error' do
      it 'session never runs and returns error' do
        stub_request(:post, 'https://sts.amazonaws.com/').to_return(
          status: 403,
          body: fixture('sts_403_response.xml'),
        )

        refresh_token = ENV['AMZ_REFRESH_TOKEN'] || 'REFRESH_TOKEN'

        expect {
          AmazonSpClients.new_session(refresh_token)
        }.to raise_error AmazonSpClients::ServiceError
      end
    end

    context 'with token error' do
      it 'session never runs and returns error' do
        stub_request(:post, 'https://sts.amazonaws.com/').to_return(
          status: 200,
          body: fixture('sts_200_response.xml'),
        )

        stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(
          status: 400,
          body: fixture('token_error.json'),
        )

        refresh_token = ENV['AMZ_REFRESH_TOKEN'] || 'REFRESH_TOKEN'


        expect {
          AmazonSpClients.new_session(refresh_token)
        }.to raise_error AmazonSpClients::ServiceError
      end
    end

    # describe 'middlewares' do
    #   it 'allows hooking into request/response env' do
    #     stub_request(:post, 'https://sts.amazonaws.com/').to_return(
    #       status: 200,
    #       body: fixture('sts_200_response.xml'),
    #     )
    #     stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(
    #       status: 200,
    #       body: fixture('token_success.json'),
    #     )
    #     stub_request(
    #       :get,
    #       'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders?CreatedAfter=TEST_CASE_200&MarketplaceIds=ATVPDKIKX0DER',
    #     ).to_return(status: 200, body: fixture('orders_200_response.json'))

    #     method = nil
    #     api_call_opts = nil
    #     status = nil
    #     AmazonSpClients.on_response do |env|
    #       method = env[:method]
    #       api_call_opts = env[:api_call_opts]
    #       status = env[:status]
    #     end

    #     refresh_token = ENV['AMZ_REFRESH_TOKEN'] || 'REFRESH_TOKEN'

    #     session, _ = AmazonSpClients.new_session(refresh_token)
    #     orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new(session)
    #     get_orders_response =
    #       orders_api.get_orders(
    #         ['ATVPDKIKX0DER'],
    #         created_after: 'TEST_CASE_200',
    #       )

    #     expect(method).to eq :get
    #     expect(status).to eq 200
    #     expect(
    #       api_call_opts[:query_params][:CreatedAfter],
    #     ).to eq 'TEST_CASE_200'
    #   end
    # end

    context 'error api response' do
      it 'returns error response' do
        stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders?CreatedAfter=TEST_CASE_400&MarketplaceIds=ATVPDKIKX0DER',
        ).to_return(
          status: 400,
          body:
            '{"errors":[{"code":"InvalidInput","message":"Invalid Input"}]}',
          headers: {
            'Date' => 'Wed, 09 Jun 2021 09:16:55 GMT',
            'Content-Type' => 'application/json',
            'Content-Length' => '62',
            'Connection' => 'keep-alive',
            'x-amzn-RequestId' => '3b9f0d8b-0b92-4582-8152-a5c56b5c998d',
            'x-amz-apigw-id' => 'ApoJKGnsIAMF7Xw=',
            'X-Amzn-Trace-Id' =>
              'Root=1-60c08707-4aade6f26fc77d032b0ccefe;Sampled=0',
          },
        )

        orders_api =
          AmazonSpClients::SpOrdersV0::OrdersV0Api.new(NullSession.new)
        get_orders_response =
          orders_api.get_orders(
            ['ATVPDKIKX0DER'],
            created_after: 'TEST_CASE_400',
          )

        expect(get_orders_response.errors).not_to be_nil
        expect(get_orders_response.payload).to be_nil
        expect(get_orders_response.errors).to be_instance_of(
          AmazonSpClients::ApiError,
        )
        expect(get_orders_response.errors.full_messages).to eq(
          'InvalidInput: Invalid Input',
        )

        expect(get_orders_response.original_response.status).to eq 400
      end
    end
  end
end
