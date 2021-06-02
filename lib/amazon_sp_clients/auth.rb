# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

module AmazonSpClients
  class Auth
    GRANT_TYPE = ['refresh_token', 'client_credentials'].freeze
    TOKEN_HOST = 'api.amazon.com'

    def initialize(client_id, client_secret, config = Configuration.default)
      @config = config
      @client_id = client_id
      @client_secret = client_secret

      @conn = Faraday.new("https://#{TOKEN_HOST}") do |conn|
        conn.request  :url_encoded
        conn.response :json

        conn.headers = {
          'Content-Type' => 'application/x-www-form-urlencoded;charset=UTF-8'
        }
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
      fail "Invalid grant_type" unless GRANT_TYPE.include?(grant_type)
      if grant_type == 'client_credentials' && scope.nil?
        fail "Grantless operations require scope" 
      end

      params = {
        grant_type: grant_type,
        client_id: @client_id,
        client_secret: @client_secret
      }

      if grant_type == 'refresh_token'
        params[:refresh_token] = @config.refresh_token
      else
        params[:scope] = score
      end

      resp = @conn.post '/auth/o2/token', params

      # TODO: handle error responses
      resp.body
    end
  end
end
