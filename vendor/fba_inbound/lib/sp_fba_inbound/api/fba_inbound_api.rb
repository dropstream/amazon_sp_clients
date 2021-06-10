=begin
#Selling Partner API for FBA Inbound Eligibilty

#With the FBA Inbound Eligibility API, you can build applications that let sellers get eligibility previews for items before shipping them to Amazon's fulfillment centers. With this API you can find out if an item is eligible for inbound shipment to Amazon's fulfillment centers in a specific marketplace. You can also find out if an item is eligible for using the manufacturer barcode for FBA inventory tracking. Sellers can use this information to inform their decisions about which items to ship Amazon's fulfillment centers.

OpenAPI spec version: v1

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

module AmazonSpClients
  module SpFbaInbound
    class FbaInboundApi
      attr_accessor :api_client

      def initialize(opts = {})
        @api_client = AmazonSpClients::ApiClient.new(opts)
      end
      # This operation gets an eligibility preview for an item that you specify. You can specify the type of eligibility preview that you want (INBOUND or COMMINGLING). For INBOUND previews, you can specify the marketplace in which you want to determine the item's eligibility.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param asin The ASIN of the item for which you want an eligibility preview.
      # @param program The program that you want to check eligibility against.
      # @param [Hash] opts the optional parameters
      # @option opts [Array<String>] :marketplace_ids The identifier for the marketplace in which you want to determine eligibility. Required only when program&#x3D;INBOUND.
      # @return [GetItemEligibilityPreviewResponse]
      def get_item_eligibility_preview(asin, program, opts = {})
        data = get_item_eligibility_preview_with_http_info(asin, program, opts)
        return data
      end

      # This operation gets an eligibility preview for an item that you specify. You can specify the type of eligibility preview that you want (INBOUND or COMMINGLING). For INBOUND previews, you can specify the marketplace in which you want to determine the item&#x27;s eligibility.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param asin The ASIN of the item for which you want an eligibility preview.
      # @param program The program that you want to check eligibility against.
      # @param [Hash] opts the optional parameters
      # @option opts [Array<String>] :marketplace_ids The identifier for the marketplace in which you want to determine eligibility. Required only when program&#x3D;INBOUND.
      # @return [Array<(GetItemEligibilityPreviewResponse)>] GetItemEligibilityPreviewResponse data, response status code and response headers
      def get_item_eligibility_preview_with_http_info(asin, program, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: FbaInboundApi.get_item_eligibility_preview ...'
        end
        # verify the required parameter 'asin' is set
        if @api_client.config.client_side_validation && asin.nil?
          fail ArgumentError, "Missing the required parameter 'asin' when calling FbaInboundApi.get_item_eligibility_preview"
        end
        # verify the required parameter 'program' is set
        if @api_client.config.client_side_validation && program.nil?
          fail ArgumentError, "Missing the required parameter 'program' when calling FbaInboundApi.get_item_eligibility_preview"
        end
        # verify enum value
        if @api_client.config.client_side_validation && !['INBOUND', 'COMMINGLING'].include?(program)
          fail ArgumentError, "invalid value for 'program', must be one of INBOUND, COMMINGLING"
        end
        # resource path
        local_var_path = '/fba/inbound/v1/eligibility/itemPreview'

        # query parameters
        query_params = opts[:query_params] || {}
        query_params[:'asin'] = asin
        query_params[:'program'] = program
        query_params[:'marketplaceIds'] = @api_client.build_collection_param(opts[:'marketplace_ids'], :csv) if !opts[:'marketplace_ids'].nil?

        # header parameters
        header_params = opts[:header_params] || {}
        # HTTP header 'Accept' (if needed)
        header_params['Accept'] = @api_client.select_header_accept(['application/json', 'ItemEligibilityPreview'])

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
          @api_client.config.logger.debug "API called: FbaInboundApi#get_item_eligibility_preview\nData: #{data.inspect}"
        end
        return data
      end
    end
  end
end
