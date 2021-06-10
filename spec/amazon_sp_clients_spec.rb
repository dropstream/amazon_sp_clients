require 'spec_helper'
require 'webmock/rspec'
require 'logger'
# require 'dotenv/load'
require 'awesome_print'
require 'timecop'

require 'amazon_sp_clients/sp_orders_v0'

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

  describe 'complete flow test' do
    context 'success path' do
      it 'returns success responses' do
        stub_request(:post, 'https://sts.amazonaws.com/')
          .with(
            body: {
              'Action' => 'AssumeRole',
              'DurationSeconds' => '3600',
              'RoleArn' => 'arn:aws:iam::*',
              'RoleSessionName' => 'SPAPISession',
              'Version' => '2011-06-15'
            },
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip,deflate',
              'Authorization' =>
                'AWS4-HMAC-SHA256 Credential=ACCESS_KEY/20180901/us-east-1/sts/aws4_request, SignedHeaders=content-type;host;user-agent;x-amz-content-sha256;x-amz-date, Signature=f9f81b426b4bb926f48a78673990b0e8e60b865935e648b6d7e999caa1b529a1',
              'Content-Type' => 'application/x-www-form-urlencoded',
              'Date' => 'Sat, 01 Sep 2018 10:00:00 GMT',
              'Host' => 'sts.amazonaws.com',
              'User-Agent' => 'Faraday v1.4.2',
              'X-Amz-Content-Sha256' =>
                '2403161606cf7da179415a9c2fd754507930a9ce4cecc7013d1c741a83100672',
              'X-Amz-Date' => '20180901T100000Z'
            }
          )
          .to_return(status: 200, body: fixture('sts_200_response.xml'))

        stub_request(:post, 'https://api.amazon.com/auth/o2/token')
          .with(
            body: {
              'client_id' => 'CLIENT_ID',
              'client_secret' => 'CLIENT_SECRET',
              'grant_type' => 'refresh_token',
              'refresh_token' => 'REFRESH_TOKEN'
            },
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip,deflate',
              'Content-Type' => 'application/x-www-form-urlencoded',
              'Date' => 'Sat, 01 Sep 2018 10:00:00 GMT',
              'User-Agent' => 'Faraday v1.4.2'
            }
          )
          .to_return(status: 200, body: fixture('token_success.json'))

        stub_request(
            :get,
            'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders?CreatedAfter=TEST_CASE_200&MarketplaceIds=ATVPDKIKX0DER'
          )
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip,deflate',
              'Authorization' =>
                'AWS4-HMAC-SHA256 Credential=ASIA2RRSYYBAYP2IUWBN/20180901/us-east-1/execute-api/aws4_request, SignedHeaders=content-type;host;user-agent;x-amz-access-token;x-amz-date;x-amz-security-token, Signature=edafde604d9f93302cc71235b20326d5026526421d131cea6fb1dfde166356a1',
              'Content-Type' => 'application/json',
              'Date' => 'Sat, 01 Sep 2018 10:00:00 GMT',
              'Host' => 'sandbox.sellingpartnerapi-na.amazon.com',
              'User-Agent' => 'Dropstream/1.0 (Language=Ruby/2.5.8)',
              'X-Amz-Access-Token' =>
                'Atza|IQEBLjAsAhRmHjNgHpi0U-Dme37rR6CuUpSREXAMPLE',
              'X-Amz-Date' => '20180901T100000Z',
              'X-Amz-Security-Token' =>
                'FwoGZXIvYXdzEJ7//////////wEaDEnSBETH9jIq5MXPAiKwAa56A52qdVEgL6xwd0bZepceZpgRN8vFQZ+sf2Tk79yrduOL2WO8MMHgu1E4ozj7i+3T/ZR8jQuANx4bJJlaZDJvyADZZq9a5OimzGmz6+y4rD29l2zQhqRhpHHzqTpKrIFCpYkVW+16JxTtHMqkduORCtkXcwfiJL+7BFE5HuRmRdZiGOZOEUjc4clPnHDmAuo1mBD0luVT7B5TO/gs+9cwfbWH7eosYEVco1eNXgCmKLf98oUGMi26OzQUTBr7sirDqTmFhwkXUy1eV/U5DanQSsu96JJ6a1kpmR1r1VG92tLrAsY='
            }
          )
          .to_return(status: 200, body: fixture('orders_200_response.json'))

        sts = AmazonSpClients::Sts.new
        sts_response = sts.assume_role # temp role creds (access and secret key)

        # can be different for evey session/user
        refresh_token = ENV['AMZ_REFRESH_TOKEN'] || 'REFRESH_TOKEN'

        token_auth = AmazonSpClients::TokenExchangeAuth.new(refresh_token)
        token_response = token_auth.exchange

        opts = { sts_response: sts_response, token_response: token_response }
        orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new(opts)

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
  end

  describe 'api smoke test' do
    context 'success api response' do
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

    context 'error api response' do
      it 'returns error response' do
        stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders?CreatedAfter=TEST_CASE_400&MarketplaceIds=ATVPDKIKX0DER'
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
          'InvalidInput: Invalid Input'
        )

        expect(get_orders_response.original_response.status).to eq 400
      end
    end
  end
end
