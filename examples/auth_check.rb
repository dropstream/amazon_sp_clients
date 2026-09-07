#!/usr/bin/env ruby
# frozen_string_literal: true

# Shows what Amazon needs to authorize an SP-API call. It pulls one order
# through the Orders API with nothing but an LWA access token, then shows
# what a token refresh needs. Read-only: it changes nothing on the seller
# account and stores nothing. Background notes are at the end of the file.
#
# Input comes from environment variables:
#
#   SP_ACCESS_TOKEN    a current access token (Atza|...); needed for check 2
#   SP_MARKETPLACE_ID  default ATVPDKIKX0DER (amazon.com)
#   SP_ENDPOINT        default na; na, eu, fe or a country code such as de
#   SP_REFRESH_TOKEN   optional; enables check 3
#   SP_CLIENT_ID       optional; with SP_CLIENT_SECRET, check 3 performs a real refresh
#   SP_CLIENT_SECRET
#   SP_LOOKBACK_DAYS   default 30; how far back check 2 looks for an order
#   SP_TRANSPORT       gem (default when the gem is loaded) or http
#
# Run it from a shell. It installs the public gem into GEM_HOME and uses it:
#
#   GEM_HOME=/tmp/gems ruby auth_check.rb
#
# Or load it into a Ruby process that already runs under Bundler, such as
# an application console: `load '/path/to/auth_check.rb'`. It then uses
# the gem when that bundle has it, and otherwise Ruby's Net::HTTP with the
# same URL and headers. Tokens are never printed, only a prefix and a length.

# Under Bundler the bundle is fixed and bundler/inline would fight it.
if defined?(Bundler) && ENV.key?('BUNDLE_GEMFILE')
  begin
    require 'amazon_sp_clients/v2'
  rescue LoadError
    # Not in this bundle. Net::HTTP takes over below.
  end
else
  require 'bundler/inline'

  gemfile do
    source 'https://rubygems.org'
    gem 'sp_api_clients', '~> 2.0', require: 'amazon_sp_clients/v2'
  end
end

require 'json'
require 'net/http'
require 'time'
require 'uri'

module AuthCheck
  # SP-API host per endpoint code: a region or a country.
  HOSTS = {
    %w[na br ca mx us] => 'sellingpartnerapi-na.amazon.com',
    %w[eu ae de eg es fr gb in it nl pl sa se tr] => 'sellingpartnerapi-eu.amazon.com',
    %w[fe au jp sg] => 'sellingpartnerapi-fe.amazon.com'
  }.freeze
  DEFAULT_ENDPOINT = 'na'
  # amazon.com
  DEFAULT_MARKETPLACE_ID = 'ATVPDKIKX0DER'
  # Shaped like a token so Amazon rejects it for its value, not its format.
  BOGUS_TOKEN = 'Atza|this-token-is-not-valid'
  LWA_TOKEN_URL = URI('https://api.amazon.com/auth/o2/token')
  ORDERS_PATH = '/orders/v0/orders'
  DEFAULT_LOOKBACK_DAYS = 30
  SECONDS_PER_DAY = 24 * 60 * 60
  # Enough of a token to recognise it, never enough to use it.
  PREFIX_LENGTH = 5

  # The headers gem 2.0.0 puts on every request. No signature among them.
  ACCESS_TOKEN_HEADER = 'x-amz-access-token'
  DATE_HEADER = 'x-amz-date'
  DATE_FORMAT = '%Y%m%dT%H%M%SZ'
  JSON_TYPE = 'application/json'
  USER_AGENT = "sp_api_clients/2.0.0 auth_check (Language=Ruby/#{RUBY_VERSION})".freeze
  RATE_LIMIT_HEADER = 'x-amzn-RateLimit-Limit'
  REQUEST_ID_HEADER = 'x-amzn-RequestId'
  HTTP_OK = 200

  EXIT_PASS = 0
  EXIT_FAIL = 1
  EXIT_SKIPPED = 2

  Orders = Struct.new(:status, :code, :message, :orders, :rate_limit, :request_id,
                      keyword_init: true) do
    def ok? = status == HTTP_OK
  end

  Exchange = Struct.new(:status, :access_token, :expires_in, :error, :description,
                        keyword_init: true) do
    def ok? = status == HTTP_OK
  end

  # Plain Net::HTTP with the gem's request shape. Used when the gem is
  # not available in the running process.
  module HttpTransport
    module_function

    def name = 'Net::HTTP, same URL and headers as gem 2.0.0'

    def orders(token, endpoint, marketplace_id, created_after)
      uri = URI("https://#{AuthCheck.host_for(endpoint)}#{ORDERS_PATH}")
      uri.query = URI.encode_www_form(MarketplaceIds: marketplace_id, CreatedAfter: created_after,
                                      MaxResultsPerPage: 1)
      request = Net::HTTP::Get.new(uri)
      headers(token).each { |name, value| request[name] = value }
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
      body = AuthCheck.parse_json(response.body)

      Orders.new(status: response.code.to_i, code: body.dig('errors', 0, 'code'),
                 message: body.dig('errors', 0, 'message'),
                 orders: body.dig('payload', 'Orders') || [],
                 rate_limit: response[RATE_LIMIT_HEADER], request_id: response[REQUEST_ID_HEADER])
    end

    def exchange(refresh_token, client_id, client_secret)
      form = { 'grant_type' => 'refresh_token', 'refresh_token' => refresh_token }
      form['client_id'] = client_id unless AuthCheck.blank?(client_id)
      form['client_secret'] = client_secret unless AuthCheck.blank?(client_secret)
      response = Net::HTTP.post_form(LWA_TOKEN_URL, form)
      body = AuthCheck.parse_json(response.body)

      Exchange.new(status: response.code.to_i, access_token: body['access_token'],
                   expires_in: body['expires_in'], error: body['error'],
                   description: body['error_description'])
    end

    def headers(token)
      { ACCESS_TOKEN_HEADER => token, DATE_HEADER => Time.now.utc.strftime(DATE_FORMAT),
        'User-Agent' => USER_AGENT, 'Content-Type' => JSON_TYPE, 'Accept' => JSON_TYPE }
    end
  end

  # The gem itself, when it is loaded.
  module GemTransport
    module_function

    def name = "sp_api_clients #{AmazonSpClients::VERSION} (AmazonSpClients::V2)"

    def orders(token, endpoint, marketplace_id, created_after)
      config = AmazonSpClients::V2::Config.new(endpoint: endpoint)
      client = AmazonSpClients::V2::Client.new(config) { token }
      response = client.orders_v0.get_orders([marketplace_id], created_after: created_after,
                                                               max_results_per_page: 1)
      # String keys, like the raw body the other transport sees.
      payload = JSON.parse(JSON.generate(response.payload))

      Orders.new(status: HTTP_OK, orders: payload['Orders'] || [],
                 rate_limit: response.reported_rate_limit,
                 request_id: response.response.headers[REQUEST_ID_HEADER])
    rescue AmazonSpClients::V2::ResponseError => e
      Orders.new(status: e.status, code: e.code, message: e.errors.first&.message, orders: [],
                 rate_limit: e.rate_limit, request_id: e.request_id)
    end

    def exchange(refresh_token, client_id, client_secret)
      config = AmazonSpClients::V2::Config.new(client_id: client_id.to_s,
                                               client_secret: client_secret.to_s)
      token = AmazonSpClients::V2::LWA.new(config).exchange(refresh_token: refresh_token)

      Exchange.new(status: HTTP_OK, access_token: token.access_token, expires_in: token.expires_in)
    rescue AmazonSpClients::V2::AuthError => e
      Exchange.new(status: e.status, error: e.code, description: e.description)
    end
  end

  module_function

  # @return [Integer] an exit code: 0 pass, 1 fail, 2 check 2 skipped
  def run
    unless host_for(endpoint)
      say "FAIL: unknown endpoint code #{endpoint.inspect}; expected na, eu, fe or a country code."
      return EXIT_FAIL
    end

    environment
    control
    passed = real_token
    refresh
    loaded_libraries

    exit_code(passed)
  end

  def environment
    section 'Environment'
    say "Ruby #{RUBY_VERSION}, transport: #{transport.name}"
    say "endpoint #{endpoint} (#{host_for(endpoint)}), marketplace #{marketplace_id}"
    file = ENV.fetch('AWS_WEB_IDENTITY_TOKEN_FILE', nil)
    if file
      size = File.exist?(file) ? "#{File.size(file)} bytes" : 'file missing'
      say "AWS_WEB_IDENTITY_TOKEN_FILE is set (#{size}). This script never reads it."
    else
      say 'AWS_WEB_IDENTITY_TOKEN_FILE is not set. Not needed.'
    end
    say "AWS_ROLE_ARN is #{ENV.key?('AWS_ROLE_ARN') ? 'set' : 'not set'}. Not needed."
  end

  # A request that reaches Amazon with a token Amazon cannot know.
  def control
    section 'Check 1: a made-up access token, no signature'
    result = fetch_orders(BOGUS_TOKEN)
    if result.ok?
      say 'FAIL: Amazon accepted a made-up token. Something is wrong with this check.'
    else
      say "PASS: Amazon answered #{result.status} #{result.code}: #{result.message}"
      say 'Meaning: the request reached Amazon and was rejected because of the token alone.'
    end
  rescue StandardError => e
    say "FAIL: #{e.class}: #{e.message}"
  end

  # The same request with a real access token. This is exactly what gem
  # 2.0.0 sends: no AWS signature.
  def real_token
    section 'Check 2: your access token, no signature, one order'
    token = ENV.fetch('SP_ACCESS_TOKEN', nil)
    if blank?(token)
      say 'SKIP: SP_ACCESS_TOKEN is not set.'
      return nil
    end

    say "token #{describe(token)}"
    result = fetch_orders(token)
    if result.ok?
      report_orders(result)
      say 'Meaning: the LWA access token is the only credential Amazon needs. ' \
          'Gem 2.0.0 works as it is, for v1 and for V2.'
      true
    else
      say "FAIL: Amazon answered #{result.status} #{result.code}: #{result.message} " \
          "(request id #{result.request_id})"
      say 'Meaning: with code Unauthorized the token is expired or revoked. ' \
          'Copy a fresh one and run again.'
      false
    end
  rescue StandardError => e
    say "FAIL: #{e.class}: #{e.message}"
    false
  end

  # Where new access tokens come from.
  def refresh
    section 'Check 3: what a token refresh needs (nothing is stored)'
    refresh_token = ENV.fetch('SP_REFRESH_TOKEN', nil)
    if blank?(refresh_token)
      say 'SKIP: SP_REFRESH_TOKEN is not set.'
      return
    end

    client_id = ENV.fetch('SP_CLIENT_ID', nil)
    client_secret = ENV.fetch('SP_CLIENT_SECRET', nil)
    if blank?(client_id) || blank?(client_secret)
      refresh_without_app(refresh_token)
    else
      refresh_with_app(refresh_token, client_id, client_secret)
    end
  rescue StandardError => e
    say "FAIL: #{e.class}: #{e.message}"
  end

  # Ask LWA the way a process without app credentials would have to.
  def refresh_without_app(refresh_token)
    say 'SP_CLIENT_ID and SP_CLIENT_SECRET are not set. Asking LWA with the refresh token only.'
    result = transport.exchange(refresh_token, nil, nil)
    say "Amazon answered #{result.status} #{result.error}: #{result.description}"
    say 'Meaning: a refresh token alone cannot produce an access token. Whatever ' \
        'renews the stored tokens every hour holds the client id and the client secret.'
  end

  def refresh_with_app(refresh_token, client_id, client_secret)
    result = transport.exchange(refresh_token, client_id, client_secret)
    unless result.ok?
      say "FAIL: LWA answered #{result.status} #{result.error}: #{result.description}"
      return
    end

    say "PASS: LWA issued a new access token (#{describe(result.access_token)}), " \
        "valid #{result.expires_in} s. Existing tokens stay valid too."
    orders = fetch_orders(result.access_token)
    if orders.ok?
      say "PASS: the new token fetched orders: HTTP 200, #{orders.orders.size} order(s)"
    else
      say "FAIL: the new token was refused: #{orders.status} #{orders.code}: #{orders.message}"
    end
    say 'Meaning: refresh token plus client id plus client secret is the whole chain. ' \
        'No AWS credential took part.'
  end

  def loaded_libraries
    section 'Loaded libraries'
    aws = $LOADED_FEATURES.grep(/aws-sdk|aws-sigv4|aws_sigv4/)
    if aws.empty?
      say 'No AWS library was loaded during these checks.'
    else
      say "AWS libraries are loaded in this process (#{aws.size} files). " \
          'These checks did not use them.'
    end
  end

  def report_orders(result)
    say "PASS: HTTP 200, #{result.orders.size} order(s) in the first page of the last " \
        "#{lookback_days} days, rate limit #{result.rate_limit.inspect} per second"
    first = result.orders.first
    return unless first

    say "first order: #{first['AmazonOrderId']} #{first['OrderStatus']} #{first['PurchaseDate']}"
  end

  def fetch_orders(token)
    transport.orders(token, endpoint, marketplace_id, created_after)
  end

  def transport
    return HttpTransport if ENV.fetch('SP_TRANSPORT', nil) == 'http'
    return HttpTransport unless defined?(::AmazonSpClients::V2)

    GemTransport
  end

  def host_for(endpoint)
    HOSTS.find { |codes, _host| codes.include?(endpoint.to_s) }&.last
  end

  def endpoint = ENV.fetch('SP_ENDPOINT', DEFAULT_ENDPOINT)
  def marketplace_id = ENV.fetch('SP_MARKETPLACE_ID', DEFAULT_MARKETPLACE_ID)
  def lookback_days = ENV.fetch('SP_LOOKBACK_DAYS', DEFAULT_LOOKBACK_DAYS).to_i
  def created_after = (Time.now.utc - (lookback_days * SECONDS_PER_DAY)).iso8601
  def blank?(value) = value.nil? || value.to_s.empty?
  def describe(token) = "#{token[0, PREFIX_LENGTH]}... (#{token.length} characters)"

  def parse_json(body)
    parsed = JSON.parse(body.to_s)
    parsed.is_a?(Hash) ? parsed : {}
  rescue JSON::ParserError
    {}
  end

  def exit_code(passed)
    case passed
    when true then EXIT_PASS
    when false then EXIT_FAIL
    else EXIT_SKIPPED
    end
  end

  def section(title)
    puts
    puts "== #{title}"
  end

  def say(text)
    puts "   #{text}"
  end
end

code = AuthCheck.run
# Loaded into a console, the script must not end the console.
exit(code) if $PROGRAM_NAME == __FILE__

# Background, in plain words
#
# Two separate identity systems are involved.
#
# 1. AWS IAM. A pod's web identity token (AWS_WEB_IDENTITY_TOKEN_FILE)
#    lets it assume an AWS role. Older SP-API clients used such a role to
#    sign every request with AWS Signature Version 4. Since 2 October
#    2023 Amazon ignores that signature: "For requests with AWS Signature
#    Version 4, we'll disregard the signature and proceed with LWA
#    authorization." (developer-docs.amazon.com, changelog "SP-API no
#    longer requires AWS IAM or AWS Signature Version 4"). Gem 2.0.0
#    sends no signature, on the v1 classes and on V2 alike.
#
# 2. Login with Amazon (LWA), OAuth 2.0. A seller authorizes your
#    application once and you receive a refresh token (Atzr|...). Every
#    hour you trade it for an access token (Atza|...) by sending the
#    refresh token together with your application's client id and client
#    secret to api.amazon.com. The access token goes on every request in
#    the x-amz-access-token header. This is the only thing Amazon checks.
#
# Consequences:
#
# - A process that only calls Amazon needs only a current access token.
#   It never needed the client id or secret, and gem 2.0.0 keeps it so.
# - Some process in your system must hold the client id and secret, or
#   every store would stop working one hour after connecting. Find the
#   process that renews stored access tokens; that is where they are.
# - An AWS role may still be needed for S3, SQS and other AWS services.
#   Not for Amazon SP-API.
