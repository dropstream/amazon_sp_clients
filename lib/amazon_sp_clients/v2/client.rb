# frozen_string_literal: true

require 'json'
require 'faraday'
require 'amazon_sp_clients/adapter_loader'
require 'amazon_sp_clients/api_response'
require 'amazon_sp_clients/v2/config'
require 'amazon_sp_clients/v2/credentials'
require 'amazon_sp_clients/v2/errors'
require 'amazon_sp_clients/v2/error_mapper'
require 'amazon_sp_clients/v2/lwa'
require 'amazon_sp_clients/v2/rdt'
require 'amazon_sp_clients/v2/token'

module AmazonSpClients
  module V2
    # One client per merchant. Owns the connection, the token source and
    # the restricted-token cache, and hands out one instance of each API
    # class. Safe to share across threads.
    #
    #   client = Client.new(config) { store.access_token }
    #   client.orders_v0.get_orders(marketplace_ids, created_after: since)
    class Client
      # Tokens API operation that issues restricted data tokens.
      TOKENS_PATH = '/tokens/2021-03-01/restrictedDataToken'
      # Carries the access token (or the restricted data token).
      ACCESS_TOKEN_HEADER = 'x-amz-access-token'
      # Request timestamp Amazon asks for on every call.
      DATE_HEADER = 'x-amz-date'
      # Format of DATE_HEADER.
      DATE_FORMAT = '%Y%m%dT%H%M%SZ'
      # Request and response media type of every SP-API operation.
      JSON_TYPE = 'application/json'

      # @return [Config]
      attr_reader :config

      # @param config [Config]
      # @param credentials [#access_token, nil] the token source; or pass a block
      # @yieldreturn [String] the current access token (see Credentials::Callback)
      # @raise [ArgumentError] unless exactly one token source is given
      def initialize(config, credentials: nil, &token)
        if credentials.nil? == token.nil?
          raise ArgumentError, 'give credentials: or a block returning the access token'
        end

        @config = config
        @credentials = credentials || Credentials::Callback.new(&token)
        @errors = ErrorMapper.new(:api)
        @api = build_connection
        @rdt = RDT::Cache.new
        @apis = {}
        @apis_mutex = Mutex.new
      end

      # A client that exchanges +refresh_token+ through LWA itself, using
      # the app credentials on +config+.
      #
      # @param config [Config] with client_id and client_secret
      # @param refresh_token [String]
      # @return [Client]
      def self.with_refresh_token(config, refresh_token)
        new(config, credentials: Credentials::RefreshToken.new(LWA.new(config), refresh_token))
      end

      # One instance of each API class per client, so they all share the
      # connection.
      #
      # @param klass [Class] an Api subclass
      # @return [Api]
      def api(klass)
        @apis_mutex.synchronize { @apis[klass] ||= klass.new(self) }
      end

      # Sends one request and returns the parsed response. The generated
      # API classes call this; consumers use them.
      #
      # @param method [Symbol] :get, :post, :put, :patch, :delete
      # @param path [String] request path, already percent-encoded
      # @param query [Hash] query parameters; nil values are left out
      # @param headers [Hash] extra request headers
      # @param body [Hash, Array, String, nil] JSON-encoded unless already a String
      # @param rdt [Array<RDT::Resource>, nil] send a restricted data token for these resources
      # @return [AmazonSpClients::ApiResponse]
      # @raise [Error] a ResponseError subclass on a non-2xx status, ConnectionError or
      #   TimeoutError when no response arrived, ParseError on a non-JSON body
      def request(method, path, query: {}, headers: {}, body: nil, rdt: nil)
        token = rdt ? restricted_token(rdt) : @credentials.access_token
        response = send_request(method, path, query, headers.merge(auth_headers(token)), body)

        ApiResponse.new(parse(response), response)
      end

      private

      def build_connection
        options = { timeout: @config.timeout, open_timeout: @config.open_timeout }
        headers = {
          'User-Agent' => @config.user_agent, 'Content-Type' => JSON_TYPE, 'Accept' => JSON_TYPE
        }

        Faraday.new(url: @config.base_url, request: options, headers: headers) do |conn|
          conn.adapter Faraday::Adapter::HTTPClient
        end
      end

      def auth_headers(token)
        { ACCESS_TOKEN_HEADER => token, DATE_HEADER => Time.now.utc.strftime(DATE_FORMAT) }
      end

      def send_request(method, path, query, headers, body)
        response = @api.run_request(method, path, encode(body), headers) do |req|
          req.params.update(query.compact)
        end

        @errors.check!(response)
      rescue *ErrorMapper::TRANSPORT_ERRORS => e
        raise @errors.transport_error(e, method: method, url: "#{@config.base_url}#{path}")
      end

      def encode(body)
        return body if body.nil? || body.is_a?(String)

        JSON.generate(body)
      end

      def parse(response)
        body = response.body
        return {} if body.nil? || body.empty?

        parsed = JSON.parse(body, symbolize_names: true)
        parsed.is_a?(Hash) ? parsed : { payload: parsed }
      rescue JSON::ParserError => e
        raise ParseError.new("response body is not JSON: #{e.message}", **parse_context(response))
      end

      def parse_context(response)
        {
          status: response.status,
          response: { status: response.status, headers: response.headers, body: response.body }
        }
      end

      # The Tokens API call inside the fetch goes out with the normal
      # access token (no rdt:), so it never comes back to the cache lock
      # that is held around it. Lock order is cache, then credentials.
      def restricted_token(resources)
        @rdt.fetch(resources) { fetch_restricted_token(resources) }
      end

      def fetch_restricted_token(resources)
        body = { restrictedResources: Array(resources).map(&:to_request) }
        response = request(:post, TOKENS_PATH, body: body)
        payload = response.payload
        token = payload[:restrictedDataToken]
        unless token
          raise ParseError.new('token response has no restrictedDataToken',
                               **parse_context(response.response))
        end

        expires_in = payload[:expiresIn]
        Token.new(access_token: token, token_type: nil, expires_in: expires_in,
                  expires_at: expires_in && (Time.now.utc + expires_in), refresh_token: nil)
      end
    end
  end
end
