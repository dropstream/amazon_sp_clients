=begin
#Selling Partner API for Pricing

#The Selling Partner API for Pricing helps you programmatically retrieve product pricing and offer information for Amazon Marketplace products.

OpenAPI spec version: v0

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.26
=end

require 'date'

module AmazonSpClients
  module SpProductPricingV0
    # Contains price information about the product, including the LowestPrices and BuyBoxPrices, the ListPrice, the SuggestedLowerPricePlusShipping, and NumberOfOffers and NumberOfBuyBoxEligibleOffers.
    class Summary
      # The number of unique offers contained in NumberOfOffers.
      attr_accessor :total_offer_count
  
      attr_accessor :number_of_offers
  
      attr_accessor :lowest_prices
  
      attr_accessor :buy_box_prices
  
      attr_accessor :list_price
  
      attr_accessor :suggested_lower_price_plus_shipping
  
      attr_accessor :buy_box_eligible_offers
  
      # When the status is ActiveButTooSoonForProcessing, this is the time when the offers will be available for processing.
      attr_accessor :offers_available_time
  
      # Attribute mapping from ruby-style variable name to JSON key.
      def self.attribute_map
        {
          :'total_offer_count' => :'TotalOfferCount',
          :'number_of_offers' => :'NumberOfOffers',
          :'lowest_prices' => :'LowestPrices',
          :'buy_box_prices' => :'BuyBoxPrices',
          :'list_price' => :'ListPrice',
          :'suggested_lower_price_plus_shipping' => :'SuggestedLowerPricePlusShipping',
          :'buy_box_eligible_offers' => :'BuyBoxEligibleOffers',
          :'offers_available_time' => :'OffersAvailableTime'
        }
      end
  
      # Attribute type mapping.
      def self.openapi_types
        {
          :'total_offer_count' => :'Object',
          :'number_of_offers' => :'Object',
          :'lowest_prices' => :'Object',
          :'buy_box_prices' => :'Object',
          :'list_price' => :'Object',
          :'suggested_lower_price_plus_shipping' => :'Object',
          :'buy_box_eligible_offers' => :'Object',
          :'offers_available_time' => :'Object'
        }
      end
  
      # List of attributes with nullable: true
      def self.openapi_nullable
        Set.new([
        ])
      end
    
      # Initializes the object
      # @param [Hash] attributes Model attributes in the form of hash
      def initialize(attributes = {})
        if (!attributes.is_a?(Hash))
          fail ArgumentError, "The input argument (attributes) must be a hash in `AmazonSpClients::SpProductPricingV0::Summary` initialize method"
        end
  
        # check to see if the attribute exists and convert string to symbol for hash key
        attributes = attributes.each_with_object({}) { |(k, v), h|
          if (!self.class.attribute_map.key?(k.to_sym))
            fail ArgumentError, "`#{k}` is not a valid attribute in `AmazonSpClients::SpProductPricingV0::Summary`. Please check the name to make sure it's valid. List of attributes: " + self.class.attribute_map.keys.inspect
          end
          h[k.to_sym] = v
        }
  
        if attributes.key?(:'total_offer_count')
          self.total_offer_count = attributes[:'total_offer_count']
        end
  
        if attributes.key?(:'number_of_offers')
          self.number_of_offers = attributes[:'number_of_offers']
        end
  
        if attributes.key?(:'lowest_prices')
          self.lowest_prices = attributes[:'lowest_prices']
        end
  
        if attributes.key?(:'buy_box_prices')
          self.buy_box_prices = attributes[:'buy_box_prices']
        end
  
        if attributes.key?(:'list_price')
          self.list_price = attributes[:'list_price']
        end
  
        if attributes.key?(:'suggested_lower_price_plus_shipping')
          self.suggested_lower_price_plus_shipping = attributes[:'suggested_lower_price_plus_shipping']
        end
  
        if attributes.key?(:'buy_box_eligible_offers')
          self.buy_box_eligible_offers = attributes[:'buy_box_eligible_offers']
        end
  
        if attributes.key?(:'offers_available_time')
          self.offers_available_time = attributes[:'offers_available_time']
        end
      end
  
      # Show invalid properties with the reasons. Usually used together with valid?
      # @return Array for valid properties with the reasons
      def list_invalid_properties
        invalid_properties = Array.new
        if @total_offer_count.nil?
          invalid_properties.push('invalid value for "total_offer_count", total_offer_count cannot be nil.')
        end
  
        invalid_properties
      end
  
      # Check to see if the all the properties in the model are valid
      # @return true if the model is valid
      def valid?
        return false if @total_offer_count.nil?
        true
      end
  
      # Checks equality by comparing each attribute.
      # @param [Object] Object to be compared
      def ==(o)
        return true if self.equal?(o)
        self.class == o.class &&
            total_offer_count == o.total_offer_count &&
            number_of_offers == o.number_of_offers &&
            lowest_prices == o.lowest_prices &&
            buy_box_prices == o.buy_box_prices &&
            list_price == o.list_price &&
            suggested_lower_price_plus_shipping == o.suggested_lower_price_plus_shipping &&
            buy_box_eligible_offers == o.buy_box_eligible_offers &&
            offers_available_time == o.offers_available_time
      end
  
      # @see the `==` method
      # @param [Object] Object to be compared
      def eql?(o)
        self == o
      end
  
      # Calculates hash code according to all attributes.
      # @return [Integer] Hash code
      def hash
        [total_offer_count, number_of_offers, lowest_prices, buy_box_prices, list_price, suggested_lower_price_plus_shipping, buy_box_eligible_offers, offers_available_time].hash
      end
  
      # Builds the object from hash
      # @param [Hash] attributes Model attributes in the form of hash
      # @return [Object] Returns the model itself
      def self.build_from_hash(attributes)
        new.build_from_hash(attributes)
      end
  
      # Builds the object from hash
      # @param [Hash] attributes Model attributes in the form of hash
      # @return [Object] Returns the model itself
      def build_from_hash(attributes)
        return nil unless attributes.is_a?(Hash)
        self.class.openapi_types.each_pair do |key, type|
          if type =~ /\AArray<(.*)>/i
            # check to ensure the input is an array given that the attribute
            # is documented as an array but the input is not
            if attributes[self.class.attribute_map[key]].is_a?(Array)
              self.send("#{key}=", attributes[self.class.attribute_map[key]].map { |v| _deserialize($1, v) })
            end
          elsif !attributes[self.class.attribute_map[key]].nil?
            self.send("#{key}=", _deserialize(type, attributes[self.class.attribute_map[key]]))
          elsif attributes[self.class.attribute_map[key]].nil? && self.class.openapi_nullable.include?(key)
            self.send("#{key}=", nil)
          end
        end
  
        self
      end
  
      # Deserializes the data based on type
      # @param string type Data type
      # @param string value Value to be deserialized
      # @return [Object] Deserialized data
      def _deserialize(type, value)
        case type.to_sym
        when :DateTime
          DateTime.parse(value)
        when :Date
          Date.parse(value)
        when :String
          value.to_s
        when :Integer
          value.to_i
        when :Float
          value.to_f
        when :Boolean
          if value.to_s =~ /\A(true|t|yes|y|1)\z/i
            true
          else
            false
          end
        when :Object
          # generic object (usually a Hash), return directly
          value
        when /\AArray<(?<inner_type>.+)>\z/
          inner_type = Regexp.last_match[:inner_type]
          value.map { |v| _deserialize(inner_type, v) }
        when /\AHash<(?<k_type>.+?), (?<v_type>.+)>\z/
          k_type = Regexp.last_match[:k_type]
          v_type = Regexp.last_match[:v_type]
          {}.tap do |hash|
            value.each do |k, v|
              hash[_deserialize(k_type, k)] = _deserialize(v_type, v)
            end
          end
        else # model
          AmazonSpClients::SpProductPricingV0.const_get(type).build_from_hash(value)
        end
      end
  
      # Returns the string representation of the object
      # @return [String] String presentation of the object
      def to_s
        to_hash.to_s
      end
  
      # to_body is an alias to to_hash (backward compatibility)
      # @return [Hash] Returns the object in the form of hash
      def to_body
        to_hash
      end
  
      # Returns the object in the form of hash
      # @return [Hash] Returns the object in the form of hash
      def to_hash
        hash = {}
        self.class.attribute_map.each_pair do |attr, param|
          value = self.send(attr)
          if value.nil?
            is_nullable = self.class.openapi_nullable.include?(attr)
            next if !is_nullable || (is_nullable && !instance_variable_defined?(:"@#{attr}"))
          end
  
          hash[param] = _to_hash(value)
        end
        hash
      end
  
      # Outputs non-array value in the form of hash
      # For object, use to_hash. Otherwise, just return the value
      # @param [Object] value Any valid value
      # @return [Hash] Returns the value in the form of hash
      def _to_hash(value)
        if value.is_a?(Array)
          value.compact.map { |v| _to_hash(v) }
        elsif value.is_a?(Hash)
          {}.tap do |hash|
            value.each { |k, v| hash[k] = _to_hash(v) }
          end
        elsif value.respond_to? :to_hash
          value.to_hash
        else
          value
        end
      end
    end

  end
end
