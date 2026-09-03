# frozen_string_literal: true

require 'json'
require 'faraday'
require 'amazon_sp_clients/adapter_loader'
require 'amazon_sp_clients/v2/config'
require 'amazon_sp_clients/v2/errors'
require 'amazon_sp_clients/v2/error_mapper'
require 'amazon_sp_clients/v2/token'

module AmazonSpClients
  module V2
    # Login with Amazon: exchanges a refresh token for an access token.
    #
    #   token = LWA.new(config).exchange(refresh_token: stored_refresh_token)
    #   token.access_token   # => "Atza|..."
    #   token.expires_at     # => Time
    #
    # Needs the app credentials on the config. Consumers that keep their
    # own token store call this directly; RefreshToken credentials call
    # it for the client.
    class LWA
      TOKEN_HOST = 'https://api.amazon.com'
      TOKEN_PATH = '/auth/o2/token'
      REFRESH_GRANT = 'refresh_token'

      # @param config [Config] with client_id and client_secret set
      # @raise [ArgumentError] when the app credentials are missing
      def initialize(config)
        if config.client_id.nil? || config.client_secret.nil?
          raise ArgumentError, 'config needs client_id and client_secret'
        end

        @config = config
        @errors = ErrorMapper.new(:lwa)
        @conn = build_connection
      end

      # @param refresh_token [String]
      # @return [Token]
      # @raise [AuthError] when LWA rejects the grant (e.g. InvalidGrantError)
      # @raise [ConnectionError, ParseError, ServerError]
      def exchange(refresh_token:)
        form = {
          grant_type: REFRESH_GRANT,
          client_id: @config.client_id,
          client_secret: @config.client_secret,
          refresh_token: refresh_token
        }

        build_token(post(form))
      end

      private

      def build_connection
        options = { timeout: @config.timeout, open_timeout: @config.open_timeout }
        headers = { 'User-Agent' => @config.user_agent }

        Faraday.new(url: TOKEN_HOST, request: options, headers: headers) do |conn|
          conn.request :url_encoded
          conn.adapter Faraday::Adapter::HTTPClient
        end
      end

      def post(form)
        response = @conn.post(TOKEN_PATH, form)

        @errors.check!(response)
      rescue *ErrorMapper::TRANSPORT_ERRORS => e
        raise @errors.transport_error(e, method: :post, url: "#{TOKEN_HOST}#{TOKEN_PATH}")
      end

      def build_token(response)
        body = parse(response)
        expires_in = body[:expires_in]

        Token.new(
          access_token: body[:access_token],
          token_type: body[:token_type],
          expires_in: expires_in,
          expires_at: expires_in && (Time.now.utc + expires_in),
          refresh_token: body[:refresh_token]
        )
      end

      def parse(response)
        body = JSON.parse(response.body, symbolize_names: true)
        return body if body.is_a?(Hash) && body[:access_token]

        raise ParseError.new('LWA response has no access_token', **parse_context(response))
      rescue JSON::ParserError => e
        raise ParseError.new("LWA response is not JSON: #{e.message}", **parse_context(response))
      end

      def parse_context(response)
        { status: response.status, response: { status: response.status, body: response.body } }
      end
    end
  end
end
