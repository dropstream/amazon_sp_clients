# AmazonSpClients

**NOTE: this is still WIP**

* [Official Amazon Selling Partner documencation](https://github.com/amzn/selling-partner-api-docs)
* [Self hosted Swagger docs](https://dropstream.github.io/amazon-sp-swagger-api-docs)

## What is this?

At the time of writing there isn't any official Ruby lib for Amazon SP API.
They do however provide OpenAPI json specs for each of their (separate now) APIs.

This gem contains generated gems for selected APIs along code to help
with generating the code and adding new APIs to this gem.

## How does it work?

* SwaggerCodegen command reads JSON specs and uses (customizable) templates to
  generate ruby gem files. Each gem has its own directory inside **vendor** dir.
* All gems are modified to be namespaced under single module (`AmazonSpClients`)
* Some files are added inside `lib` to allow requiring/initializing generated gems

## TODO

Unlike 'semit-official' Java version, generated Ruby code doesn't implement:

- [ ] Authentication
- [ ] Authorization
- [ ] PII support (restricted token auth)
- [ ] Grantless operations
- [ ] Usage plans (+ dynamic plans with `x-amzn-RateLimit-Limit`)
- [ ] Request signing (v. 4)
- [ ] Instrumentation (so far there's only basic logging)
- [x] Sanbox

## Installation

```ruby
gem 'amazon_sp_clients'
```

This will require only the main (root) gem, but won't load any of generated SP APIs.
The idea is to generate code for all APIs we may need across our system, but allow
requiring per project/repo basis. Because of that, each API must be required explicitly:

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

**Q: Why some APIs end with 'v0' or '2021'**

A: Some APIs have just one version but other have more.
It also seems that in some cases Amazon reserves right to add more versions in
near future.

## Usage

### What works?

```ruby
RSpec.describe AmazonSpClients do
  before do
    AmazonSpClients.configure.sandbox_env!
    AmazonSpClients.configure do |c|
      c.marketplace = :us
      c.access_token = 'Azmn|FooBar'
      c.logger = Logger.new($stdout)
      c.logger.level = Logger::DEBUG
      c.debugging = true
    end
  end

  describe 'smoke tests' do
    it 'success response' do
      stub_request(
          :get,
          'https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders/TEST_CASE_200'
        )
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Dropstream/1.0 (Language=Ruby/2.5.8)',
            'X-Amz-Access-Token'=>'Azmn|FooBar',
            'X-Amz-Date'=>'TODO'
          }
        )
        .to_return(status: 200, body: fixture('order_200_response'))

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
      expect(order_model.to_hash[attribute_map[:order_status]]).to eq 'Pending'
    end
  end
end
```

```
AmazonSpClients
  smoke tests
D, [2021-05-31T22:51:22.414809 #54590] DEBUG -- : Calling API: OrdersV0Api.get_order ...
I, [2021-05-31T22:51:22.415016 #54590]  INFO -- request: GET https://sandbox.sellingpartnerapi-na.amazon.com/orders/v0/orders/TEST_CASE_200
I, [2021-05-31T22:51:22.415045 #54590]  INFO -- request: Content-Type: "application/json"
User-Agent: "Dropstream/1.0 (Language=Ruby/2.5.8)"
Accept: "application/json"
I, [2021-05-31T22:51:22.424365 #54590]  INFO -- response: Status 200
I, [2021-05-31T22:51:22.424400 #54590]  INFO -- response:
D, [2021-05-31T22:51:22.424421 #54590] DEBUG -- : HTTP response body ~BEGIN~
{
  "payload": {
    "AmazonOrderId": "902-3159896-1390916",
    "PurchaseDate": "2017-01-20T19:49:35Z",
    "LastUpdateDate": "2017-01-20T19:49:35Z",
    "OrderStatus": "Pending",
    "FulfillmentChannel": "AFN",
    "NumberOfItemsShipped": 0,
    "NumberOfItemsUnshipped": 0,
    "PaymentMethod": "Other",
    "PaymentMethodDetails": [
      "CreditCard",
      "GiftCerificate"
    ],
    "MarketplaceId": "ATVPDKIKX0DER",
    "ShipmentServiceLevelCategory": "Standard",
    "OrderType": "StandardOrder",
    "EarliestShipDate": "2017-01-20T19:51:16Z",
    "LatestShipDate": "2017-01-25T19:49:35Z",
    "IsBusinessOrder": false,
    "IsPrime": false,
    "IsGlobalExpressEnabled": false,
    "IsPremiumOrder": false,
    "IsSoldByAB": false,
    "DefaultShipFromLocationAddress": {
      "Name": "MFNIntegrationTestMerchant",
      "AddressLine1": "2201 WESTLAKE AVE",
      "City": "SEATTLE",
      "StateOrRegion": "WA",
      "PostalCode": "98121-2778",
      "CountryCode": "US",
      "Phone": "+1 480-386-0930 ext. 73824",
      "AddressType": "Commercial"
    },
    "FulfillmentInstruction": {
      "FulfillmentSupplySourceId": "sampleSupplySourceId"
    },
    "IsISPU": false
  }
}

~END~

D, [2021-05-31T22:51:22.424585 #54590] DEBUG -- : API called: OrdersV0Api#get_order
Data: #<AmazonSpClients::SpOrdersV0::GetOrderResponse:0x00007fa297a4a218 @payload={:AmazonOrderId=>"902-3159896-1390916", 
[~~~CUT THE REST~~~], :IsISPU=>false}>
Status code: 200
Headers: {}
```

### General usage example

TODO

### Enabling sandbox mode

[Sandbox Endpoints](https://github.com/amzn/selling-partner-api-docs/blob/main/guides/en-US/developer-guide/SellingPartnerApiDeveloperGuide.md#selling-partner-api-sandbox-endpoints)

This will enable **us-east-1** sandbox endpoints untill you change it back:

```ruby
AmazonSpClients.configure.sandbox_env!
```

Or just set `host` config option yourself.

But we're not done yet. Amazon expects requests to sandbox endpoints to be done
with very specific params. Those params are nowhere to be found in official reference
or any docs: JSON spec is the only place where they are. You have to look for 
`x-amazon-spds-sandbox-behaviors` key. As it's normal for those file to have 3.5k
lines of nested JSON, searching for them is not optimal.

Because of this codegen rake task creates custom `.sandbox_params` file for
"greping" (in root dir). For example, orders_v0 api client has `get_order_items`
method. To find sandbox params for this method do:

```
cat .sandbox_params | grep orders_v0 | grep get_order_items

orders_v0       get_order_items     order_id (orderId):     "TEST_CASE_200"
orders_v0       get_order_items     order_id (orderId):     "TEST_CASE_400"
```

So `order_id` must be `TEST_CASE_200` for success response, or `TEST_CASE_400`
for invalid request.

## Currently Generated APIs

Please check the `vendor` directory.

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
