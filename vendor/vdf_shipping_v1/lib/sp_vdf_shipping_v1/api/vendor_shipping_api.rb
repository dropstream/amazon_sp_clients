=begin
#Selling Partner API for Direct Fulfillment Shipping

#The Selling Partner API for Direct Fulfillment Shipping provides programmatic access to a direct fulfillment vendor's shipping data.

OpenAPI spec version: v1

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

module AmazonSpClients
  module SpVdfShippingV1
    class VendorShippingApi
      attr_accessor :api_client

      def initialize(opts = {})
        @api_client = AmazonSpClients::ApiClient.new(opts)
      end
      # Returns a packing slip based on the purchaseOrderNumber that you specify.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param purchase_order_number The purchaseOrderNumber for the packing slip you want.
      # @param [Hash] opts the optional parameters
      # @return [GetPackingSlipResponse]
      def get_packing_slip(purchase_order_number, opts = {})
        data = get_packing_slip_with_http_info(purchase_order_number, opts)
        return data
      end

      # Returns a packing slip based on the purchaseOrderNumber that you specify.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param purchase_order_number The purchaseOrderNumber for the packing slip you want.
      # @param [Hash] opts the optional parameters
      # @return [Array<(GetPackingSlipResponse)>] GetPackingSlipResponse data, response status code and response headers
      def get_packing_slip_with_http_info(purchase_order_number, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: VendorShippingApi.get_packing_slip ...'
        end
        # verify the required parameter 'purchase_order_number' is set
        if @api_client.config.client_side_validation && purchase_order_number.nil?
          fail ArgumentError, "Missing the required parameter 'purchase_order_number' when calling VendorShippingApi.get_packing_slip"
        end
        # resource path
        local_var_path = '/vendor/directFulfillment/shipping/v1/packingSlips/{purchaseOrderNumber}'.sub('{' + 'purchaseOrderNumber' + '}', purchase_order_number.to_s)

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
          @api_client.config.logger.debug "API called: VendorShippingApi#get_packing_slip\nData: #{data.inspect}"
        end
        return data
      end
      # Returns a list of packing slips for the purchase orders that match the criteria specified. Date range to search must not be more than 7 days.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param created_after Packing slips that became available after this date and time will be included in the result. Must be in ISO-8601 date/time format.
      # @param created_before Packing slips that became available before this date and time will be included in the result. Must be in ISO-8601 date/time format.
      # @param [Hash] opts the optional parameters
      # @option opts [String] :ship_from_party_id The vendor warehouseId for order fulfillment. If not specified the result will contain orders for all warehouses.
      # @option opts [Integer] :limit The limit to the number of records returned
      # @option opts [String] :sort_order Sort ASC or DESC by packing slip creation date. (default to ASC)
      # @option opts [String] :next_token Used for pagination when there are more packing slips than the specified result size limit. The token value is returned in the previous API call.
      # @return [GetPackingSlipListResponse]
      def get_packing_slips(created_after, created_before, opts = {})
        data = get_packing_slips_with_http_info(created_after, created_before, opts)
        return data
      end

      # Returns a list of packing slips for the purchase orders that match the criteria specified. Date range to search must not be more than 7 days.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param created_after Packing slips that became available after this date and time will be included in the result. Must be in ISO-8601 date/time format.
      # @param created_before Packing slips that became available before this date and time will be included in the result. Must be in ISO-8601 date/time format.
      # @param [Hash] opts the optional parameters
      # @option opts [String] :ship_from_party_id The vendor warehouseId for order fulfillment. If not specified the result will contain orders for all warehouses.
      # @option opts [Integer] :limit The limit to the number of records returned
      # @option opts [String] :sort_order Sort ASC or DESC by packing slip creation date.
      # @option opts [String] :next_token Used for pagination when there are more packing slips than the specified result size limit. The token value is returned in the previous API call.
      # @return [Array<(GetPackingSlipListResponse)>] GetPackingSlipListResponse data, response status code and response headers
      def get_packing_slips_with_http_info(created_after, created_before, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: VendorShippingApi.get_packing_slips ...'
        end
        # verify the required parameter 'created_after' is set
        if @api_client.config.client_side_validation && created_after.nil?
          fail ArgumentError, "Missing the required parameter 'created_after' when calling VendorShippingApi.get_packing_slips"
        end
        # verify the required parameter 'created_before' is set
        if @api_client.config.client_side_validation && created_before.nil?
          fail ArgumentError, "Missing the required parameter 'created_before' when calling VendorShippingApi.get_packing_slips"
        end
        if @api_client.config.client_side_validation && opts[:'sort_order'] && !['ASC', 'DESC'].include?(opts[:'sort_order'])
          fail ArgumentError, 'invalid value for "sort_order", must be one of ASC, DESC'
        end
        # resource path
        local_var_path = '/vendor/directFulfillment/shipping/v1/packingSlips'

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
          @api_client.config.logger.debug "API called: VendorShippingApi#get_packing_slips\nData: #{data.inspect}"
        end
        return data
      end
      # Submits one or more shipment confirmations for vendor orders.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [SubmitShipmentConfirmationsResponse]
      def submit_shipment_confirmations(body, opts = {})
        data = submit_shipment_confirmations_with_http_info(body, opts)
        return data
      end

      # Submits one or more shipment confirmations for vendor orders.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [Array<(SubmitShipmentConfirmationsResponse)>] SubmitShipmentConfirmationsResponse data, response status code and response headers
      def submit_shipment_confirmations_with_http_info(body, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: VendorShippingApi.submit_shipment_confirmations ...'
        end
        # verify the required parameter 'body' is set
        if @api_client.config.client_side_validation && body.nil?
          fail ArgumentError, "Missing the required parameter 'body' when calling VendorShippingApi.submit_shipment_confirmations"
        end
        # resource path
        local_var_path = '/vendor/directFulfillment/shipping/v1/shipmentConfirmations'

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
          @api_client.config.logger.debug "API called: VendorShippingApi#submit_shipment_confirmations\nData: #{data.inspect}"
        end
        return data
      end
      # This API call is only to be used by Vendor-Own-Carrier (VOC) vendors. Calling this API will submit a shipment status update for the package that a vendor has shipped. It will provide the Amazon customer visibility on their order, when the package is outside of Amazon Network visibility.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [SubmitShipmentStatusUpdatesResponse]
      def submit_shipment_status_updates(body, opts = {})
        data = submit_shipment_status_updates_with_http_info(body, opts)
        return data
      end

      # This API call is only to be used by Vendor-Own-Carrier (VOC) vendors. Calling this API will submit a shipment status update for the package that a vendor has shipped. It will provide the Amazon customer visibility on their order, when the package is outside of Amazon Network visibility.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 10 | 10 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [Array<(SubmitShipmentStatusUpdatesResponse)>] SubmitShipmentStatusUpdatesResponse data, response status code and response headers
      def submit_shipment_status_updates_with_http_info(body, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: VendorShippingApi.submit_shipment_status_updates ...'
        end
        # verify the required parameter 'body' is set
        if @api_client.config.client_side_validation && body.nil?
          fail ArgumentError, "Missing the required parameter 'body' when calling VendorShippingApi.submit_shipment_status_updates"
        end
        # resource path
        local_var_path = '/vendor/directFulfillment/shipping/v1/shipmentStatusUpdates'

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
          @api_client.config.logger.debug "API called: VendorShippingApi#submit_shipment_status_updates\nData: #{data.inspect}"
        end
        return data
      end
    end
  end
end
