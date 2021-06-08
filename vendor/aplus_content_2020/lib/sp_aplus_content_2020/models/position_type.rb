=begin
#Selling Partner API for A+ Content Management

#With the A+ Content API, you can build applications that help selling partners add rich marketing content to their Amazon product detail pages. A+ content helps selling partners share their brand and product story, which helps buyers make informed purchasing decisions. Selling partners assemble content by choosing from content modules and adding images and text.

OpenAPI spec version: 2020-11-01

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

require 'date'

module AmazonSpClients
  module SpAplusContent2020
    class PositionType
      LEFT = 'LEFT'.freeze
      RIGHT = 'RIGHT'.freeze
  
      # Builds the enum from string
      # @param [String] The enum value in the form of the string
      # @return [String] The enum value
      def build_from_hash(value)
        constantValues = PositionType.constants.select { |c| PositionType::const_get(c) == value }
        raise "Invalid ENUM value #{value} for class #PositionType" if constantValues.empty?
        value
      end
    end
  end
end
