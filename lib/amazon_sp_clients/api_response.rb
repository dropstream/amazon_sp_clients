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
        attributes.transform_keys! { |k| k.to_sym }
        self.payload = attributes[:payload]
        if attributes.key?(:errors)
          self.errors = AmazonSpClients::ApiError.new(attributes.delete(:'errors'))
        end
      else
        attributes.transform_keys! { |k| underscore(k).to_sym }
        self.payload = attributes
      end
    end

    # Builds the object from hash
    # @param [Hash] attributes Model attributes in the form of hash
    # @return [Object] Returns the model itself
    def self.build_from_hash(attributes, response = nil)
      new(attributes, response)
    end

    private

    # doesn't work with acronyms
    def underscore(camel_cased_word)
      return camel_cased_word unless /[A-Z-]|::/.match?(camel_cased_word)
      word = camel_cased_word.to_s.gsub('::', '/')

      # word.gsub!(inflections.acronyms_underscore_regex) { "#{$1 && '_' }#{$2.downcase}" }
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.tr!('-', '_')
      word.downcase!
      word
    end
  end
end
