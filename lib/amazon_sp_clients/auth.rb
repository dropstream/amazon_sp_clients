module AmazonSpClients
  class Auth
    attr_accessor :api_client

    def initialize
      @api_client = ApiClient.new(Configuration.new)
      @api_client.config.host = 'api.amazon.com'
    end

    # REQ:
    #
    # POST /auth/o2/token HTTP/l.l
    # Host: api.amazon.com
    # Content-Type: application/x-www-form-urlencoded;charset=UTF-8
    # grant_type=refresh_token
    #   &refresh_token=Aztr|...
    #   &client_id=foodev
    #   &client_secret=Y76SDl2F
    #
    # RESP:
    #
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
    def request_login(grant_type:, refresh_token:, client_id:, client_secret:)
      req =
        @api_client.build_request(
          'POST',
          '/auth/o2/token',
          {
            form_params: grant_type,
            refresh_token: refresh_token,
            client_id: client_id,
            client_secret: client_secret
          }
        )

      req
      # TODO: add headers (https://github.com/amzn/selling-partner-api-docs/blob/main/guides/en-US/developer-guide/SellingPartnerApiDeveloperGuide.md#step-3-add-headers-to-the-uri)
      # TODO: sing request
      # TODO: make a request
    end

    def request_login_grantless
    end
  end
end
