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

# in active_fulfillment
require 'amazon_sp_clients/sp_fba_inventory' # FBA Inventory API
# ...and others
```

Generally the you should look for files with `sp_` prefix inside `lib` dir.

### Faraday

The gem works with Faraday 1.10 and Faraday 2; CI runs the suite
against both.

When you move an app from Faraday 1 to Faraday 2, run:

```sh
bundle update faraday faraday-httpclient faraday-retry
```

A plain `bundle install` after changing the `faraday` pin is not
enough. The lock keeps `faraday-httpclient` 1.x, which cannot load
under Faraday 2 (it has no runtime dependency on faraday, so nothing
forces the 2.x adapter). The gem detects this pair at boot and raises
a `LoadError` with the command above.

## Usage Example

```ruby
require 'amazon_sp_clients/sp_orders_v0'
require 'dotenv/load'

AmazonSpClients.configure do |c|
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

The AWS IAM settings (`access_key`, `secret_key`, `role_arn`,
`credentials_provider`) are deprecated. Amazon dropped the SigV4
signing requirement in October 2023, so the gem no longer signs
requests or calls STS. The setters still exist but do nothing. They
stay until the v1 API itself is removed in a later major.

### Restricted operations (requesting PII data)

```ruby
orders_api = AmazonSpClients::SpOrdersV0::OrdersV0Api.new(session)
addr_resp =
  orders_api.get_order_address('113-1435144-7135426', auth_names: [:pii])
```

## V2 client

`AmazonSpClients::V2` is the second-generation client. It fixes the v1
design flaws: no global config, a thread-safe token source, restricted
data tokens as a plain argument, and typed errors. v1 stays in the gem,
so you can migrate one class at a time.

```ruby
require 'amazon_sp_clients/v2'

config = AmazonSpClients::V2::Config.new(
  endpoint: 'na',      # 'na', 'eu', 'fe' or a country code such as 'de'
  sandbox: false,
  timeout: 60,         # read/write seconds; open_timeout: 10
  client_id: nil,      # LWA app credentials; only refresh-token clients and LWA need them
  client_secret: nil
)

# The block runs before every request and returns the current access token.
client = AmazonSpClients::V2::Client.new(config) { store.access_token }

# Or let the client exchange a refresh token itself (needs client_id and client_secret).
client = AmazonSpClients::V2::Client.with_refresh_token(config, refresh_token)

orders = client.orders_v0.get_orders(['ATVPDKIKX0DER'], created_after: '2026-09-01T00:00:00Z')
orders.payload[:Orders]       # symbol keys, as in v1
orders.payload[:NextToken]
orders.reported_rate_limit    # Float from x-amzn-RateLimit-Limit, or nil
```

One client per merchant. It owns one connection and is safe to share
across threads. Required parameters are positional, in the same order
as v1; optional ones are keywords. Unknown keywords raise
`ArgumentError` (v1 ignored them), so pass only the parameters the
operation has.

### Restricted data tokens

Operations that return PII take `rdt:`, a list of restricted resources.
The client fetches the token, caches it until it expires, and sends it
instead of the access token.

```ruby
rdt = AmazonSpClients::V2::RDT
client.orders_v0.get_orders(ids, created_after: since, rdt: rdt::ORDERS_AND_ITEMS)

path = "/reports/2021-06-30/documents/#{doc_id}"
client.reports_2021.get_report_document(doc_id, rdt: [rdt.resource('GET', path)])
```

### Errors

Every failure is an `AmazonSpClients::V2::Error`. Match on the class
and on `code`, never on the message.

| Class | When |
|---|---|
| `ThrottledError` | 429. Not a `ClientError`, so rescuing `ClientError` does not swallow it. |
| `UnauthorizedError`, `ForbiddenError` | 401, 403 |
| `NotFoundError` | 404 |
| `BadRequestError`, `ClientError` | 400, other 4xx. `code` holds the SP-API error code, e.g. `InvalidInput`. |
| `ServerError` | 5xx |
| `InvalidGrantError`, `InvalidClientError`, `AuthError` | LWA rejected the token request; `code` is `invalid_grant`, `invalid_client`, ... |
| `TimeoutError`, `ConnectionError` | no usable response; the original exception is `cause` |
| `ParseError` | a 2xx body that is not JSON |
| `DocumentError` | a presigned S3 upload or download failed |

Rescue subclasses before parents. Every error carries `status`,
`request_id`, `request` and `response`, with secrets redacted.

### Feed and report documents

```ruby
client.upload_feed_document(feed_document_payload, 'text/xml; charset=UTF-8', body)
client.download_feed_result(feed_document_payload)       # Hash with string keys
client.download_report_document(report_document_payload) # String, gunzipped when needed
```

### Migrating from v1

| v1 | V2 |
|---|---|
| `AmazonSpClients.configure` block | `Config.new(endpoint: ...)`, one per merchant |
| `AmazonSpClients.new_callback_session { token }` | `Client.new(config) { token }` |
| `AmazonSpClients.new_session(refresh_token)` | `Client.with_refresh_token(config, refresh_token)` |
| `TokenExchangeAuth.new(refresh_token).exchange` | `LWA.new(config).exchange(refresh_token: refresh_token)` |
| `response[:access_token]` | `token.access_token`, `token.expires_in`, `token.expires_at` |
| `SpOrdersV0::OrdersV0Api.new(session)` | `client.orders_v0` |
| `get_orders(ids, opts)` with an options Hash | `get_orders(ids, **opts)` with real parameter names only |
| `auth_names: [:orders_and_items]` | `rdt: RDT::ORDERS_AND_ITEMS` |
| `auth_names: [{ method: 'GET', path: path }]` | `rdt: [RDT.resource('GET', path)]` |
| `rescue Faraday::RetriableResponse` | `rescue V2::ThrottledError` |
| `rescue Faraday::ForbiddenError, Faraday::UnauthorizedError` | `rescue V2::ForbiddenError, V2::UnauthorizedError` |
| message starts with `Service 'token'` | `rescue V2::AuthError`, then `e.code` |
| message matches `InvalidInput` | `e.code == 'InvalidInput'` |
| `upload_feed_data`, `download_feed_report`, `download_report_document` | `client.upload_feed_document`, `client.download_feed_result`, `client.download_report_document` (the last one gunzips for you) |

## Code generation

The v1 API classes under `vendor/` and the V2 classes under
`lib/amazon_sp_clients/v2/apis/` are generated by `lib/generator` (plain
Ruby + ERB, no external tools) from Amazon's official
[selling-partner-api-models](https://github.com/amzn/selling-partner-api-models)
specs. The generator clones that repo into `amzn-models/` (gitignored)
and checks out the exact revision pinned in
`selling-partner-api-models.sha`, so generation is reproducible.

```sh
bundle exec rake generate          # regenerate at the pinned revision
bundle exec rake generate:setup    # only clone/sync the spec repo
bundle exec rake generate:verify   # regenerate and fail on any drift (runs in CI)
bundle exec rake generate:update   # pull latest specs, regenerate, advance the pin
```

Which APIs get generated, and with which template sets (`v1`, `v2`), is
controlled by `codegen-config.yml`. To adopt newer Amazon specs, run
`rake generate:update` and review the diff — the pin file change plus
the regenerated files — in its own PR.

`bundle exec rake yard:verify` fails when a public V2 object has no doc
comment; CI runs it.

Generated files carry a `Generated by: lib/generator` header. Never edit
them by hand; change the generator (or the templates in
`lib/generator/templates/`) and regenerate.
