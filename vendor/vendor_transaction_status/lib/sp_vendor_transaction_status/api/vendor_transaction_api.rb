=begin
#Selling Partner API for Retail Procurement Transaction Status

#The Selling Partner API for Retail Procurement Transaction Status provides programmatic access to status information on specific asynchronous POST transactions for vendors.

OpenAPI spec version: v1

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

module AmazonSpClients
  module SpVendorTransactionStatus
    class VendorTransactionApi
      attr_accessor :api_client

      def initialize(api_client = ApiClient.default)
        @api_client = api_client
      end
      # Returns the status of the transaction that you specify.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param transaction_id The GUID provided by Amazon in the &#x27;transactionId&#x27; field in response to the post request of a specific transaction.
      # @param [Hash] opts the optional parameters
      # @return [GetTransactionResponse]
      def get_transaction(transaction_id, opts = {})
        data, _status_code, _headers = get_transaction_with_http_info(transaction_id, opts)
        data
      end

      # Returns the status of the transaction that you specify.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param transaction_id The GUID provided by Amazon in the &#x27;transactionId&#x27; field in response to the post request of a specific transaction.
      # @param [Hash] opts the optional parameters
      # @return [Array<(GetTransactionResponse, Integer, Hash)>] GetTransactionResponse data, response status code and response headers
      def get_transaction_with_http_info(transaction_id, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: VendorTransactionApi.get_transaction ...'
        end
        # verify the required parameter 'transaction_id' is set
        if @api_client.config.client_side_validation && transaction_id.nil?
          fail ArgumentError, "Missing the required parameter 'transaction_id' when calling VendorTransactionApi.get_transaction"
        end
        # resource path
        local_var_path = '/vendor/transactions/v1/transactions/{transactionId}'.sub('{' + 'transactionId' + '}', transaction_id.to_s)

        # query parameters
        query_params = opts[:query_params] || {}

        # header parameters
        header_params = opts[:header_params] || {}
        # HTTP header 'Accept' (if needed)
        header_params['Accept'] = @api_client.select_header_accept(['application/json'])

        # form parameters
        form_params = opts[:form_params] || {}

        # http body (model)
        post_body = opts[:body] 

        return_type = opts[:return_type] || 'AmazonSpClients::ApiResponse' 

        auth_names = opts[:auth_names] || []
        data, status_code, headers = @api_client.call_api(:GET, local_var_path,
          :header_params => header_params,
          :query_params => query_params,
          :form_params => form_params,
          :body => post_body,
          :auth_names => auth_names,
          :return_type => return_type)

        if @api_client.config.debugging
          @api_client.config.logger.debug "API called: VendorTransactionApi#get_transaction\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
        end
        return data, status_code, headers
      end
    end
  end
end
