=begin
#Selling Partner API for Merchant Fulfillment

#The Selling Partner API for Merchant Fulfillment helps you build applications that let sellers purchase shipping for non-Prime and Prime orders using Amazon’s Buy Shipping Services.

OpenAPI spec version: v0

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

# # Common files
# require 'sp_merchant_fulfillment_v0/api_client'
# require 'sp_merchant_fulfillment_v0/api_error'
# require 'sp_merchant_fulfillment_v0/version'
# require 'sp_merchant_fulfillment_v0/configuration'

# Models
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/additional_inputs'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/additional_inputs_list'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/additional_seller_input'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/additional_seller_inputs'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/additional_seller_inputs_list'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/address'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/address_line1'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/address_line2'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/address_line3'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/address_name'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/amazon_order_id'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/available_carrier_will_pick_up_option'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/available_carrier_will_pick_up_options_list'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/available_delivery_experience_option'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/available_delivery_experience_options_list'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/available_format_options_for_label'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/available_format_options_for_label_list'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/available_shipping_service_options'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/cancel_shipment_response'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/carrier_will_pick_up_option'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/city'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/constraint'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/constraints'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/country_code'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/create_shipment_request'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/create_shipment_response'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/currency_amount'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/custom_text_for_label'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/delivery_experience_option'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/delivery_experience_type'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/district_or_county'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/email_address'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/error'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/error_list'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/file_contents'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/file_type'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/get_additional_seller_inputs_request'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/get_additional_seller_inputs_response'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/get_additional_seller_inputs_result'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/get_eligible_shipment_services_request'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/get_eligible_shipment_services_response'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/get_eligible_shipment_services_result'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/get_shipment_response'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/hazmat_type'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/input_target_type'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/item'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/item_description'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/item_level_fields'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/item_level_fields_list'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/item_list'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/item_quantity'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/label'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/label_customization'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/label_dimension'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/label_dimensions'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/label_format'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/label_format_list'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/label_format_option'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/label_format_option_request'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/length'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/order_item_id'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/package_dimension'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/package_dimensions'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/phone_number'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/postal_code'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/predefined_package_dimensions'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/rejected_shipping_service'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/rejected_shipping_service_list'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/restricted_set_values'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/seller_input_definition'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/seller_order_id'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/shipment'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/shipment_id'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/shipment_request_details'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/shipment_status'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/shipping_offering_filter'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/shipping_service'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/shipping_service_identifier'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/shipping_service_list'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/shipping_service_options'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/standard_id_for_label'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/state_or_province_code'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/temporarily_unavailable_carrier'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/temporarily_unavailable_carrier_list'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/terms_and_conditions_not_accepted_carrier'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/terms_and_conditions_not_accepted_carrier_list'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/timestamp'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/tracking_id'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/transparency_code'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/transparency_code_list'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/unit_of_length'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/unit_of_weight'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/weight'
# 
# 
# require_relative './sp_merchant_fulfillment_v0/models/weight_value'
# 

# APIs
require_relative './sp_merchant_fulfillment_v0/api/merchant_fulfillment_api'
