module AmazonSpClients
  # The general response.
  class ApiResponse
    # # Hash with response payload
    attr_accessor :payload

    # # Hash with error response, nil otherwise
    attr_accessor :errors

    # Initializes the object
    # @param [Hash] attributes Model attributes in the form of hash
    def initialize(attributes = {}, response = nil)
      @attributes = nil

      if (!attributes.is_a?(Hash))
        raise ArgumentError,
              'The input argument (attributes) must be a hash in `ApiResponse` initialize method'
      end

      if attributes.key?('payload') || attributes.key?(:payload) || attributes.key?('errors') ||
           attributes.key?(:errors)
        self.payload = attributes[:payload]
        if attributes.key?(:errors)
          self.errors = AmazonSpClients::ApiError.new(attributes.delete(:'errors'))
        end
      else
        self.payload = attributes
      end
    end

    # Builds the object from hash
    # @param [Hash] attributes Model attributes in the form of hash
    # @return [Object] Returns the model itself
    def self.build_from_hash(attributes, response = nil)
      new(attributes, response)
    end
  end
end
