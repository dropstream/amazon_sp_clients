# frozen_string_literal: true

require 'faraday'
# Faraday 2 no longer auto-loads adapter gems; a no-op under Faraday 1.
require 'faraday/httpclient'

module AmazonSpClients
  class AuthResponse < Struct.new(
    :access_token,
    :token_type,
    :expires_in,
    :refresh_token
  )
  end

  class TokenExchangeAuth
    GRANT_TYPE = %w[refresh_token client_credentials].freeze
    TOKEN_HOST = 'api.amazon.com'

    def initialize(refresh_token = nil, config = Configuration.default)
      @refresh_token = refresh_token
      @config = config

      @conn =
        Faraday.new("https://#{TOKEN_HOST}", request: { timeout: @config.timeout }) do |conn|
          conn.use AmazonSpClients::Middlewares::RaiseError, { service: :token }
          conn.adapter Faraday::Adapter::HTTPClient
        end
    end

    # Request login with access token
    # https://github.com/amzn/selling-partner-api-docs/blob/main/guides/en-US/developer-guide/SellingPartnerApiDeveloperGuide.md#step-1-request-a-login-with-amazon-access-token
    #
    # # REQ:
    # POST /auth/o2/token HTTP/l.l
    # Host: api.amazon.com
    # Content-Type: application/x-www-form-urlencoded;charset=UTF-8
    # grant_type=refresh_token
    #   &refresh_token=Aztr|...
    #   &client_id=foodev
    #   &client_secret=Y76SDl2F
    #
    # # RESP:
    # HTTP/l.l 200 OK
    # Content-Type: application/json;charset UTF-8
    # Cache-Control: no-store
    # Pragma:no-cache
    # {
    #   "access_token":"Atza|IQEBLjAsAhRmHjNgHpi0U-Dme37rR6CuUpSREXAMPLE",
    #   "token_type":"bearer",
    #   "expires_in":3600,
    #   "refresh_token":"Atzr|IQEBLzAtAhRPpMJxdwVz2Nn6f2y-tpJX2DeXEXAMPLE"
    # }
    def exchange(grant_type = 'refresh_token', scope = nil)
      raise 'Invalid grant_type' unless GRANT_TYPE.include?(grant_type)
      raise 'Grantless operations require scope' if grant_type == 'client_credentials' && scope.nil?

      params = {
        grant_type: grant_type,
        client_id: @config.client_id,
        client_secret: @config.client_secret
      }

      if grant_type == 'refresh_token'
        params[:refresh_token] = @refresh_token
      else
        params[:scope] = scope
      end

      resp = @conn.post '/auth/o2/token', params

      body = resp.body
      body = JSON.parse(body, symbolize_names: true) if body.is_a?(String)

      AuthResponse.new(
        body[:access_token],
        body[:token_type],
        body[:expires_in],
        body[:refresh_token]
      )
    end
  end
end
