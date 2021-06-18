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
    class CompetitivePriceType
      # The pricing model for each price that is returned.  Possible values:  * 1 - New Buy Box Price. * 2 - Used Buy Box Price.
      attr_accessor :competitive_price_id
  
      attr_accessor :price
  
      # Indicates the condition of the item whose pricing information is returned. Possible values are: New, Used, Collectible, Refurbished, or Club.
      attr_accessor :condition
  
      # Indicates the subcondition of the item whose pricing information is returned. Possible values are: New, Mint, Very Good, Good, Acceptable, Poor, Club, OEM, Warranty, Refurbished Warranty, Refurbished, Open Box, or Other.
      attr_accessor :subcondition
  
      attr_accessor :offer_type
  
      # Indicates at what quantity this price becomes active.
      attr_accessor :quantity_tier
  
      attr_accessor :quantity_discount_type
  
      # The seller identifier for the offer.
      attr_accessor :seller_id
  
      #  Indicates whether or not the pricing information is for an offer listing that belongs to the requester. The requester is the seller associated with the SellerId that was submitted with the request. Possible values are: true and false.
      attr_accessor :belongs_to_requester
  
      # Attribute mapping from ruby-style variable name to JSON key.
      def self.attribute_map
        {
          :'competitive_price_id' => :'CompetitivePriceId',
          :'price' => :'Price',
          :'condition' => :'condition',
          :'subcondition' => :'subcondition',
          :'offer_type' => :'offerType',
          :'quantity_tier' => :'quantityTier',
          :'quantity_discount_type' => :'quantityDiscountType',
          :'seller_id' => :'sellerId',
          :'belongs_to_requester' => :'belongsToRequester'
        }
      end
  
      # Attribute type mapping.
      def self.openapi_types
        {
          :'competitive_price_id' => :'Object',
          :'price' => :'Object',
          :'condition' => :'Object',
          :'subcondition' => :'Object',
          :'offer_type' => :'Object',
          :'quantity_tier' => :'Object',
          :'quantity_discount_type' => :'Object',
          :'seller_id' => :'Object',
          :'belongs_to_requester' => :'Object'
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
          fail ArgumentError, "The input argument (attributes) must be a hash in `AmazonSpClients::SpProductPricingV0::CompetitivePriceType` initialize method"
        end
  
        # check to see if the attribute exists and convert string to symbol for hash key
        attributes = attributes.each_with_object({}) { |(k, v), h|
          if (!self.class.attribute_map.key?(k.to_sym))
            fail ArgumentError, "`#{k}` is not a valid attribute in `AmazonSpClients::SpProductPricingV0::CompetitivePriceType`. Please check the name to make sure it's valid. List of attributes: " + self.class.attribute_map.keys.inspect
          end
          h[k.to_sym] = v
        }
  
        if attributes.key?(:'competitive_price_id')
          self.competitive_price_id = attributes[:'competitive_price_id']
        end
  
        if attributes.key?(:'price')
          self.price = attributes[:'price']
        end
  
        if attributes.key?(:'condition')
          self.condition = attributes[:'condition']
        end
  
        if attributes.key?(:'subcondition')
          self.subcondition = attributes[:'subcondition']
        end
  
        if attributes.key?(:'offer_type')
          self.offer_type = attributes[:'offer_type']
        end
  
        if attributes.key?(:'quantity_tier')
          self.quantity_tier = attributes[:'quantity_tier']
        end
  
        if attributes.key?(:'quantity_discount_type')
          self.quantity_discount_type = attributes[:'quantity_discount_type']
        end
  
        if attributes.key?(:'seller_id')
          self.seller_id = attributes[:'seller_id']
        end
  
        if attributes.key?(:'belongs_to_requester')
          self.belongs_to_requester = attributes[:'belongs_to_requester']
        end
      end
  
      # Show invalid properties with the reasons. Usually used together with valid?
      # @return Array for valid properties with the reasons
      def list_invalid_properties
        invalid_properties = Array.new
        if @competitive_price_id.nil?
          invalid_properties.push('invalid value for "competitive_price_id", competitive_price_id cannot be nil.')
        end
  
        if @price.nil?
          invalid_properties.push('invalid value for "price", price cannot be nil.')
        end
  
        invalid_properties
      end
  
      # Check to see if the all the properties in the model are valid
      # @return true if the model is valid
      def valid?
        return false if @competitive_price_id.nil?
        return false if @price.nil?
        true
      end
  
      # Checks equality by comparing each attribute.
      # @param [Object] Object to be compared
      def ==(o)
        return true if self.equal?(o)
        self.class == o.class &&
            competitive_price_id == o.competitive_price_id &&
            price == o.price &&
            condition == o.condition &&
            subcondition == o.subcondition &&
            offer_type == o.offer_type &&
            quantity_tier == o.quantity_tier &&
            quantity_discount_type == o.quantity_discount_type &&
            seller_id == o.seller_id &&
            belongs_to_requester == o.belongs_to_requester
      end
  
      # @see the `==` method
      # @param [Object] Object to be compared
      def eql?(o)
        self == o
      end
  
      # Calculates hash code according to all attributes.
      # @return [Integer] Hash code
      def hash
        [competitive_price_id, price, condition, subcondition, offer_type, quantity_tier, quantity_discount_type, seller_id, belongs_to_requester].hash
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
