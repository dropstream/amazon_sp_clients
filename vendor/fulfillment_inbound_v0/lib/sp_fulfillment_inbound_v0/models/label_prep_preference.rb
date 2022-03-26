=begin
#Selling Partner API for Fulfillment Inbound

#The Selling Partner API for Fulfillment Inbound lets you create applications that create and update inbound shipments of inventory to Amazon's fulfillment network.

OpenAPI spec version: v0

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.33
=end

require 'date'

module AmazonSpClients
  module SpFulfillmentInboundV0
    class LabelPrepPreference
      SELLER_LABEL = 'SELLER_LABEL'.freeze
      AMAZON_LABEL_ONLY = 'AMAZON_LABEL_ONLY'.freeze
      AMAZON_LABEL_PREFERRED = 'AMAZON_LABEL_PREFERRED'.freeze
  
      # Builds the enum from string
      # @param [String] The enum value in the form of the string
      # @return [String] The enum value
      def build_from_hash(value)
        constantValues = LabelPrepPreference.constants.select { |c| LabelPrepPreference::const_get(c) == value }
        raise "Invalid ENUM value #{value} for class #LabelPrepPreference" if constantValues.empty?
        value
      end
    end
  end
end
