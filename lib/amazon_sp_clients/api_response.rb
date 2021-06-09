module AmazonSpClients
  # The general response.
  class ApiResponse
    # Hash with response payload
    attr_accessor :payload

    # Hash with error response, nil otherwise
    attr_accessor :errors

    attr_reader :original_response

    def self.attribute_map
      { 'payload': :'payload', 'errors': :'errors' }
    end

    # Initializes the object
    # @param [Hash] attributes Model attributes in the form of hash
    def initialize(attributes = {}, response = nil)
      if (!attributes.is_a?(Hash))
        fail ArgumentError,
             'The input argument (attributes) must be a hash in `ApiResponse` initialize method'
      end

      # check to see if the attribute exists and convert string to symbol for hash key
      attributes =
        attributes.each_with_object({}) do |(k, v), h|
          if (!self.class.attribute_map.key?(k.to_sym))
            fail ArgumentError,
                 "`#{k}` is not a valid attribute in `ApiResponse`. Please check the name to make sure it's valid. "
          end
          h[k.to_sym] = v
        end

      self.payload = attributes[:'payload'] if attributes.key?(:'payload')

      if attributes.key?(:'errors')
        self.errors = AmazonSpClients::ApiError.new(attributes[:'errors'])
      end

      @original_response = response if response
    end

    # Builds the object from hash
    # @param [Hash] attributes Model attributes in the form of hash
    # @return [Object] Returns the model itself
    def self.build_from_hash(attributes, response = nil)
      new(attributes, response)
    end
  end
end
