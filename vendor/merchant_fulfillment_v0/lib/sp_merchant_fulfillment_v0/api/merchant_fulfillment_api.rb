=begin
#Selling Partner API for Merchant Fulfillment

#The Selling Partner API for Merchant Fulfillment helps you build applications that let sellers purchase shipping for non-Prime and Prime orders using Amazon’s Buy Shipping Services.

OpenAPI spec version: v0

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.26
=end

module AmazonSpClients
  module SpMerchantFulfillmentV0
    class MerchantFulfillmentApi
      attr_accessor :api_client

      def initialize(session)
        @api_client = AmazonSpClients::ApiClient.new(session)
      end
      # Cancel the shipment indicated by the specified shipment identifier.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param shipment_id The Amazon-defined shipment identifier for the shipment to cancel.
      # @param [Hash] opts the optional parameters
      # @return [CancelShipmentResponse]
      def cancel_shipment(shipment_id, opts = {})
        data = cancel_shipment_with_http_info(shipment_id, opts)
        return data
      end

      # Cancel the shipment indicated by the specified shipment identifier.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param shipment_id The Amazon-defined shipment identifier for the shipment to cancel.
      # @param [Hash] opts the optional parameters
      # @return [Array<(CancelShipmentResponse)>] CancelShipmentResponse data, response status code and response headers
      def cancel_shipment_with_http_info(shipment_id, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: MerchantFulfillmentApi.cancel_shipment ...'
        end
        # verify the required parameter 'shipment_id' is set
        if @api_client.config.client_side_validation && shipment_id.nil?
          fail ArgumentError, "Missing the required parameter 'shipment_id' when calling MerchantFulfillmentApi.cancel_shipment"
        end
        # resource path
        local_var_path = '/mfn/v0/shipments/{shipmentId}'.sub('{' + 'shipmentId' + '}', shipment_id.to_s)

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
        data = @api_client.call_api(:DELETE, local_var_path,
          :header_params => header_params,
          :query_params => query_params,
          :form_params => form_params,
          :body => post_body,
          :auth_names => auth_names,
          :return_type => return_type)

        if @api_client.config.debugging
          @api_client.config.logger.debug "API called: MerchantFulfillmentApi#cancel_shipment\nData: #{data.inspect}"
        end
        return data
      end
      # Cancel the shipment indicated by the specified shipment identifer.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param shipment_id The Amazon-defined shipment identifier for the shipment to cancel.
      # @param [Hash] opts the optional parameters
      # @return [CancelShipmentResponse]
      def cancel_shipment_old(shipment_id, opts = {})
        data = cancel_shipment_old_with_http_info(shipment_id, opts)
        return data
      end

      # Cancel the shipment indicated by the specified shipment identifer.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param shipment_id The Amazon-defined shipment identifier for the shipment to cancel.
      # @param [Hash] opts the optional parameters
      # @return [Array<(CancelShipmentResponse)>] CancelShipmentResponse data, response status code and response headers
      def cancel_shipment_old_with_http_info(shipment_id, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: MerchantFulfillmentApi.cancel_shipment_old ...'
        end
        # verify the required parameter 'shipment_id' is set
        if @api_client.config.client_side_validation && shipment_id.nil?
          fail ArgumentError, "Missing the required parameter 'shipment_id' when calling MerchantFulfillmentApi.cancel_shipment_old"
        end
        # resource path
        local_var_path = '/mfn/v0/shipments/{shipmentId}/cancel'.sub('{' + 'shipmentId' + '}', shipment_id.to_s)

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
        data = @api_client.call_api(:PUT, local_var_path,
          :header_params => header_params,
          :query_params => query_params,
          :form_params => form_params,
          :body => post_body,
          :auth_names => auth_names,
          :return_type => return_type)

        if @api_client.config.debugging
          @api_client.config.logger.debug "API called: MerchantFulfillmentApi#cancel_shipment_old\nData: #{data.inspect}"
        end
        return data
      end
      # Create a shipment with the information provided.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [CreateShipmentResponse]
      def create_shipment(body, opts = {})
        data = create_shipment_with_http_info(body, opts)
        return data
      end

      # Create a shipment with the information provided.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [Array<(CreateShipmentResponse)>] CreateShipmentResponse data, response status code and response headers
      def create_shipment_with_http_info(body, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: MerchantFulfillmentApi.create_shipment ...'
        end
        # verify the required parameter 'body' is set
        if @api_client.config.client_side_validation && body.nil?
          fail ArgumentError, "Missing the required parameter 'body' when calling MerchantFulfillmentApi.create_shipment"
        end
        # resource path
        local_var_path = '/mfn/v0/shipments'

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
          @api_client.config.logger.debug "API called: MerchantFulfillmentApi#create_shipment\nData: #{data.inspect}"
        end
        return data
      end
      # Gets a list of additional seller inputs required for a ship method. This is generally used for international shipping.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [GetAdditionalSellerInputsResponse]
      def get_additional_seller_inputs(body, opts = {})
        data = get_additional_seller_inputs_with_http_info(body, opts)
        return data
      end

      # Gets a list of additional seller inputs required for a ship method. This is generally used for international shipping.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [Array<(GetAdditionalSellerInputsResponse)>] GetAdditionalSellerInputsResponse data, response status code and response headers
      def get_additional_seller_inputs_with_http_info(body, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: MerchantFulfillmentApi.get_additional_seller_inputs ...'
        end
        # verify the required parameter 'body' is set
        if @api_client.config.client_side_validation && body.nil?
          fail ArgumentError, "Missing the required parameter 'body' when calling MerchantFulfillmentApi.get_additional_seller_inputs"
        end
        # resource path
        local_var_path = '/mfn/v0/additionalSellerInputs'

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
          @api_client.config.logger.debug "API called: MerchantFulfillmentApi#get_additional_seller_inputs\nData: #{data.inspect}"
        end
        return data
      end
      # Get a list of additional seller inputs required for a ship method. This is generally used for international shipping.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [GetAdditionalSellerInputsResponse]
      def get_additional_seller_inputs_old(body, opts = {})
        data = get_additional_seller_inputs_old_with_http_info(body, opts)
        return data
      end

      # Get a list of additional seller inputs required for a ship method. This is generally used for international shipping.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [Array<(GetAdditionalSellerInputsResponse)>] GetAdditionalSellerInputsResponse data, response status code and response headers
      def get_additional_seller_inputs_old_with_http_info(body, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: MerchantFulfillmentApi.get_additional_seller_inputs_old ...'
        end
        # verify the required parameter 'body' is set
        if @api_client.config.client_side_validation && body.nil?
          fail ArgumentError, "Missing the required parameter 'body' when calling MerchantFulfillmentApi.get_additional_seller_inputs_old"
        end
        # resource path
        local_var_path = '/mfn/v0/sellerInputs'

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
          @api_client.config.logger.debug "API called: MerchantFulfillmentApi#get_additional_seller_inputs_old\nData: #{data.inspect}"
        end
        return data
      end
      # Returns a list of shipping service offers that satisfy the specified shipment request details.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [GetEligibleShipmentServicesResponse]
      def get_eligible_shipment_services(body, opts = {})
        data = get_eligible_shipment_services_with_http_info(body, opts)
        return data
      end

      # Returns a list of shipping service offers that satisfy the specified shipment request details.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [Array<(GetEligibleShipmentServicesResponse)>] GetEligibleShipmentServicesResponse data, response status code and response headers
      def get_eligible_shipment_services_with_http_info(body, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: MerchantFulfillmentApi.get_eligible_shipment_services ...'
        end
        # verify the required parameter 'body' is set
        if @api_client.config.client_side_validation && body.nil?
          fail ArgumentError, "Missing the required parameter 'body' when calling MerchantFulfillmentApi.get_eligible_shipment_services"
        end
        # resource path
        local_var_path = '/mfn/v0/eligibleShippingServices'

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
          @api_client.config.logger.debug "API called: MerchantFulfillmentApi#get_eligible_shipment_services\nData: #{data.inspect}"
        end
        return data
      end
      # Returns a list of shipping service offers that satisfy the specified shipment request details.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [GetEligibleShipmentServicesResponse]
      def get_eligible_shipment_services_old(body, opts = {})
        data = get_eligible_shipment_services_old_with_http_info(body, opts)
        return data
      end

      # Returns a list of shipping service offers that satisfy the specified shipment request details.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param body 
      # @param [Hash] opts the optional parameters
      # @return [Array<(GetEligibleShipmentServicesResponse)>] GetEligibleShipmentServicesResponse data, response status code and response headers
      def get_eligible_shipment_services_old_with_http_info(body, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: MerchantFulfillmentApi.get_eligible_shipment_services_old ...'
        end
        # verify the required parameter 'body' is set
        if @api_client.config.client_side_validation && body.nil?
          fail ArgumentError, "Missing the required parameter 'body' when calling MerchantFulfillmentApi.get_eligible_shipment_services_old"
        end
        # resource path
        local_var_path = '/mfn/v0/eligibleServices'

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
          @api_client.config.logger.debug "API called: MerchantFulfillmentApi#get_eligible_shipment_services_old\nData: #{data.inspect}"
        end
        return data
      end
      # Returns the shipment information for an existing shipment.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param shipment_id The Amazon-defined shipment identifier for the shipment.
      # @param [Hash] opts the optional parameters
      # @return [GetShipmentResponse]
      def get_shipment(shipment_id, opts = {})
        data = get_shipment_with_http_info(shipment_id, opts)
        return data
      end

      # Returns the shipment information for an existing shipment.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param shipment_id The Amazon-defined shipment identifier for the shipment.
      # @param [Hash] opts the optional parameters
      # @return [Array<(GetShipmentResponse)>] GetShipmentResponse data, response status code and response headers
      def get_shipment_with_http_info(shipment_id, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: MerchantFulfillmentApi.get_shipment ...'
        end
        # verify the required parameter 'shipment_id' is set
        if @api_client.config.client_side_validation && shipment_id.nil?
          fail ArgumentError, "Missing the required parameter 'shipment_id' when calling MerchantFulfillmentApi.get_shipment"
        end
        # resource path
        local_var_path = '/mfn/v0/shipments/{shipmentId}'.sub('{' + 'shipmentId' + '}', shipment_id.to_s)

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
          @api_client.config.logger.debug "API called: MerchantFulfillmentApi#get_shipment\nData: #{data.inspect}"
        end
        return data
      end
    end
  end
end
