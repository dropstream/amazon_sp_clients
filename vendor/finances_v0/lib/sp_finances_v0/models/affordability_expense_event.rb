=begin
#Selling Partner API for Finances

#The Selling Partner API for Finances helps you obtain financial information relevant to a seller's business. You can obtain financial events for a given order, financial event group, or date range without having to wait until a statement period closes. You can also obtain financial event groups for a given date range.

OpenAPI spec version: v0

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.26
=end

require 'date'

module AmazonSpClients
  module SpFinancesV0
    # An expense related to an affordability promotion.
    class AffordabilityExpenseEvent
      # An Amazon-defined identifier for an order.
      attr_accessor :amazon_order_id
  
      attr_accessor :posted_date
  
      # An encrypted, Amazon-defined marketplace identifier.
      attr_accessor :marketplace_id
  
      # Indicates the type of transaction.   Possible values:  * Charge - For an affordability promotion expense.  * Refund - For an affordability promotion expense reversal.
      attr_accessor :transaction_type
  
      attr_accessor :base_expense
  
      attr_accessor :tax_type_cgst
  
      attr_accessor :tax_type_sgst
  
      attr_accessor :tax_type_igst
  
      attr_accessor :total_expense
  
      # Attribute mapping from ruby-style variable name to JSON key.
      def self.attribute_map
        {
          :'amazon_order_id' => :'AmazonOrderId',
          :'posted_date' => :'PostedDate',
          :'marketplace_id' => :'MarketplaceId',
          :'transaction_type' => :'TransactionType',
          :'base_expense' => :'BaseExpense',
          :'tax_type_cgst' => :'TaxTypeCGST',
          :'tax_type_sgst' => :'TaxTypeSGST',
          :'tax_type_igst' => :'TaxTypeIGST',
          :'total_expense' => :'TotalExpense'
        }
      end
  
      # Attribute type mapping.
      def self.openapi_types
        {
          :'amazon_order_id' => :'Object',
          :'posted_date' => :'Object',
          :'marketplace_id' => :'Object',
          :'transaction_type' => :'Object',
          :'base_expense' => :'Object',
          :'tax_type_cgst' => :'Object',
          :'tax_type_sgst' => :'Object',
          :'tax_type_igst' => :'Object',
          :'total_expense' => :'Object'
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
          fail ArgumentError, "The input argument (attributes) must be a hash in `AmazonSpClients::SpFinancesV0::AffordabilityExpenseEvent` initialize method"
        end
  
        # check to see if the attribute exists and convert string to symbol for hash key
        attributes = attributes.each_with_object({}) { |(k, v), h|
          if (!self.class.attribute_map.key?(k.to_sym))
            fail ArgumentError, "`#{k}` is not a valid attribute in `AmazonSpClients::SpFinancesV0::AffordabilityExpenseEvent`. Please check the name to make sure it's valid. List of attributes: " + self.class.attribute_map.keys.inspect
          end
          h[k.to_sym] = v
        }
  
        if attributes.key?(:'amazon_order_id')
          self.amazon_order_id = attributes[:'amazon_order_id']
        end
  
        if attributes.key?(:'posted_date')
          self.posted_date = attributes[:'posted_date']
        end
  
        if attributes.key?(:'marketplace_id')
          self.marketplace_id = attributes[:'marketplace_id']
        end
  
        if attributes.key?(:'transaction_type')
          self.transaction_type = attributes[:'transaction_type']
        end
  
        if attributes.key?(:'base_expense')
          self.base_expense = attributes[:'base_expense']
        end
  
        if attributes.key?(:'tax_type_cgst')
          self.tax_type_cgst = attributes[:'tax_type_cgst']
        end
  
        if attributes.key?(:'tax_type_sgst')
          self.tax_type_sgst = attributes[:'tax_type_sgst']
        end
  
        if attributes.key?(:'tax_type_igst')
          self.tax_type_igst = attributes[:'tax_type_igst']
        end
  
        if attributes.key?(:'total_expense')
          self.total_expense = attributes[:'total_expense']
        end
      end
  
      # Show invalid properties with the reasons. Usually used together with valid?
      # @return Array for valid properties with the reasons
      def list_invalid_properties
        invalid_properties = Array.new
        if @tax_type_cgst.nil?
          invalid_properties.push('invalid value for "tax_type_cgst", tax_type_cgst cannot be nil.')
        end
  
        if @tax_type_sgst.nil?
          invalid_properties.push('invalid value for "tax_type_sgst", tax_type_sgst cannot be nil.')
        end
  
        if @tax_type_igst.nil?
          invalid_properties.push('invalid value for "tax_type_igst", tax_type_igst cannot be nil.')
        end
  
        invalid_properties
      end
  
      # Check to see if the all the properties in the model are valid
      # @return true if the model is valid
      def valid?
        return false if @tax_type_cgst.nil?
        return false if @tax_type_sgst.nil?
        return false if @tax_type_igst.nil?
        true
      end
  
      # Checks equality by comparing each attribute.
      # @param [Object] Object to be compared
      def ==(o)
        return true if self.equal?(o)
        self.class == o.class &&
            amazon_order_id == o.amazon_order_id &&
            posted_date == o.posted_date &&
            marketplace_id == o.marketplace_id &&
            transaction_type == o.transaction_type &&
            base_expense == o.base_expense &&
            tax_type_cgst == o.tax_type_cgst &&
            tax_type_sgst == o.tax_type_sgst &&
            tax_type_igst == o.tax_type_igst &&
            total_expense == o.total_expense
      end
  
      # @see the `==` method
      # @param [Object] Object to be compared
      def eql?(o)
        self == o
      end
  
      # Calculates hash code according to all attributes.
      # @return [Integer] Hash code
      def hash
        [amazon_order_id, posted_date, marketplace_id, transaction_type, base_expense, tax_type_cgst, tax_type_sgst, tax_type_igst, total_expense].hash
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
          AmazonSpClients::SpFinancesV0.const_get(type).build_from_hash(value)
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
