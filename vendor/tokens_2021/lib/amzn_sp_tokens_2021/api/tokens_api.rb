=begin
#Selling Partner API for Tokens 

#The Selling Partner API for Tokens provides a secure way to access a customers's PII (Personally Identifiable Information). You can call the Tokens API to get a Restricted Data Token (RDT) for one or more restricted resources that you specify. The RDT authorizes you to make subsequent requests to access these restricted resources.

OpenAPI spec version: 2021-03-01

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

module AmznSpTokens2021
  class TokensApi
    attr_accessor :api_client

    def initialize(api_client = ApiClient.default)
      @api_client = api_client
    end
    # Returns a Restricted Data Token (RDT) for one or more restricted resources that you specify. A restricted resource is the HTTP method and path from a restricted operation that returns Personally Identifiable Information (PII). See the Tokens API Use Case Guide for a list of restricted operations. Use the RDT returned here as the access token in subsequent calls to the corresponding restricted operations.  The path of a restricted resource can be: - A specific path containing a seller's order ID, for example ```/orders/v0/orders/902-3159896-1390916/address```. The returned RDT authorizes a subsequent call to the getOrderAddress operation of the Orders API for that specific order only. For example, ```GET /orders/v0/orders/902-3159896-1390916/address```. - A generic path that does not contain a seller's order ID, for example```/orders/v0/orders/{orderId}/address```). The returned RDT authorizes subsequent calls to the getOrderAddress operation for *any* of a seller's order IDs. For example, ```GET /orders/v0/orders/902-3159896-1390916/address``` and ```GET /orders/v0/orders/483-3488972-0896720/address```  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 1 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
    # @param body The restricted data token request details.
    # @param [Hash] opts the optional parameters
    # @return [CreateRestrictedDataTokenResponse]
    def create_restricted_data_token(body, opts = {})
      data, _status_code, _headers = create_restricted_data_token_with_http_info(body, opts)
      data
    end

    # Returns a Restricted Data Token (RDT) for one or more restricted resources that you specify. A restricted resource is the HTTP method and path from a restricted operation that returns Personally Identifiable Information (PII). See the Tokens API Use Case Guide for a list of restricted operations. Use the RDT returned here as the access token in subsequent calls to the corresponding restricted operations.  The path of a restricted resource can be: - A specific path containing a seller&#x27;s order ID, for example &#x60;&#x60;&#x60;/orders/v0/orders/902-3159896-1390916/address&#x60;&#x60;&#x60;. The returned RDT authorizes a subsequent call to the getOrderAddress operation of the Orders API for that specific order only. For example, &#x60;&#x60;&#x60;GET /orders/v0/orders/902-3159896-1390916/address&#x60;&#x60;&#x60;. - A generic path that does not contain a seller&#x27;s order ID, for example&#x60;&#x60;&#x60;/orders/v0/orders/{orderId}/address&#x60;&#x60;&#x60;). The returned RDT authorizes subsequent calls to the getOrderAddress operation for *any* of a seller&#x27;s order IDs. For example, &#x60;&#x60;&#x60;GET /orders/v0/orders/902-3159896-1390916/address&#x60;&#x60;&#x60; and &#x60;&#x60;&#x60;GET /orders/v0/orders/483-3488972-0896720/address&#x60;&#x60;&#x60;  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 1 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
    # @param body The restricted data token request details.
    # @param [Hash] opts the optional parameters
    # @return [Array<(CreateRestrictedDataTokenResponse, Integer, Hash)>] CreateRestrictedDataTokenResponse data, response status code and response headers
    def create_restricted_data_token_with_http_info(body, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: TokensApi.create_restricted_data_token ...'
      end
      # verify the required parameter 'body' is set
      if @api_client.config.client_side_validation && body.nil?
        fail ArgumentError, "Missing the required parameter 'body' when calling TokensApi.create_restricted_data_token"
      end
      # resource path
      local_var_path = '/tokens/2021-03-01/restrictedDataToken'

      # query parameters
      query_params = opts[:query_params] || {}

      # header parameters
      header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json'])
      # HTTP header 'Content-Type'
      header_params['Content-Type'] = @api_client.select_header_content_type(['application/json'])

      # form parameters
      form_params = opts[:form_params] || {}

      # http body (model)
      post_body = opts[:body] || @api_client.object_to_http_body(body) 

      return_type = opts[:return_type] || 'CreateRestrictedDataTokenResponse' 

      auth_names = opts[:auth_names] || []
      data, status_code, headers = @api_client.call_api(:POST, local_var_path,
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type)

      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: TokensApi#create_restricted_data_token\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end
  end
end
