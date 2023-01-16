require 'spec_helper'
require 'webmock/rspec'
require 'logger'
require 'dotenv/load'
require 'timecop'
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

  def role_credentials
    Aws::Credentials.new('access_key_id', 'secret_access_key', 'session_token')
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
    end
  end

  after do
    AmazonSpClients.configure do |c|
      c.set_endpoint_by_marketplace_id('ATVPDKIKX0DER')
    end
  end

  describe 'restricted access resources' do
    context 'success path' do
      it 'returns success response with PII data' do
        stub_request(:post, 'https://sts.us-east-1.amazonaws.com/').to_return(
          status: 200,
          body: fixture('sts_200_response.xml'),
        )

        stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(
          status: 200,
          body: fixture('token_success.json'),
        )

        stub_request(
            :post,
            'https://sandbox.sellingpartnerapi-na.amazon.com/tokens/2021-03-01/restrictedDataToken',
          )
          .with(
            body:
              "{\"restrictedResources\":[{\"method\":\"GET\",\"path\":\"/orders/v0/orders\",\"dataElements\":[\"buyerInfo\",\"shippingAddress\"]}]}",
          )
          .to_return(
            status: 200,
            body: '{"payload":{"restrictedDataToken":"RESTRICTED_TOKEN","expiresIn":3600}}',
          )

        stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders/marketplace_id',
        ).to_return(status: 200, body: '{"payload":{}}', headers: { 'x-amzn-RateLimit-Limit' => '0.2' })

        refresh_token = ENV['AMZ_REFRESH_TOKEN'] || 'REFRESH_TOKEN'
        session = AmazonSpClients.new_session(refresh_token)

        orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new(session)
        order_resp = orders_api.get_order('marketplace_id', auth_names: [:orders])

        expect(order_resp.payload).not_to be_nil
        expect(order_resp.reported_rate_limit).to eq(0.2)
        expect(session.restricted_data_token).to be_a(Hash)
        expect(session.restricted_data_token[:orders]).to eq('RESTRICTED_TOKEN')
      end
    end
  end

  describe 'complete flow test' do
    context 'success path' do
      it 'returns success responses' do
        stub_request(:post, 'https://sts.us-east-1.amazonaws.com/').to_return(
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
        stub_request(:post, 'https://sts.eu-west-1.amazonaws.com/').to_return(
          status: 200,
          body: fixture('sts_200_response.xml'),
        )

        stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(
          status: 200,
          body: fixture('token_success.json'),
        )

        stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-eu.amazon.com/orders/v0/orders?CreatedAfter=TEST_CASE_200&MarketplaceIds=ATVPDKIKX0DER',
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

    context 'with sts error' do
      it 'session never runs and returns error' do
        stub_request(:post, 'https://sts.us-east-1.amazonaws.com/').to_return(
          status: 403,
          body: fixture('sts_403_response.xml'),
        )

        refresh_token = ENV['AMZ_REFRESH_TOKEN'] || 'REFRESH_TOKEN'

        expect { AmazonSpClients.new_session(refresh_token) }.to raise_error Faraday::ForbiddenError
      end
    end

    context 'with token error' do
      it 'session never runs and returns error' do
        stub_request(:post, 'https://sts.us-east-1.amazonaws.com/').to_return(
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
        }.to raise_error Faraday::BadRequestError
      end
    end

    context 'error api response' do
      it 'returns error response' do
        stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders?CreatedAfter=TEST_CASE_400&MarketplaceIds=ATVPDKIKX0DER',
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
            'X-Amzn-Trace-Id' => 'Root=1-60c08707-4aade6f26fc77d032b0ccefe;Sampled=0',
          },
        )

        orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new(NullSession.new)

        expect {
          orders_api.get_orders(['ATVPDKIKX0DER'], created_after: 'TEST_CASE_400')
        }.to raise_error Faraday::BadRequestError
      end
    end
  end

  describe 'aws credentials' do
    before do
      Aws.config.update(credentials: Aws::Credentials.new('bogus', 'bogus'), region: 'bogus')
    end

    it 'initializes sts client with correct credentials' do
      stub_request(:post, 'https://sts.us-east-1.amazonaws.com/').to_return(
        status: 200,
        body: fixture('sts_200_response.xml'),
      )

      stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(
        status: 200,
        body: fixture('token_success.json'),
      )

      refresh_token = ENV['AMZ_REFRESH_TOKEN'] || 'REFRESH_TOKEN'
      session = AmazonSpClients.new_session(refresh_token)

      expect(session.role_credentials.client.config.credentials.access_key_id)
        .to eq(AmazonSpClients.configure.access_key)

      expect(session.role_credentials.client.config.credentials.secret_access_key)
        .to eq(AmazonSpClients.configure.secret_key)
    end
  end
end
