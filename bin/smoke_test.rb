require 'amazon_sp_clients/sp_orders_v0'
require 'dotenv/load'

AmazonSpClients.configure do |c|
  c.access_key    = ENV['AMZ_ACCESS_KEY_ID']
  c.secret_key    = ENV['AMZ_SECRET_ACCESS_KEY']
  c.role_arn      = ENV['AMZ_ROLE_ARN']

  c.client_id     = ENV['AMZ_CLIENT_ID']
  c.client_secret = ENV['AMZ_CLIENT_SECRET']
  c.refresh_token = ENV['AMZ_REFRESH_TOKEN']

  c.sandbox_env!
  c.logger = Logger.new($stdout)
  c.logger.level = Logger::DEBUG
end

AmazonSpClients.authenticate!
# Calling it second time should reuse tokens
# TODO: find out if asking for new IAM credentials, invalidates the previous ones!
# TODO: this would allow to run requests in parallel from different services
AmazonSpClients.authenticate!

orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new

marketplace_id = AmazonSpClients.configure.marketplace_id

get_orders_response =
  orders_api.get_orders([marketplace_id], created_after: 'TEST_CASE_200')

puts get_orders_response.payload
