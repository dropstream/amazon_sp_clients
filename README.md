# AmazonSpClients

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

### Client side validation

Client side validation is enabled by default. It will trigger some basic
params validations. For example, if you call 'get_order()', it will fail
with `ArgumentError`, because order_id is required. If you want to check for
params yourself, disable it with setting validations to false:

```ruby
AmazonSpClients.configure.client_side_validations = false
```

### Enabling sandbox mode

[Sandbox Endpoints](https://github.com/amzn/selling-partner-api-docs/blob/main/guides/en-US/developer-guide/SellingPartnerApiDeveloperGuide.md#selling-partner-api-sandbox-endpoints)

This will enable **us-east-1** sandbox endpoints untill you change it back:

```ruby
AmazonSpClients.configure.sandbox_env!
```

Amazon expects requests to sandbox endpoints to be called with very specific params.

So f.i. `order_id` must be `TEST_CASE_200` for success response, or `TEST_CASE_400`
for invalid request (see docs for details).

## Code generation

TL;DR: If you just want to use this gem you don't need to read this section.

If you want to add or remove APIs or make changes in the templates (i.e. make
changes on how the final code in API gems is generated) you need to run code
generator. This will purge and rebuild ALL files inside `vendor`.

To add or remove APIs, edit `codegen-config.yml` file and uncomment required lines.

1. First, ensure you have **Java** (8+) installed.
2. Follow [SwaggerCodegen](https://github.com/swagger-api/swagger-codegen) installation instructions.
3. Ensure the `swagger-codegen` is working: `swagger-codegen -h`.
4. Run `rake codegen:generate`.
5. Add changes to git and move gem to next version.
