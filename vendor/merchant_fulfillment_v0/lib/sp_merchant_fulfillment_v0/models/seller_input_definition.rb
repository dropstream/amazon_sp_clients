=begin
#Selling Partner API for Merchant Fulfillment

#The Selling Partner API for Merchant Fulfillment helps you build applications that let sellers purchase shipping for non-Prime and Prime orders using Amazon’s Buy Shipping Services.

OpenAPI spec version: v0

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.26
=end

require 'date'

module AmazonSpClients
  module SpMerchantFulfillmentV0
    # Specifies characteristics that apply to a seller input.
    class SellerInputDefinition
      # When true, the additional input field is required.
      attr_accessor :is_required
  
      # The data type of the additional input field.
      attr_accessor :data_type
  
      attr_accessor :constraints
  
      # The display text for the additional input field.
      attr_accessor :input_display_text
  
      attr_accessor :input_target
  
      attr_accessor :stored_value
  
      attr_accessor :restricted_set_values
  
      # Attribute mapping from ruby-style variable name to JSON key.
      def self.attribute_map
        {
          :'is_required' => :'IsRequired',
          :'data_type' => :'DataType',
          :'constraints' => :'Constraints',
          :'input_display_text' => :'InputDisplayText',
          :'input_target' => :'InputTarget',
          :'stored_value' => :'StoredValue',
          :'restricted_set_values' => :'RestrictedSetValues'
        }
      end
  
      # Attribute type mapping.
      def self.openapi_types
        {
          :'is_required' => :'Object',
          :'data_type' => :'Object',
          :'constraints' => :'Object',
          :'input_display_text' => :'Object',
          :'input_target' => :'Object',
          :'stored_value' => :'Object',
          :'restricted_set_values' => :'Object'
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
          fail ArgumentError, "The input argument (attributes) must be a hash in `AmazonSpClients::SpMerchantFulfillmentV0::SellerInputDefinition` initialize method"
        end
  
        # check to see if the attribute exists and convert string to symbol for hash key
        attributes = attributes.each_with_object({}) { |(k, v), h|
          if (!self.class.attribute_map.key?(k.to_sym))
            fail ArgumentError, "`#{k}` is not a valid attribute in `AmazonSpClients::SpMerchantFulfillmentV0::SellerInputDefinition`. Please check the name to make sure it's valid. List of attributes: " + self.class.attribute_map.keys.inspect
          end
          h[k.to_sym] = v
        }
  
        if attributes.key?(:'is_required')
          self.is_required = attributes[:'is_required']
        end
  
        if attributes.key?(:'data_type')
          self.data_type = attributes[:'data_type']
        end
  
        if attributes.key?(:'constraints')
          self.constraints = attributes[:'constraints']
        end
  
        if attributes.key?(:'input_display_text')
          self.input_display_text = attributes[:'input_display_text']
        end
  
        if attributes.key?(:'input_target')
          self.input_target = attributes[:'input_target']
        end
  
        if attributes.key?(:'stored_value')
          self.stored_value = attributes[:'stored_value']
        end
  
        if attributes.key?(:'restricted_set_values')
          self.restricted_set_values = attributes[:'restricted_set_values']
        end
      end
  
      # Show invalid properties with the reasons. Usually used together with valid?
      # @return Array for valid properties with the reasons
      def list_invalid_properties
        invalid_properties = Array.new
        if @is_required.nil?
          invalid_properties.push('invalid value for "is_required", is_required cannot be nil.')
        end
  
        if @data_type.nil?
          invalid_properties.push('invalid value for "data_type", data_type cannot be nil.')
        end
  
        if @constraints.nil?
          invalid_properties.push('invalid value for "constraints", constraints cannot be nil.')
        end
  
        if @input_display_text.nil?
          invalid_properties.push('invalid value for "input_display_text", input_display_text cannot be nil.')
        end
  
        if @stored_value.nil?
          invalid_properties.push('invalid value for "stored_value", stored_value cannot be nil.')
        end
  
        invalid_properties
      end
  
      # Check to see if the all the properties in the model are valid
      # @return true if the model is valid
      def valid?
        return false if @is_required.nil?
        return false if @data_type.nil?
        return false if @constraints.nil?
        return false if @input_display_text.nil?
        return false if @stored_value.nil?
        true
      end
  
      # Checks equality by comparing each attribute.
      # @param [Object] Object to be compared
      def ==(o)
        return true if self.equal?(o)
        self.class == o.class &&
            is_required == o.is_required &&
            data_type == o.data_type &&
            constraints == o.constraints &&
            input_display_text == o.input_display_text &&
            input_target == o.input_target &&
            stored_value == o.stored_value &&
            restricted_set_values == o.restricted_set_values
      end
  
      # @see the `==` method
      # @param [Object] Object to be compared
      def eql?(o)
        self == o
      end
  
      # Calculates hash code according to all attributes.
      # @return [Integer] Hash code
      def hash
        [is_required, data_type, constraints, input_display_text, input_target, stored_value, restricted_set_values].hash
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
          AmazonSpClients::SpMerchantFulfillmentV0.const_get(type).build_from_hash(value)
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
