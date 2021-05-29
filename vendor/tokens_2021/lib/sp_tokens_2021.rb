=begin
#Selling Partner API for Tokens 

#The Selling Partner API for Tokens provides a secure way to access a customers's PII (Personally Identifiable Information). You can call the Tokens API to get a Restricted Data Token (RDT) for one or more restricted resources that you specify. The RDT authorizes you to make subsequent requests to access these restricted resources.

OpenAPI spec version: 2021-03-01

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

# # Common files
# require 'sp_tokens_2021/api_client'
# require 'sp_tokens_2021/api_error'
# require 'sp_tokens_2021/version'
# require 'sp_tokens_2021/configuration'

# Models
require_relative './sp_tokens_2021/models/create_restricted_data_token_request'
require_relative './sp_tokens_2021/models/create_restricted_data_token_response'
require_relative './sp_tokens_2021/models/error'
require_relative './sp_tokens_2021/models/error_list'
require_relative './sp_tokens_2021/models/restricted_resource'

# APIs
require_relative './sp_tokens_2021/api/tokens_api'
