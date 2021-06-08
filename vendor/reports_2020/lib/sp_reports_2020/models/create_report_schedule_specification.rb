=begin
#Selling Partner API for Reports

#The Selling Partner API for Reports lets you retrieve and manage a variety of reports that can help selling partners manage their businesses.

OpenAPI spec version: 2020-09-04

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.25
=end

require 'date'

module AmazonSpClients
  module SpReports2020
    class CreateReportScheduleSpecification
      # The report type.
      attr_accessor :report_type
  
      # A list of marketplace identifiers for the report schedule.
      attr_accessor :marketplace_ids
  
      attr_accessor :report_options
  
      # One of a set of predefined ISO 8601 periods that specifies how often a report should be created.
      attr_accessor :period
  
      # The date and time when the schedule will create its next report, in ISO 8601 date time format.
      attr_accessor :next_report_creation_time
  
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
          :'report_type' => :'reportType',
          :'marketplace_ids' => :'marketplaceIds',
          :'report_options' => :'reportOptions',
          :'period' => :'period',
          :'next_report_creation_time' => :'nextReportCreationTime'
        }
      end
  
      # Attribute type mapping.
      def self.openapi_types
        {
          :'report_type' => :'Object',
          :'marketplace_ids' => :'Object',
          :'report_options' => :'Object',
          :'period' => :'Object',
          :'next_report_creation_time' => :'Object'
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
          fail ArgumentError, "The input argument (attributes) must be a hash in `AmazonSpClients::SpReports2020::CreateReportScheduleSpecification` initialize method"
        end
  
        # check to see if the attribute exists and convert string to symbol for hash key
        attributes = attributes.each_with_object({}) { |(k, v), h|
          if (!self.class.attribute_map.key?(k.to_sym))
            fail ArgumentError, "`#{k}` is not a valid attribute in `AmazonSpClients::SpReports2020::CreateReportScheduleSpecification`. Please check the name to make sure it's valid. List of attributes: " + self.class.attribute_map.keys.inspect
          end
          h[k.to_sym] = v
        }
  
        if attributes.key?(:'report_type')
          self.report_type = attributes[:'report_type']
        end
  
        if attributes.key?(:'marketplace_ids')
          if (value = attributes[:'marketplace_ids']).is_a?(Array)
            self.marketplace_ids = value
          end
        end
  
        if attributes.key?(:'report_options')
          self.report_options = attributes[:'report_options']
        end
  
        if attributes.key?(:'period')
          self.period = attributes[:'period']
        end
  
        if attributes.key?(:'next_report_creation_time')
          self.next_report_creation_time = attributes[:'next_report_creation_time']
        end
      end
  
      # Show invalid properties with the reasons. Usually used together with valid?
      # @return Array for valid properties with the reasons
      def list_invalid_properties
        invalid_properties = Array.new
        if @report_type.nil?
          invalid_properties.push('invalid value for "report_type", report_type cannot be nil.')
        end
  
        if @marketplace_ids.nil?
          invalid_properties.push('invalid value for "marketplace_ids", marketplace_ids cannot be nil.')
        end
  
        if @period.nil?
          invalid_properties.push('invalid value for "period", period cannot be nil.')
        end
  
        invalid_properties
      end
  
      # Check to see if the all the properties in the model are valid
      # @return true if the model is valid
      def valid?
        return false if @report_type.nil?
        return false if @marketplace_ids.nil?
        return false if @period.nil?
        period_validator = EnumAttributeValidator.new('Object', ['PT5M', 'PT15M', 'PT30M', 'PT1H', 'PT2H', 'PT4H', 'PT8H', 'PT12H', 'P1D', 'P2D', 'P3D', 'PT84H', 'P7D', 'P14D', 'P15D', 'P18D', 'P30D', 'P1M'])
        return false unless period_validator.valid?(@period)
        true
      end
  
      # Custom attribute writer method checking allowed values (enum).
      # @param [Object] period Object to be assigned
      def period=(period)
        validator = EnumAttributeValidator.new('Object', ['PT5M', 'PT15M', 'PT30M', 'PT1H', 'PT2H', 'PT4H', 'PT8H', 'PT12H', 'P1D', 'P2D', 'P3D', 'PT84H', 'P7D', 'P14D', 'P15D', 'P18D', 'P30D', 'P1M'])
        unless validator.valid?(period)
          fail ArgumentError, "invalid value for \"period\", must be one of #{validator.allowable_values}."
        end
        @period = period
      end
  
      # Checks equality by comparing each attribute.
      # @param [Object] Object to be compared
      def ==(o)
        return true if self.equal?(o)
        self.class == o.class &&
            report_type == o.report_type &&
            marketplace_ids == o.marketplace_ids &&
            report_options == o.report_options &&
            period == o.period &&
            next_report_creation_time == o.next_report_creation_time
      end
  
      # @see the `==` method
      # @param [Object] Object to be compared
      def eql?(o)
        self == o
      end
  
      # Calculates hash code according to all attributes.
      # @return [Integer] Hash code
      def hash
        [report_type, marketplace_ids, report_options, period, next_report_creation_time].hash
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
          AmazonSpClients::SpReports2020.const_get(type).build_from_hash(value)
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
