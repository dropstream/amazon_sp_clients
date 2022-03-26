=begin
#Selling Partner API for Direct Fulfillment Shipping

#The Selling Partner API for Direct Fulfillment Shipping provides programmatic access to a direct fulfillment vendor's shipping data.

OpenAPI spec version: v1

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.33
=end

require 'date'

module AmazonSpClients
  module SpVdfShippingV1
    # Details about a shipment.
    class ShipmentDetails
      # This field indicates the date of the departure of the shipment from vendor's location. Vendors are requested to send ASNs within 30 minutes of departure from their warehouse/distribution center or at least 6 hours prior to the appointment time at the Amazon destination warehouse, whichever is sooner. Shipped date mentioned in the Shipment Confirmation should not be in the future.
      attr_accessor :shipped_date
  
      # Indicate the shipment status.
      attr_accessor :shipment_status
  
      # Provide the priority of the shipment.
      attr_accessor :is_priority_shipment
  
      # The vendor order number is a unique identifier generated by a vendor for their reference.
      attr_accessor :vendor_order_number
  
      # Date on which the shipment is expected to reach the buyer's warehouse. It needs to be an estimate based on the average transit time between the ship-from location and the destination. The exact appointment time will be provided by buyer and is potentially not known when creating the shipment confirmation.
      attr_accessor :estimated_delivery_date
  
      class EnumAttributeValidator
        attr_reader :datatype
        attr_reader :allowable_values
  
        def initialize(datatype, allowable_values)
          @allowable_values = allowable_values.map do |value|
            case datatype.to_s
            when /Integer/i
              value.to_i
            when /Float/i
              value.to_f
            else
              value
            end
          end
        end
  
        def valid?(value)
          !value || allowable_values.include?(value)
        end
      end
  
      # Attribute mapping from ruby-style variable name to JSON key.
      def self.attribute_map
        {
          :'shipped_date' => :'shippedDate',
          :'shipment_status' => :'shipmentStatus',
          :'is_priority_shipment' => :'isPriorityShipment',
          :'vendor_order_number' => :'vendorOrderNumber',
          :'estimated_delivery_date' => :'estimatedDeliveryDate'
        }
      end
  
      # Attribute type mapping.
      def self.openapi_types
        {
          :'shipped_date' => :'Object',
          :'shipment_status' => :'Object',
          :'is_priority_shipment' => :'Object',
          :'vendor_order_number' => :'Object',
          :'estimated_delivery_date' => :'Object'
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
          fail ArgumentError, "The input argument (attributes) must be a hash in `AmazonSpClients::SpVdfShippingV1::ShipmentDetails` initialize method"
        end
  
        # check to see if the attribute exists and convert string to symbol for hash key
        attributes = attributes.each_with_object({}) { |(k, v), h|
          if (!self.class.attribute_map.key?(k.to_sym))
            fail ArgumentError, "`#{k}` is not a valid attribute in `AmazonSpClients::SpVdfShippingV1::ShipmentDetails`. Please check the name to make sure it's valid. List of attributes: " + self.class.attribute_map.keys.inspect
          end
          h[k.to_sym] = v
        }
  
        if attributes.key?(:'shipped_date')
          self.shipped_date = attributes[:'shipped_date']
        end
  
        if attributes.key?(:'shipment_status')
          self.shipment_status = attributes[:'shipment_status']
        end
  
        if attributes.key?(:'is_priority_shipment')
          self.is_priority_shipment = attributes[:'is_priority_shipment']
        end
  
        if attributes.key?(:'vendor_order_number')
          self.vendor_order_number = attributes[:'vendor_order_number']
        end
  
        if attributes.key?(:'estimated_delivery_date')
          self.estimated_delivery_date = attributes[:'estimated_delivery_date']
        end
      end
  
      # Show invalid properties with the reasons. Usually used together with valid?
      # @return Array for valid properties with the reasons
      def list_invalid_properties
        invalid_properties = Array.new
        if @shipped_date.nil?
          invalid_properties.push('invalid value for "shipped_date", shipped_date cannot be nil.')
        end
  
        if @shipment_status.nil?
          invalid_properties.push('invalid value for "shipment_status", shipment_status cannot be nil.')
        end
  
        invalid_properties
      end
  
      # Check to see if the all the properties in the model are valid
      # @return true if the model is valid
      def valid?
        return false if @shipped_date.nil?
        return false if @shipment_status.nil?
        shipment_status_validator = EnumAttributeValidator.new('Object', ['SHIPPED', 'FLOOR_DENIAL'])
        return false unless shipment_status_validator.valid?(@shipment_status)
        true
      end
  
      # Custom attribute writer method checking allowed values (enum).
      # @param [Object] shipment_status Object to be assigned
      def shipment_status=(shipment_status)
        validator = EnumAttributeValidator.new('Object', ['SHIPPED', 'FLOOR_DENIAL'])
        unless validator.valid?(shipment_status)
          fail ArgumentError, "invalid value for \"shipment_status\", must be one of #{validator.allowable_values}."
        end
        @shipment_status = shipment_status
      end
  
      # Checks equality by comparing each attribute.
      # @param [Object] Object to be compared
      def ==(o)
        return true if self.equal?(o)
        self.class == o.class &&
            shipped_date == o.shipped_date &&
            shipment_status == o.shipment_status &&
            is_priority_shipment == o.is_priority_shipment &&
            vendor_order_number == o.vendor_order_number &&
            estimated_delivery_date == o.estimated_delivery_date
      end
  
      # @see the `==` method
      # @param [Object] Object to be compared
      def eql?(o)
        self == o
      end
  
      # Calculates hash code according to all attributes.
      # @return [Integer] Hash code
      def hash
        [shipped_date, shipment_status, is_priority_shipment, vendor_order_number, estimated_delivery_date].hash
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
          AmazonSpClients::SpVdfShippingV1.const_get(type).build_from_hash(value)
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
