=begin
#Selling Partner API for A+ Content Management

#With the A+ Content API, you can build applications that help selling partners add rich marketing content to their Amazon product detail pages. A+ content helps selling partners share their brand and product story, which helps buyers make informed purchasing decisions. Selling partners assemble content by choosing from content modules and adding images and text.

OpenAPI spec version: 2020-11-01

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

# # Common files
# require 'sp_aplus_content_2020/api_client'
# require 'sp_aplus_content_2020/api_error'
# require 'sp_aplus_content_2020/version'
# require 'sp_aplus_content_2020/configuration'

# Models
# 
# 
# require_relative './sp_aplus_content_2020/models/aplus_paginated_response'
# 
# 
# require_relative './sp_aplus_content_2020/models/aplus_response'
# 
# 
# require_relative './sp_aplus_content_2020/models/asin'
# 
# 
# require_relative './sp_aplus_content_2020/models/asin_badge'
# 
# 
# require_relative './sp_aplus_content_2020/models/asin_badge_set'
# 
# 
# require_relative './sp_aplus_content_2020/models/asin_metadata'
# 
# 
# require_relative './sp_aplus_content_2020/models/asin_metadata_set'
# 
# 
# require_relative './sp_aplus_content_2020/models/asin_set'
# 
# 
# require_relative './sp_aplus_content_2020/models/color_type'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_badge'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_badge_set'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_document'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_metadata'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_metadata_record'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_metadata_record_list'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_module_list'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_module_type'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_record'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_record_list'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_reference_key'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_reference_key_set'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_status'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_sub_type'
# 
# 
# require_relative './sp_aplus_content_2020/models/content_type'
# 
# 
# require_relative './sp_aplus_content_2020/models/decorator'
# 
# 
# require_relative './sp_aplus_content_2020/models/decorator_set'
# 
# 
# require_relative './sp_aplus_content_2020/models/decorator_type'
# 
# 
# require_relative './sp_aplus_content_2020/models/error'
# 
# 
# require_relative './sp_aplus_content_2020/models/error_list'
# 
# 
# require_relative './sp_aplus_content_2020/models/get_content_document_included_data_type'
# 
# 
# require_relative './sp_aplus_content_2020/models/get_content_document_response'
# 
# 
# require_relative './sp_aplus_content_2020/models/image_component'
# 
# 
# require_relative './sp_aplus_content_2020/models/image_crop_specification'
# 
# 
# require_relative './sp_aplus_content_2020/models/image_dimensions'
# 
# 
# require_relative './sp_aplus_content_2020/models/image_offsets'
# 
# 
# require_relative './sp_aplus_content_2020/models/integer_with_units'
# 
# 
# require_relative './sp_aplus_content_2020/models/language_tag'
# 
# 
# require_relative './sp_aplus_content_2020/models/list_content_document_asin_relations_included_data_type'
# 
# 
# require_relative './sp_aplus_content_2020/models/list_content_document_asin_relations_response'
# 
# 
# require_relative './sp_aplus_content_2020/models/marketplace_id'
# 
# 
# require_relative './sp_aplus_content_2020/models/message_set'
# 
# 
# require_relative './sp_aplus_content_2020/models/page_token'
# 
# 
# require_relative './sp_aplus_content_2020/models/paragraph_component'
# 
# 
# require_relative './sp_aplus_content_2020/models/plain_text_item'
# 
# 
# require_relative './sp_aplus_content_2020/models/position_type'
# 
# 
# require_relative './sp_aplus_content_2020/models/post_content_document_approval_submission_response'
# 
# 
# require_relative './sp_aplus_content_2020/models/post_content_document_asin_relations_request'
# 
# 
# require_relative './sp_aplus_content_2020/models/post_content_document_asin_relations_response'
# 
# 
# require_relative './sp_aplus_content_2020/models/post_content_document_request'
# 
# 
# require_relative './sp_aplus_content_2020/models/post_content_document_response'
# 
# 
# require_relative './sp_aplus_content_2020/models/post_content_document_suspend_submission_response'
# 
# 
# require_relative './sp_aplus_content_2020/models/publish_record'
# 
# 
# require_relative './sp_aplus_content_2020/models/publish_record_list'
# 
# 
# require_relative './sp_aplus_content_2020/models/search_content_documents_response'
# 
# 
# require_relative './sp_aplus_content_2020/models/search_content_publish_records_response'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_company_logo_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_comparison_product_block'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_comparison_table_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_four_image_text_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_four_image_text_quadrant_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_header_image_text_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_header_text_list_block'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_image_caption_block'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_image_sidebar_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_image_text_block'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_image_text_caption_block'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_image_text_overlay_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_multiple_image_text_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_product_description_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_single_image_highlights_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_single_image_specs_detail_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_single_side_image_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_tech_specs_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_text_block'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_text_list_block'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_text_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_text_pair_block'
# 
# 
# require_relative './sp_aplus_content_2020/models/standard_three_image_text_module'
# 
# 
# require_relative './sp_aplus_content_2020/models/text_component'
# 
# 
# require_relative './sp_aplus_content_2020/models/text_item'
# 
# 
# require_relative './sp_aplus_content_2020/models/validate_content_document_asin_relations_response'
# 

# APIs
require_relative './sp_aplus_content_2020/api/aplus_content_api'
