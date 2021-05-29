# AmazonSpClients

**Warning this is still WIP**

* [Official Amazon Selling Partner documencation](https://github.com/amzn/selling-partner-api-docs)
* [Self hosted Swagger docs](https://dropstream.github.io/amazon-sp-swagger-api-docs)

## What is this?

At the time of writing there isn't any official Ruby lib for Amazon SP API.
They do however provide OpenAPI json specs for each of their (separate now) APIs.
This repo allows choosing which APIs you need, generate them (based on modifiable
template), and use them under one single gem. This repo contains this gem and
everything is needed for code generators.

## How does it work?

1. SwaggerCodegen command reads JSON specs and uses Mustache templates to generate
   gems. Each gem has it's own directory inside **vendor** dir.
2. All gems are modified to be namespaced under single module (`AmazonSpClients`)
3. Some files are added to allow requiring/initializing generated gems

## TODO

Unlike Java and C# versions this one still doesn't have:

- [ ] Authentication
- [ ] Authorization
- [ ] PII support (restricted token auth)
- [ ] Usage plans (+ dynamic plans with `x-amzn-RateLimit-Limit`)
- [ ] Request signing (v. 4)
- [ ] Instrumentation (so far there's only basic logging)
- [x] Sanbox

## Installation

```ruby
gem 'amazon_sp_clients'
```

This doesn't load the SP APIs. It is unlikely that one would need *all* SP gems.
Because of that, each API must be required explicitly:

```ruby
require 'amazon_sp_clients' # <= skip if you are using bundler
require 'amazon_sp_clients/sp_orders_v0' # Orders API
require 'amazon_sp_clients/sp_shipping' # Shipping API
```

**Q: Why some APIs end with 'v0' or '2021'**

A: Some APIs have just one version. Some have two. It seems in some cases Amazon reserves right to add more versions in near future.

## Usage

### Enabling sandbox mode

[Sandbox Endpoints](https://github.com/amzn/selling-partner-api-docs/blob/main/guides/en-US/developer-guide/SellingPartnerApiDeveloperGuide.md#selling-partner-api-sandbox-endpoints)

This will enable **us-east-1** sandbox endpoints untill you change it back:

```ruby
AmazonSpClients.configure.sandbox_env!
```

Or just set `host` config option yourself.

## Currently Generated APIs

Please check the `vendor` directory.

## Code generation

If you just want to use this gem you don't need to read this section.

If you want to add or remove APIs or make changes in the templates (i.e. make
changes on how the final code in API gems is generated) you need to run code
generator to rebuild some parts of this repo, and release new version of main gem.

To add or remove APIs, edit `codegen-config.yml` file and uncomment required lines.

1. First, ensure you have **Java** (8+) installed.
2. Follow [SwaggerCodegen](https://github.com/swagger-api/swagger-codegen) installation instructions.
3. Ensure the `swagger-codegen` is working: `swagger-codegen -h`.
4. Run `rake codegen:generate`.
5. Add changes to git and move gem to next version.
