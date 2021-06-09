=begin
#Selling Partner API for Catalog Items

#The Selling Partner API for Catalog Items helps you programmatically retrieve item details for items in the catalog.

OpenAPI spec version: v0

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

module AmazonSpClients
  module SpCatalogItemsV0
    class CatalogApi
      attr_accessor :api_client

      def initialize(api_client = ApiClient.default)
        @api_client = api_client
      end
      # Returns a specified item and its attributes.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 2 | 20 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param marketplace_id A marketplace identifier. Specifies the marketplace for the item.
      # @param asin The Amazon Standard Identification Number (ASIN) of the item.
      # @param [Hash] opts the optional parameters
      # @return [GetCatalogItemResponse]
      def get_catalog_item(marketplace_id, asin, opts = {})
        data = get_catalog_item_with_http_info(marketplace_id, asin, opts)
        return data
      end

      # Returns a specified item and its attributes.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 2 | 20 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param marketplace_id A marketplace identifier. Specifies the marketplace for the item.
      # @param asin The Amazon Standard Identification Number (ASIN) of the item.
      # @param [Hash] opts the optional parameters
      # @return [Array<(GetCatalogItemResponse)>] GetCatalogItemResponse data, response status code and response headers
      def get_catalog_item_with_http_info(marketplace_id, asin, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: CatalogApi.get_catalog_item ...'
        end
        # verify the required parameter 'marketplace_id' is set
        if @api_client.config.client_side_validation && marketplace_id.nil?
          fail ArgumentError, "Missing the required parameter 'marketplace_id' when calling CatalogApi.get_catalog_item"
        end
        # verify the required parameter 'asin' is set
        if @api_client.config.client_side_validation && asin.nil?
          fail ArgumentError, "Missing the required parameter 'asin' when calling CatalogApi.get_catalog_item"
        end
        # resource path
        local_var_path = '/catalog/v0/items/{asin}'.sub('{' + 'asin' + '}', asin.to_s)

        # query parameters
        query_params = opts[:query_params] || {}
        query_params[:'MarketplaceId'] = marketplace_id

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
          @api_client.config.logger.debug "API called: CatalogApi#get_catalog_item\nData: #{data.inspect}"
        end
        return data
      end
      # Returns the parent categories to which an item belongs, based on the specified ASIN or SellerSKU.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 1 | 40 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param marketplace_id A marketplace identifier. Specifies the marketplace for the item.
      # @param [Hash] opts the optional parameters
      # @option opts [String] :asin The Amazon Standard Identification Number (ASIN) of the item.
      # @option opts [String] :seller_sku Used to identify items in the given marketplace. SellerSKU is qualified by the seller&#x27;s SellerId, which is included with every operation that you submit.
      # @return [ListCatalogCategoriesResponse]
      def list_catalog_categories(marketplace_id, opts = {})
        data = list_catalog_categories_with_http_info(marketplace_id, opts)
        return data
      end

      # Returns the parent categories to which an item belongs, based on the specified ASIN or SellerSKU.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 1 | 40 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param marketplace_id A marketplace identifier. Specifies the marketplace for the item.
      # @param [Hash] opts the optional parameters
      # @option opts [String] :asin The Amazon Standard Identification Number (ASIN) of the item.
      # @option opts [String] :seller_sku Used to identify items in the given marketplace. SellerSKU is qualified by the seller&#x27;s SellerId, which is included with every operation that you submit.
      # @return [Array<(ListCatalogCategoriesResponse)>] ListCatalogCategoriesResponse data, response status code and response headers
      def list_catalog_categories_with_http_info(marketplace_id, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: CatalogApi.list_catalog_categories ...'
        end
        # verify the required parameter 'marketplace_id' is set
        if @api_client.config.client_side_validation && marketplace_id.nil?
          fail ArgumentError, "Missing the required parameter 'marketplace_id' when calling CatalogApi.list_catalog_categories"
        end
        # resource path
        local_var_path = '/catalog/v0/categories'

        # query parameters
        query_params = opts[:query_params] || {}
        query_params[:'MarketplaceId'] = marketplace_id
        query_params[:'ASIN'] = opts[:'asin'] if !opts[:'asin'].nil?
        query_params[:'SellerSKU'] = opts[:'seller_sku'] if !opts[:'seller_sku'].nil?

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
          @api_client.config.logger.debug "API called: CatalogApi#list_catalog_categories\nData: #{data.inspect}"
        end
        return data
      end
      # Returns a list of items and their attributes, based on a search query or item identifiers that you specify. When based on a search query, provide the Query parameter and optionally, the QueryContextId parameter. When based on item identifiers, provide a single appropriate parameter based on the identifier type, and specify the associated item value. MarketplaceId is always required.  This operation returns a maximum of ten products and does not return non-buyable products.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 6 | 40 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.
      # @param marketplace_id A marketplace identifier. Specifies the marketplace for which items are returned.
      # @param [Hash] opts the optional parameters
      # @option opts [String] :query Keyword(s) to use to search for items in the catalog. Example: &#x27;harry potter books&#x27;.
      # @option opts [String] :query_context_id An identifier for the context within which the given search will be performed. A marketplace might provide mechanisms for constraining a search to a subset of potential items. For example, the retail marketplace allows queries to be constrained to a specific category. The QueryContextId parameter specifies such a subset. If it is omitted, the search will be performed using the default context for the marketplace, which will typically contain the largest set of items.
      # @option opts [String] :seller_sku Used to identify an item in the given marketplace. SellerSKU is qualified by the seller&#x27;s SellerId, which is included with every operation that you submit.
      # @option opts [String] :upc A 12-digit bar code used for retail packaging.
      # @option opts [String] :ean A European article number that uniquely identifies the catalog item, manufacturer, and its attributes.
      # @option opts [String] :isbn The unique commercial book identifier used to identify books internationally.
      # @option opts [String] :jan A Japanese article number that uniquely identifies the product, manufacturer, and its attributes.
      # @return [ListCatalogItemsResponse]
      def list_catalog_items(marketplace_id, opts = {})
        data = list_catalog_items_with_http_info(marketplace_id, opts)
        return data
      end

      # Returns a list of items and their attributes, based on a search query or item identifiers that you specify. When based on a search query, provide the Query parameter and optionally, the QueryContextId parameter. When based on item identifiers, provide a single appropriate parameter based on the identifier type, and specify the associated item value. MarketplaceId is always required.  This operation returns a maximum of ten products and does not return non-buyable products.  **Usage Plans:**  | Plan type | Rate (requests per second) | Burst | | ---- | ---- | ---- | |Default| 6 | 40 | |Selling partner specific| Variable | Variable |  The x-amzn-RateLimit-Limit response header returns the usage plan rate limits that were applied to the requested operation. Rate limits for some selling partners will vary from the default rate and burst shown in the table above. For more information, see \&quot;Usage Plans and Rate Limits\&quot; in the Selling Partner API documentation.
      # @param marketplace_id A marketplace identifier. Specifies the marketplace for which items are returned.
      # @param [Hash] opts the optional parameters
      # @option opts [String] :query Keyword(s) to use to search for items in the catalog. Example: &#x27;harry potter books&#x27;.
      # @option opts [String] :query_context_id An identifier for the context within which the given search will be performed. A marketplace might provide mechanisms for constraining a search to a subset of potential items. For example, the retail marketplace allows queries to be constrained to a specific category. The QueryContextId parameter specifies such a subset. If it is omitted, the search will be performed using the default context for the marketplace, which will typically contain the largest set of items.
      # @option opts [String] :seller_sku Used to identify an item in the given marketplace. SellerSKU is qualified by the seller&#x27;s SellerId, which is included with every operation that you submit.
      # @option opts [String] :upc A 12-digit bar code used for retail packaging.
      # @option opts [String] :ean A European article number that uniquely identifies the catalog item, manufacturer, and its attributes.
      # @option opts [String] :isbn The unique commercial book identifier used to identify books internationally.
      # @option opts [String] :jan A Japanese article number that uniquely identifies the product, manufacturer, and its attributes.
      # @return [Array<(ListCatalogItemsResponse)>] ListCatalogItemsResponse data, response status code and response headers
      def list_catalog_items_with_http_info(marketplace_id, opts = {})
        if @api_client.config.debugging
          @api_client.config.logger.debug 'Calling API: CatalogApi.list_catalog_items ...'
        end
        # verify the required parameter 'marketplace_id' is set
        if @api_client.config.client_side_validation && marketplace_id.nil?
          fail ArgumentError, "Missing the required parameter 'marketplace_id' when calling CatalogApi.list_catalog_items"
        end
        # resource path
        local_var_path = '/catalog/v0/items'

        # query parameters
        query_params = opts[:query_params] || {}
        query_params[:'MarketplaceId'] = marketplace_id
        query_params[:'Query'] = opts[:'query'] if !opts[:'query'].nil?
        query_params[:'QueryContextId'] = opts[:'query_context_id'] if !opts[:'query_context_id'].nil?
        query_params[:'SellerSKU'] = opts[:'seller_sku'] if !opts[:'seller_sku'].nil?
        query_params[:'UPC'] = opts[:'upc'] if !opts[:'upc'].nil?
        query_params[:'EAN'] = opts[:'ean'] if !opts[:'ean'].nil?
        query_params[:'ISBN'] = opts[:'isbn'] if !opts[:'isbn'].nil?
        query_params[:'JAN'] = opts[:'jan'] if !opts[:'jan'].nil?

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
          @api_client.config.logger.debug "API called: CatalogApi#list_catalog_items\nData: #{data.inspect}"
        end
        return data
      end
    end
  end
end
