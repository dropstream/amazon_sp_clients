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

## How this works?

1. SwaggerCodegen command reads JSON specs and uses Mustache templates to generate
   gems (with code samples, documentation). Those gems are put under `vendor` dir,
   each gem has separate dir.
2. All gems are modified to be namespaced under single module (`AmazonSpClients`)
3. Some files are added to allow requiring/initializing generated gems

## TODO

Unlike Java and C# versions this one still doesn't have:

- [] Authentication
- [] Authorization
- [] Throttler support
- [] Request signing (v. 4)
- [] Instrumentation (only basic logging)
- [] PII support

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

TODO: Write usage instructions here
TODO: Write examples here

## Currently enabled APIs

TODO

## Code generation

If you just want to use this gem you don't need to read this section.

If you want to add or remove APIs or make changes in the templates (i.e. make
changes on how the final code in API gems is generated) you need to run code
generator to rebuild some parts of this repo, and release new version of main gem.

1. First, ensure you have **Java** (8+) installed.
2. Follow [SwaggerCodegen](https://github.com/swagger-api/swagger-codegen) installation instructions.
3. Ensure the `swagger-codegen` is working: `swagger-codegen -h`. If not, you can 
   try to create this executable:
   
```bash   
#!/bin/bash
export JAVA_HOME="${JAVA_HOME:-/usr/local/opt/openjdk/libexec/openjdk.jdk/Contents/Home}"
exec "${JAVA_HOME}/bin/java"  -jar "/usr/local/Cellar/swagger-codegen/3.0.25/libexec/swagger-codegen-cli.jar" "$@"
```

4. Run `rake codegen:generate`.
5. Add changes to git and move gem to next version.
