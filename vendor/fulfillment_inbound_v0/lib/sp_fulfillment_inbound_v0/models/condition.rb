=begin
#Selling Partner API for Fulfillment Inbound

#The Selling Partner API for Fulfillment Inbound lets you create applications that create and update inbound shipments of inventory to Amazon's fulfillment network.

OpenAPI spec version: v0

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

require 'date'

module AmazonSpClients
  module SpFulfillmentInboundV0
    class Condition
      NEW_ITEM = 'NewItem'.freeze
      NEW_WITH_WARRANTY = 'NewWithWarranty'.freeze
      NEW_OEM = 'NewOEM'.freeze
      NEW_OPEN_BOX = 'NewOpenBox'.freeze
      USED_LIKE_NEW = 'UsedLikeNew'.freeze
      USED_VERY_GOOD = 'UsedVeryGood'.freeze
      USED_GOOD = 'UsedGood'.freeze
      USED_ACCEPTABLE = 'UsedAcceptable'.freeze
      USED_POOR = 'UsedPoor'.freeze
      USED_REFURBISHED = 'UsedRefurbished'.freeze
      COLLECTIBLE_LIKE_NEW = 'CollectibleLikeNew'.freeze
      COLLECTIBLE_VERY_GOOD = 'CollectibleVeryGood'.freeze
      COLLECTIBLE_GOOD = 'CollectibleGood'.freeze
      COLLECTIBLE_ACCEPTABLE = 'CollectibleAcceptable'.freeze
      COLLECTIBLE_POOR = 'CollectiblePoor'.freeze
      REFURBISHED_WITH_WARRANTY = 'RefurbishedWithWarranty'.freeze
      REFURBISHED = 'Refurbished'.freeze
      CLUB = 'Club'.freeze
  
      # Builds the enum from string
      # @param [String] The enum value in the form of the string
      # @return [String] The enum value
      def build_from_hash(value)
        constantValues = Condition.constants.select { |c| Condition::const_get(c) == value }
        raise "Invalid ENUM value #{value} for class #Condition" if constantValues.empty?
        value
      end
    end
  end
end
