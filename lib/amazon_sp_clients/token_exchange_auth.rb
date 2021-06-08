# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

module AmazonSpClients
  class AuthResponse < Struct.new(
    :access_token,
    :token_type,
    :expires_in,
    :refresh_token,
    :original_response
  )
  end

  class AuthErrorResponse < Struct.new(
    :error,
    :error_description,
    :original_response
  )
  end

  class TokenExchangeAuth
    GRANT_TYPE = %w[refresh_token client_credentials].freeze
    TOKEN_HOST = 'api.amazon.com'

    def initialize(config = Configuration.default)
      @config = config
      @logger = @config.logger
      @debugging = @config.debugging

      @conn =
        Faraday.new("https://#{TOKEN_HOST}") do |conn|
          conn.response :json
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
    def exchange(grant_type, scope = nil)
      raise 'Invalid grant_type' unless GRANT_TYPE.include?(grant_type)
      if grant_type == 'client_credentials' && scope.nil?
        raise 'Grantless operations require scope'
      end

      params = {
        grant_type: grant_type,
        client_id: @config.client_id,
        client_secret: @config.client_secret
      }

      if grant_type == 'refresh_token'
        params[:refresh_token] = @config.refresh_token
      else
        params[:scope] = scope
      end

      resp = @conn.post '/auth/o2/token', params

      body = resp.body
      response_struct = nil

      if resp.success?
        response_struct =
          AuthResponse.new(
            body['access_token'],
            body['token_type'],
            body['expires_in'],
            body['refresh_token'],
            resp
          )
        @logger.debug "#{self.class.name} returned success response"
      else
        response_struct =
          AuthErrorResponse.new(body['error'], body['error_description'], resp)
        @logger.error "#{self.class.name} returned error response (#{
                        resp.status
                      }): #{
                        response_struct.error
                      } - #{response_struct.error_description}"
      end

      if @debugging == true
        @logger.debug "#{self.class.name} response body ~BEGIN~\n#{body}\n~END~\n"
      end

      response_struct
    end
  end
end
