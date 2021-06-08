=begin
#Selling Partner API for Retail Procurement Shipments

#The Selling Partner API for Retail Procurement Shipments provides programmatic access to retail shipping data for vendors.

OpenAPI spec version: v1

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

module AmazonSpClients
  module SpVendorsShipments
    class VendorShippingApi
      attr_accessor :api_client

      def initialize(api_client = ApiClient.default)
        @api_client = api_client
      end
      # Submits one or more shipment confirmations for vendor orders.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [SubmitShipmentConfirmationsResponse]
      def submit_shipment_confirmations(body, opts = {})
        data, _status_code, _headers = submit_shipment_confirmations_with_http_info(body, opts)
        data
      end

      # Submits one or more shipment confirmations for vendor orders.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [Array<(SubmitShipmentConfirmationsResponse, Integer, Hash)>] SubmitShipmentConfirmationsResponse data, response status code and response headers
      def submit_shipment_confirmations_with_http_info(body, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: VendorShippingApi.submit_shipment_confirmations ...'
        end
        # verify the required parameter 'body' is set
        if @api_client.config.client_side_validation && body.nil?
          fail ArgumentError, "Missing the required parameter 'body' when calling VendorShippingApi.submit_shipment_confirmations"
        end
        # resource path
        local_var_path = '/vendor/shipping/v1/shipmentConfirmations'

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

        return_type = opts[:return_type] || 'AmazonSpClients::ApiResponse' 

        auth_names = opts[:auth_names] || []
        data, status_code, headers = @api_client.call_api(:POST, local_var_path,
          :header_params => header_params,
          :query_params => query_params,
          :form_params => form_params,
          :body => post_body,
          :auth_names => auth_names,
          :return_type => return_type)

        if @api_client.config.debugging
          @api_client.config.logger.debug "API called: VendorShippingApi#submit_shipment_confirmations\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
        end
        return data, status_code, headers
      end
    end
  end
end
