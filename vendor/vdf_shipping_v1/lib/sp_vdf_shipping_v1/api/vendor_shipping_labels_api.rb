=begin
#Selling Partner API for Direct Fulfillment Shipping

#The Selling Partner API for Direct Fulfillment Shipping provides programmatic access to a direct fulfillment vendor's shipping data.

OpenAPI spec version: v1

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.33
=end

module AmazonSpClients
  module SpVdfShippingV1
    class VendorShippingLabelsApi
      attr_accessor :api_client

      def initialize(session)
        @api_client = AmazonSpClients::ApiClient.new(session)
      end
      # Returns a shipping label for the purchaseOrderNumber that you specify.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param purchase_order_number The purchase order number for which you want to return the shipping label. It should be the same purchaseOrderNumber as received in the order.
      # @param [Hash] opts the optional parameters
      # @return [GetShippingLabelResponse]
      def get_shipping_label(purchase_order_number, opts = {})
        data = get_shipping_label_with_http_info(purchase_order_number, opts)
        return data
      end

      # Returns a shipping label for the purchaseOrderNumber that you specify.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param purchase_order_number The purchase order number for which you want to return the shipping label. It should be the same purchaseOrderNumber as received in the order.
      # @param [Hash] opts the optional parameters
      # @return [Array<(GetShippingLabelResponse)>] GetShippingLabelResponse data, response status code and response headers
      def get_shipping_label_with_http_info(purchase_order_number, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: VendorShippingLabelsApi.get_shipping_label ...'
        end
        # verify the required parameter 'purchase_order_number' is set
        if @api_client.config.client_side_validation && purchase_order_number.nil?
          fail ArgumentError, "Missing the required parameter 'purchase_order_number' when calling VendorShippingLabelsApi.get_shipping_label"
        end
        # resource path
        local_var_path = '/vendor/directFulfillment/shipping/v1/shippingLabels/{purchaseOrderNumber}'.sub('{' + 'purchaseOrderNumber' + '}', purchase_order_number.to_s)

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
        data = @api_client.call_api(:GET, local_var_path,
          :header_params => header_params,
          :query_params => query_params,
          :form_params => form_params,
          :body => post_body,
          :auth_names => auth_names,
          :return_type => return_type)

        if @api_client.config.debugging
          @api_client.config.logger.debug "API called: VendorShippingLabelsApi#get_shipping_label\nData: #{data.inspect}"
        end
        return data
      end
      # Returns a list of shipping labels created during the time frame that you specify. You define that time frame using the createdAfter and createdBefore parameters. You must use both of these parameters. The date range to search must not be more than 7 days.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param created_after Shipping labels that became available after this date and time will be included in the result. Must be in ISO-8601 date/time format.
      # @param created_before Shipping labels that became available before this date and time will be included in the result. Must be in ISO-8601 date/time format.
      # @param [Hash] opts the optional parameters
      # @option opts [String] :ship_from_party_id The vendor warehouseId for order fulfillment. If not specified, the result will contain orders for all warehouses.
      # @option opts [Integer] :limit The limit to the number of records returned.
      # @option opts [String] :sort_order Sort ASC or DESC by order creation date. (default to ASC)
      # @option opts [String] :next_token Used for pagination when there are more ship labels than the specified result size limit. The token value is returned in the previous API call.
      # @return [GetShippingLabelListResponse]
      def get_shipping_labels(created_after, created_before, opts = {})
        data = get_shipping_labels_with_http_info(created_after, created_before, opts)
        return data
      end

      # Returns a list of shipping labels created during the time frame that you specify. You define that time frame using the createdAfter and createdBefore parameters. You must use both of these parameters. The date range to search must not be more than 7 days.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param created_after Shipping labels that became available after this date and time will be included in the result. Must be in ISO-8601 date/time format.
      # @param created_before Shipping labels that became available before this date and time will be included in the result. Must be in ISO-8601 date/time format.
      # @param [Hash] opts the optional parameters
      # @option opts [String] :ship_from_party_id The vendor warehouseId for order fulfillment. If not specified, the result will contain orders for all warehouses.
      # @option opts [Integer] :limit The limit to the number of records returned.
      # @option opts [String] :sort_order Sort ASC or DESC by order creation date.
      # @option opts [String] :next_token Used for pagination when there are more ship labels than the specified result size limit. The token value is returned in the previous API call.
      # @return [Array<(GetShippingLabelListResponse)>] GetShippingLabelListResponse data, response status code and response headers
      def get_shipping_labels_with_http_info(created_after, created_before, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: VendorShippingLabelsApi.get_shipping_labels ...'
        end
        # verify the required parameter 'created_after' is set
        if @api_client.config.client_side_validation && created_after.nil?
          fail ArgumentError, "Missing the required parameter 'created_after' when calling VendorShippingLabelsApi.get_shipping_labels"
        end
        # verify the required parameter 'created_before' is set
        if @api_client.config.client_side_validation && created_before.nil?
          fail ArgumentError, "Missing the required parameter 'created_before' when calling VendorShippingLabelsApi.get_shipping_labels"
        end
        if @api_client.config.client_side_validation && opts[:'sort_order'] && !['ASC', 'DESC'].include?(opts[:'sort_order'])
          fail ArgumentError, 'invalid value for "sort_order", must be one of ASC, DESC'
        end
        # resource path
        local_var_path = '/vendor/directFulfillment/shipping/v1/shippingLabels'

        # query parameters
        query_params = opts[:query_params] || {}
        query_params[:'createdAfter'] = created_after
        query_params[:'createdBefore'] = created_before
        query_params[:'shipFromPartyId'] = opts[:'ship_from_party_id'] if !opts[:'ship_from_party_id'].nil?
        query_params[:'limit'] = opts[:'limit'] if !opts[:'limit'].nil?
        query_params[:'sortOrder'] = opts[:'sort_order'] if !opts[:'sort_order'].nil?
        query_params[:'nextToken'] = opts[:'next_token'] if !opts[:'next_token'].nil?

        # header parameters
        header_params = opts[:header_params] || {}
        # HTTP header 'Accept' (if needed)
        header_params['Accept'] = @api_client.select_header_accept(['application/json', 'payload'])

        # form parameters
        form_params = opts[:form_params] || {}

        # http body (model)
        post_body = opts[:body] 

        return_type = opts[:return_type] || 'AmazonSpClients::ApiResponse' 

        auth_names = opts[:auth_names] || []
        data = @api_client.call_api(:GET, local_var_path,
          :header_params => header_params,
          :query_params => query_params,
          :form_params => form_params,
          :body => post_body,
          :auth_names => auth_names,
          :return_type => return_type)

        if @api_client.config.debugging
          @api_client.config.logger.debug "API called: VendorShippingLabelsApi#get_shipping_labels\nData: #{data.inspect}"
        end
        return data
      end
      # Creates a shipping label for a purchase order and returns a transactionId for reference.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [SubmitShippingLabelsResponse]
      def submit_shipping_label_request(body, opts = {})
        data = submit_shipping_label_request_with_http_info(body, opts)
        return data
      end

      # Creates a shipping label for a purchase order and returns a transactionId for reference.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [Array<(SubmitShippingLabelsResponse)>] SubmitShippingLabelsResponse data, response status code and response headers
      def submit_shipping_label_request_with_http_info(body, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: VendorShippingLabelsApi.submit_shipping_label_request ...'
        end
        # verify the required parameter 'body' is set
        if @api_client.config.client_side_validation && body.nil?
          fail ArgumentError, "Missing the required parameter 'body' when calling VendorShippingLabelsApi.submit_shipping_label_request"
        end
        # resource path
        local_var_path = '/vendor/directFulfillment/shipping/v1/shippingLabels'

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
        data = @api_client.call_api(:POST, local_var_path,
          :header_params => header_params,
          :query_params => query_params,
          :form_params => form_params,
          :body => post_body,
          :auth_names => auth_names,
          :return_type => return_type)

        if @api_client.config.debugging
          @api_client.config.logger.debug "API called: VendorShippingLabelsApi#submit_shipping_label_request\nData: #{data.inspect}"
        end
        return data
      end
    end
  end
end
