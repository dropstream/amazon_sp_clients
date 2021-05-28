=begin
#Selling Partner API for Shipping

#Provides programmatic access to Amazon Shipping APIs.

OpenAPI spec version: v1

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

# # Common files
# require 'sp_shipping/api_client'
# require 'sp_shipping/api_error'
# require 'sp_shipping/version'
# require 'sp_shipping/configuration'

# Models
require_relative './sp_shipping/models/accepted_rate'
require_relative './sp_shipping/models/account'
require_relative './sp_shipping/models/account_id'
require_relative './sp_shipping/models/address'
require_relative './sp_shipping/models/cancel_shipment_response'
require_relative './sp_shipping/models/city'
require_relative './sp_shipping/models/client_reference_id'
require_relative './sp_shipping/models/container'
require_relative './sp_shipping/models/container_item'
require_relative './sp_shipping/models/container_list'
require_relative './sp_shipping/models/container_reference_id'
require_relative './sp_shipping/models/container_specification'
require_relative './sp_shipping/models/container_specification_list'
require_relative './sp_shipping/models/country_code'
require_relative './sp_shipping/models/create_shipment_request'
require_relative './sp_shipping/models/create_shipment_response'
require_relative './sp_shipping/models/create_shipment_result'
require_relative './sp_shipping/models/currency'
require_relative './sp_shipping/models/dimensions'
require_relative './sp_shipping/models/error'
require_relative './sp_shipping/models/error_list'
require_relative './sp_shipping/models/event'
require_relative './sp_shipping/models/event_code'
require_relative './sp_shipping/models/event_list'
require_relative './sp_shipping/models/get_account_response'
require_relative './sp_shipping/models/get_rates_request'
require_relative './sp_shipping/models/get_rates_response'
require_relative './sp_shipping/models/get_rates_result'
require_relative './sp_shipping/models/get_shipment_response'
require_relative './sp_shipping/models/get_tracking_information_response'
require_relative './sp_shipping/models/label'
require_relative './sp_shipping/models/label_result'
require_relative './sp_shipping/models/label_result_list'
require_relative './sp_shipping/models/label_specification'
require_relative './sp_shipping/models/label_stream'
require_relative './sp_shipping/models/location'
require_relative './sp_shipping/models/party'
require_relative './sp_shipping/models/postal_code'
require_relative './sp_shipping/models/promised_delivery_date'
require_relative './sp_shipping/models/purchase_labels_request'
require_relative './sp_shipping/models/purchase_labels_response'
require_relative './sp_shipping/models/purchase_labels_result'
require_relative './sp_shipping/models/purchase_shipment_request'
require_relative './sp_shipping/models/purchase_shipment_response'
require_relative './sp_shipping/models/purchase_shipment_result'
require_relative './sp_shipping/models/rate'
require_relative './sp_shipping/models/rate_id'
require_relative './sp_shipping/models/rate_list'
require_relative './sp_shipping/models/retrieve_shipping_label_request'
require_relative './sp_shipping/models/retrieve_shipping_label_response'
require_relative './sp_shipping/models/retrieve_shipping_label_result'
require_relative './sp_shipping/models/service_rate'
require_relative './sp_shipping/models/service_rate_list'
require_relative './sp_shipping/models/service_type'
require_relative './sp_shipping/models/service_type_list'
require_relative './sp_shipping/models/shipment'
require_relative './sp_shipping/models/shipment_id'
require_relative './sp_shipping/models/shipping_promise_set'
require_relative './sp_shipping/models/state_or_region'
require_relative './sp_shipping/models/time_range'
require_relative './sp_shipping/models/tracking_id'
require_relative './sp_shipping/models/tracking_information'
require_relative './sp_shipping/models/tracking_summary'
require_relative './sp_shipping/models/weight'

# APIs
require_relative './sp_shipping/api/shipping_api'

# module SpShipping
#   class << self
#     # Customize default settings for the SDK using block.
#     #   SpShipping.configure do |config|
#     #     config.username = "xxx"
#     #     config.password = "xxx"
#     #   end
#     # If no block given, return the default Configuration object.
#     def configure
#       if block_given?
#         yield(Configuration.default)
#       else
#         Configuration.default
#       end
#     end
#   end
# end
