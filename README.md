# sp_api_clients

> **Status: experimental.** This gem is in the middle of large changes:
> a new code generator, a second client (`V2`), and consumers still
> moving over. Interfaces can change between releases. For a maintained,
> complete SP-API client we recommend
> [peddler](https://github.com/lineofflight/peddler).

The gem is `sp_api_clients`. The code keeps the `AmazonSpClients`
namespace and the `amazon_sp_clients/...` require paths. This project
is not affiliated with or endorsed by Amazon.

## Installation

```ruby
gem 'sp_api_clients', '~> 2.0'
```

Releases are on [rubygems.org](https://rubygems.org/gems/sp_api_clients).
A git source (`gem 'sp_api_clients', git: ...`) still works, but it
follows a branch instead of a version. If you keep one, pin a `tag:`.

Either way this requires only the main (root) gem, but won't load any of
the generated SP APIs. The idea is to generate code for all APIs we may
need across our system, but allow requiring per project/repo basis.
Because of that, each API must be required explicitly:

```ruby
require 'amazon_sp_clients' # or 'sp_api_clients'; Bundler.require does this for you

# a project that reads orders
require 'amazon_sp_clients/sp_orders_v0' # Orders API
# ...and others

# a project that reads inventory
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

To read a rotated refresh token back, build the credentials yourself
and keep the reference:

```ruby
lwa = AmazonSpClients::V2::LWA.new(config)
creds = AmazonSpClients::V2::Credentials::RefreshToken.new(lwa, refresh_token)
client = AmazonSpClients::V2::Client.new(config, credentials: creds)
creds.refresh_token   # the latest one LWA returned; persist it when it changes
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
client.reports_2021.get_report_document(doc_id, rdt: rdt.report_document(doc_id))

# Any other restricted resource: method, path template, PII fields wanted.
rdt.resource('GET', '/orders/v0/orders/{orderId}', %w[buyerInfo shippingAddress])
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
| `TokenExchangeAuth.new(refresh_token).exchange` | `LWA.new(config).exchange(refresh_token: refresh_token)`. The config must carry `client_id` and `client_secret`; `LWA.new` raises `ArgumentError` when they are missing, where v1 sent the request and got an LWA error back. |
| `response[:access_token]` | `token.access_token`, `token.expires_in`, `token.expires_at` |
| `SpOrdersV0::OrdersV0Api.new(session)` | `client.orders_v0` |
| `get_orders(ids, opts)` with an options Hash | `get_orders(ids, **opts)` with real parameter names only |
| `auth_names: [:orders_and_items]` | `rdt: RDT::ORDERS_AND_ITEMS` |
| `auth_names: [{ method: 'GET', path: path }]` | `rdt: RDT.report_document(doc_id)` for a report document, `rdt: [RDT.resource('GET', path)]` for anything else |
| `AmazonSpClients.configure.region` | `config.region` |
| `AmazonSpClients.configure.sandbox_env!` / `disable_sandbox!` | `Config.new(sandbox: true)`. The config is frozen, so a client cannot be switched after it is built. |
| `c.logger`, `c.role_arn`, `c.access_key`, `c.secret_key`, `c.credentials_provider` | nothing. v1 has ignored them since 1.8.0; delete the lines, and the AWS credential code that fed them. |
| the `Dropstream/1.0` user agent | `Config.new(user_agent: 'YourApp/1.0 ...')`. The default names this gem; Amazon asks for the application name. |
| `rescue Faraday::RetriableResponse` | `rescue V2::ThrottledError` |
| `rescue Faraday::ForbiddenError, Faraday::UnauthorizedError` | `rescue V2::ForbiddenError, V2::UnauthorizedError`. In v1 these also covered the token endpoint; in V2 those are `AuthError` (see the next row). |
| message starts with `Service 'token'` | `rescue V2::AuthError`, then `e.code`. A token-endpoint 4xx other than 429 is an `AuthError`, 401 and 403 included, so branch on `e.status` if you mapped those to an auth failure. The other three cases are not `AuthError`: 429 is a `ThrottledError`, 5xx is a `ServerError`, and a 200 with no `access_token` is a `ParseError`. |
| `rescue Faraday::ResourceNotFound` | `rescue V2::NotFoundError` |
| `rescue Faraday::BadRequestError, Faraday::ClientError` | `rescue V2::BadRequestError, V2::ClientError` |
| `rescue Faraday::ServerError` | `rescue V2::ServerError, V2::TimeoutError`. Faraday makes a timeout a `ServerError`; V2 makes it a `ConnectionError`, so add it where you treated 5xx as worth retrying. |
| `Faraday::ConnectionFailed`, `Faraday::SSLError` reaching your last `rescue` | `rescue V2::ConnectionError`. v1 let them fall through untyped; V2 wraps every transport failure, `TimeoutError` included, with the original exception as `cause`. |
| `e.message =~ /Please try again/` and other text matches | Match on the class and on `code`. The text changed: `"<status> <code>: <message> (<details>)"` for SP-API, `"<status> <code>: <description>"` for LWA, `"<status> (no body)"` and friends when there is nothing to show. The wording is not a contract. |
| `order_statuses: []` in the options Hash | The same on the wire: `[]` is sent as an empty value (`OrderStatuses=`), a nil keyword is left off. |
| message matches `InvalidInput` | `e.code == 'InvalidInput'` |
| `upload_feed_data`, `download_feed_report`, `download_report_document` | `client.upload_feed_document`, `client.download_feed_result`, `client.download_report_document`. The last one gunzips for you. The first returns nil; v1 returned the S3 response, which nothing read. |

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

## Releasing

A release is a version tag. Nothing else publishes. The `Release`
workflow (`.github/workflows/release.yml`) checks the tag against the
version, runs the suite, builds the gem, pushes it to rubygems.org and
opens a GitHub Release with the CHANGELOG entry.

The push uses rubygems.org's Trusted Publishing: the job's GitHub OIDC
token is exchanged for a short-lived key, so no API key is stored
anywhere. rubygems.org has to trust this repository's workflow first.
Before the first release, sign in to rubygems.org, open the Trusted
publishers page of your profile and add a pending publisher: gem
`sp_api_clients`, repository owner `dropstream`, repository
`amazon_sp_clients` (the repository keeps its old name), workflow
`release.yml`, environment empty. A
pending publisher expires when the first push does not follow soon
(12 hours at the time of writing). After the first release the
publisher belongs to the gem and stays.

1. Write the CHANGELOG entry under a `## [X.Y.Z]` heading. The task
   adds the date.
2. Run the release task. It refuses a dirty tree, a bad version, an
   existing tag or a missing CHANGELOG entry. Then it runs the suite,
   sets `AmazonSpClients::VERSION`, relocks all three lockfiles (or
   CI's frozen install fails), commits `Release X.Y.Z` and creates the
   annotated tag `vX.Y.Z`. Nothing is pushed.

   ```sh
   bundle exec rake 'release:prepare[X.Y.Z]'
   ```

3. Push the branch and the tag. The task prints the exact command:

   ```sh
   git push origin <branch> vX.Y.Z
   ```

The tag must be `v` plus the version, or the workflow stops before it
builds. rubygems.org rejects a version it already has, so a failed
release needs a new version and a new tag, not a re-run. That is why
the task runs the suite before it tags. The bundler `rake release` is
disabled; it would push the gem from a laptop.
