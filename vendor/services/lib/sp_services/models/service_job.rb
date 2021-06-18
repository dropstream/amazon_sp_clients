=begin
#Selling Partner API for Services

#With the Services API, you can build applications that help service providers get and modify their service orders.

OpenAPI spec version: v1

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.26
=end

require 'date'

module AmazonSpClients
  module SpServices
    # The job details of a service.
    class ServiceJob
      # The date and time of the creation of the job, in ISO 8601 format.
      attr_accessor :create_time
  
      attr_accessor :service_job_id
  
      # The status of the service job.
      attr_accessor :service_job_status
  
      attr_accessor :scope_of_work
  
      attr_accessor :seller
  
      attr_accessor :service_job_provider
  
      # A list of appointment windows preferred by the buyer. Included only if the buyer selected appointment windows when creating the order.
      attr_accessor :preferred_appointment_times
  
      # A list of appointments.
      attr_accessor :appointments
  
      attr_accessor :service_order_id
  
      # The marketplace identifier.
      attr_accessor :marketplace_id
  
      attr_accessor :buyer
  
      # A list of items associated with the service job.
      attr_accessor :associated_items
  
      attr_accessor :service_location
  
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
          :'create_time' => :'createTime',
          :'service_job_id' => :'serviceJobId',
          :'service_job_status' => :'serviceJobStatus',
          :'scope_of_work' => :'scopeOfWork',
          :'seller' => :'seller',
          :'service_job_provider' => :'serviceJobProvider',
          :'preferred_appointment_times' => :'preferredAppointmentTimes',
          :'appointments' => :'appointments',
          :'service_order_id' => :'serviceOrderId',
          :'marketplace_id' => :'marketplaceId',
          :'buyer' => :'buyer',
          :'associated_items' => :'associatedItems',
          :'service_location' => :'serviceLocation'
        }
      end
  
      # Attribute type mapping.
      def self.openapi_types
        {
          :'create_time' => :'Object',
          :'service_job_id' => :'Object',
          :'service_job_status' => :'Object',
          :'scope_of_work' => :'Object',
          :'seller' => :'Object',
          :'service_job_provider' => :'Object',
          :'preferred_appointment_times' => :'Object',
          :'appointments' => :'Object',
          :'service_order_id' => :'Object',
          :'marketplace_id' => :'Object',
          :'buyer' => :'Object',
          :'associated_items' => :'Object',
          :'service_location' => :'Object'
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
          fail ArgumentError, "The input argument (attributes) must be a hash in `AmazonSpClients::SpServices::ServiceJob` initialize method"
        end
  
        # check to see if the attribute exists and convert string to symbol for hash key
        attributes = attributes.each_with_object({}) { |(k, v), h|
          if (!self.class.attribute_map.key?(k.to_sym))
            fail ArgumentError, "`#{k}` is not a valid attribute in `AmazonSpClients::SpServices::ServiceJob`. Please check the name to make sure it's valid. List of attributes: " + self.class.attribute_map.keys.inspect
          end
          h[k.to_sym] = v
        }
  
        if attributes.key?(:'create_time')
          self.create_time = attributes[:'create_time']
        end
  
        if attributes.key?(:'service_job_id')
          self.service_job_id = attributes[:'service_job_id']
        end
  
        if attributes.key?(:'service_job_status')
          self.service_job_status = attributes[:'service_job_status']
        end
  
        if attributes.key?(:'scope_of_work')
          self.scope_of_work = attributes[:'scope_of_work']
        end
  
        if attributes.key?(:'seller')
          self.seller = attributes[:'seller']
        end
  
        if attributes.key?(:'service_job_provider')
          self.service_job_provider = attributes[:'service_job_provider']
        end
  
        if attributes.key?(:'preferred_appointment_times')
          if (value = attributes[:'preferred_appointment_times']).is_a?(Array)
            self.preferred_appointment_times = value
          end
        end
  
        if attributes.key?(:'appointments')
          if (value = attributes[:'appointments']).is_a?(Array)
            self.appointments = value
          end
        end
  
        if attributes.key?(:'service_order_id')
          self.service_order_id = attributes[:'service_order_id']
        end
  
        if attributes.key?(:'marketplace_id')
          self.marketplace_id = attributes[:'marketplace_id']
        end
  
        if attributes.key?(:'buyer')
          self.buyer = attributes[:'buyer']
        end
  
        if attributes.key?(:'associated_items')
          if (value = attributes[:'associated_items']).is_a?(Array)
            self.associated_items = value
          end
        end
  
        if attributes.key?(:'service_location')
          self.service_location = attributes[:'service_location']
        end
      end
  
      # Show invalid properties with the reasons. Usually used together with valid?
      # @return Array for valid properties with the reasons
      def list_invalid_properties
        invalid_properties = Array.new
        invalid_properties
      end
  
      # Check to see if the all the properties in the model are valid
      # @return true if the model is valid
      def valid?
        service_job_status_validator = EnumAttributeValidator.new('Object', ['NOT_SERVICED', 'CANCELLED', 'COMPLETED', 'PENDING_SCHEDULE', 'NOT_FULFILLABLE', 'HOLD', 'PAYMENT_DECLINED'])
        return false unless service_job_status_validator.valid?(@service_job_status)
        true
      end
  
      # Custom attribute writer method checking allowed values (enum).
      # @param [Object] service_job_status Object to be assigned
      def service_job_status=(service_job_status)
        validator = EnumAttributeValidator.new('Object', ['NOT_SERVICED', 'CANCELLED', 'COMPLETED', 'PENDING_SCHEDULE', 'NOT_FULFILLABLE', 'HOLD', 'PAYMENT_DECLINED'])
        unless validator.valid?(service_job_status)
          fail ArgumentError, "invalid value for \"service_job_status\", must be one of #{validator.allowable_values}."
        end
        @service_job_status = service_job_status
      end
  
      # Checks equality by comparing each attribute.
      # @param [Object] Object to be compared
      def ==(o)
        return true if self.equal?(o)
        self.class == o.class &&
            create_time == o.create_time &&
            service_job_id == o.service_job_id &&
            service_job_status == o.service_job_status &&
            scope_of_work == o.scope_of_work &&
            seller == o.seller &&
            service_job_provider == o.service_job_provider &&
            preferred_appointment_times == o.preferred_appointment_times &&
            appointments == o.appointments &&
            service_order_id == o.service_order_id &&
            marketplace_id == o.marketplace_id &&
            buyer == o.buyer &&
            associated_items == o.associated_items &&
            service_location == o.service_location
      end
  
      # @see the `==` method
      # @param [Object] Object to be compared
      def eql?(o)
        self == o
      end
  
      # Calculates hash code according to all attributes.
      # @return [Integer] Hash code
      def hash
        [create_time, service_job_id, service_job_status, scope_of_work, seller, service_job_provider, preferred_appointment_times, appointments, service_order_id, marketplace_id, buyer, associated_items, service_location].hash
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
          AmazonSpClients::SpServices.const_get(type).build_from_hash(value)
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
