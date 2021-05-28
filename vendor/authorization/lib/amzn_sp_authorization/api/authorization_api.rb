=begin
#Selling Partner API for Authorization

#The Selling Partner API for Authorization helps developers manage authorizations and check the specific permissions associated with a given authorization.

OpenAPI spec version: v1

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

module AmznSpAuthorization
  class AuthorizationApi
    attr_accessor :api_client

    def initialize(api_client = ApiClient.default)
      @api_client = api_client
    end
    # Returns the Login with Amazon (LWA) authorization code for an existing Amazon MWS authorization.
    # With the getAuthorizationCode operation, you can request a Login With Amazon (LWA) authorization code that will allow you to call a Selling Partner API on behalf of a seller who has already authorized you to call Amazon Marketplace Web Service (Amazon MWS). You specify a developer ID, an MWS auth token, and a seller ID. Taken together, these represent the Amazon MWS authorization that the seller previously granted you. The operation returns an LWA authorization code that can be exchanged for a refresh token and access token representing authorization to call the Selling Partner API on the seller's behalf. By using this API, sellers who have already authorized you for Amazon MWS do not need to re-authorize you for the Selling Partner API.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 5 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
    # @param selling_partner_id The seller ID of the seller for whom you are requesting Selling Partner API authorization. This must be the seller ID of the seller who authorized your application on the Marketplace Appstore.
    # @param developer_id Your developer ID. This must be one of the developer ID values that you provided when you registered your application in Developer Central.
    # @param mws_auth_token The MWS Auth Token that was generated when the seller authorized your application on the Marketplace Appstore.
    # @param [Hash] opts the optional parameters
    # @return [GetAuthorizationCodeResponse]
    def get_authorization_code(selling_partner_id, developer_id, mws_auth_token, opts = {})
      data, _status_code, _headers = get_authorization_code_with_http_info(selling_partner_id, developer_id, mws_auth_token, opts)
      data
    end

    # Returns the Login with Amazon (LWA) authorization code for an existing Amazon MWS authorization.
    # With the getAuthorizationCode operation, you can request a Login With Amazon (LWA) authorization code that will allow you to call a Selling Partner API on behalf of a seller who has already authorized you to call Amazon Marketplace Web Service (Amazon MWS). You specify a developer ID, an MWS auth token, and a seller ID. Taken together, these represent the Amazon MWS authorization that the seller previously granted you. The operation returns an LWA authorization code that can be exchanged for a refresh token and access token representing authorization to call the Selling Partner API on the seller&#x27;s behalf. By using this API, sellers who have already authorized you for Amazon MWS do not need to re-authorize you for the Selling Partner API.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 5 |  For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
    # @param selling_partner_id The seller ID of the seller for whom you are requesting Selling Partner API authorization. This must be the seller ID of the seller who authorized your application on the Marketplace Appstore.
    # @param developer_id Your developer ID. This must be one of the developer ID values that you provided when you registered your application in Developer Central.
    # @param mws_auth_token The MWS Auth Token that was generated when the seller authorized your application on the Marketplace Appstore.
    # @param [Hash] opts the optional parameters
    # @return [Array<(GetAuthorizationCodeResponse, Integer, Hash)>] GetAuthorizationCodeResponse data, response status code and response headers
    def get_authorization_code_with_http_info(selling_partner_id, developer_id, mws_auth_token, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: AuthorizationApi.get_authorization_code ...'
      end
      # verify the required parameter 'selling_partner_id' is set
      if @api_client.config.client_side_validation && selling_partner_id.nil?
        fail ArgumentError, "Missing the required parameter 'selling_partner_id' when calling AuthorizationApi.get_authorization_code"
      end
      # verify the required parameter 'developer_id' is set
      if @api_client.config.client_side_validation && developer_id.nil?
        fail ArgumentError, "Missing the required parameter 'developer_id' when calling AuthorizationApi.get_authorization_code"
      end
      # verify the required parameter 'mws_auth_token' is set
      if @api_client.config.client_side_validation && mws_auth_token.nil?
        fail ArgumentError, "Missing the required parameter 'mws_auth_token' when calling AuthorizationApi.get_authorization_code"
      end
      # resource path
      local_var_path = '/authorization/v1/authorizationCode'

      # query parameters
      query_params = opts[:query_params] || {}
      query_params[:'sellingPartnerId'] = selling_partner_id
      query_params[:'developerId'] = developer_id
      query_params[:'mwsAuthToken'] = mws_auth_token

      # header parameters
      header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json', 'payload', 'errors'])

      # form parameters
      form_params = opts[:form_params] || {}

      # http body (model)
      post_body = opts[:body] 

      return_type = opts[:return_type] || 'GetAuthorizationCodeResponse' 

      auth_names = opts[:auth_names] || []
      data, status_code, headers = @api_client.call_api(:GET, local_var_path,
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type)

      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: AuthorizationApi#get_authorization_code\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end
  end
end
