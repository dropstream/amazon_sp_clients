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
    class TransportStatus
      WORKING = 'WORKING'.freeze
      ESTIMATING = 'ESTIMATING'.freeze
      ESTIMATED = 'ESTIMATED'.freeze
      ERROR_ON_ESTIMATING = 'ERROR_ON_ESTIMATING'.freeze
      CONFIRMING = 'CONFIRMING'.freeze
      CONFIRMED = 'CONFIRMED'.freeze
      ERROR_ON_CONFIRMING = 'ERROR_ON_CONFIRMING'.freeze
      VOIDING = 'VOIDING'.freeze
      VOIDED = 'VOIDED'.freeze
      ERROR_IN_VOIDING = 'ERROR_IN_VOIDING'.freeze
      ERROR = 'ERROR'.freeze
  
      # Builds the enum from string
      # @param [String] The enum value in the form of the string
      # @return [String] The enum value
      def build_from_hash(value)
        constantValues = TransportStatus.constants.select { |c| TransportStatus::const_get(c) == value }
        raise "Invalid ENUM value #{value} for class #TransportStatus" if constantValues.empty?
        value
      end
    end
  end
end
