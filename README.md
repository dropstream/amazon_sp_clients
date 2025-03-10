# AmazonSpClients

*NOTE*: This is still in development.

## Installation

```ruby
gem 'amazon_sp_clients'
```

This will require only the main (root) gem, but won't load any of the generated
SP APIs. The idea is to generate code for all APIs we may need across our
system, but allow requiring per project/repo basis. Because of that, each API
must be required explicitly:

```ruby
require 'amazon_sp_clients' # you can skip if you use Bundle.setup

# in active_cart
require 'amazon_sp_clients/sp_orders_v0' # Orders API
# ...and others

# in beagle_shipment
require 'amazon_sp_clients/sp_shipping' # Shipping API
# ...and others
```

Generally the you should look for files with `sp_` prefix inside `lib` dir.

## Usage Example

```ruby
require 'amazon_sp_clients/sp_orders_v0'
require 'dotenv/load'

AmazonSpClients.configure do |c|
  c.access_key = ENV['AMZ_ACCESS_KEY_ID']
  c.secret_key = ENV['AMZ_SECRET_ACCESS_KEY']
  c.role_arn = ENV['AMZ_ROLE_ARN']

  c.client_id = ENV['AMZ_CLIENT_ID']
  c.client_secret = ENV['AMZ_CLIENT_SECRET']

  c.sandbox_env!
  c.logger = Logger.new($stdout)
  c.logger.level = Logger::DEBUG
end

session = AmazonSpClients.new_session(refresh_token)

orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new(session)
get_orders_response =
  orders_api.get_orders(['ATVPDKIKX0DER'], created_after: 'TEST_CASE_200')

puts get_orders_response.payload # Hash with symbolized keys
```
### Restricted operations (requesting PII data)

```ruby
orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new(session)
addr_resp =
  orders_api.get_order_address('113-1435144-7135426', auth_names: [:pii])
```

## Code generation

1. First, ensure you have **Java** (8+) installed.
2. Follow [SwaggerCodegen](https://github.com/swagger-api/swagger-codegen) installation instructions.
3. Ensure the `swagger-codegen` is working: `swagger-codegen -h`.
4. Run `rake codegen:generate`.
5. Add changes to git and move gem to next version.
