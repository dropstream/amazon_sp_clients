# frozen_string_literal: true

require_relative 'naming'

module Generator
  # One operation parameter from a Swagger 2.0 spec, exposed the way the
  # templates need it (snake_case name, doc type, enum values, ...).
  class Param
    COLLECTION_FORMATS = %w[csv ssv tsv pipes multi].freeze

    # YARD types the V2 templates emit per Swagger primitive.
    V2_TYPES = {
      'string' => 'String', 'integer' => 'Integer', 'boolean' => 'Boolean', 'number' => 'Float'
    }.freeze

    def initialize(spec)
      @spec = spec
      validate!
    end

    def location = @spec.fetch('in')
    def body? = location == 'body'
    def required? = @spec['required'] == true
    def base_name = @spec.fetch('name')

    # swagger-codegen names every body parameter 'body', whatever the
    # spec calls it.
    def name
      body? ? 'body' : Naming.underscore(base_name)
    end

    def description = Naming.flatten(@spec['description'])
    def escaped_description = Naming.escape(description)
    def default_value = @spec['default']

    def array? = @spec['type'] == 'array'

    def collection_format
      return nil unless array?

      @spec['collectionFormat'] || 'csv'
    end

    def enum_values
      array? ? @spec.dig('items', 'enum') : @spec['enum']
    end

    def doc_type
      return ref_name(@spec['schema']) if body?
      return "Array<#{primitive_type(@spec.fetch('items'))}>" if array?

      primitive_type(@spec)
    end

    # YARD type for the V2 templates; bodies are plain Hashes.
    def v2_doc_type
      return 'Hash' if body?
      return "Array<#{v2_primitive(@spec.fetch('items'))}>" if array?

      v2_primitive(@spec)
    end

    # One line, unescaped; a body param names its schema.
    def v2_description
      text = Naming.oneline(@spec['description'])
      return text unless body?

      "#{text} (#{ref_name(@spec['schema'])})".strip
    end

    private

    # Fail loudly on spec constructs the generator does not understand,
    # instead of silently emitting wrong code.
    def validate!
      raise "Unsupported $ref parameter: #{@spec.inspect}" if @spec.key?('$ref')
      raise "Unsupported formData parameter: #{base_name}" if location == 'formData'

      cf = @spec['collectionFormat']
      return if cf.nil? || COLLECTION_FORMATS.include?(cf)

      raise "Unknown collectionFormat #{cf} for #{base_name}"
    end

    def primitive_type(spec)
      case spec['type']
      when 'string'
        { 'date-time' => 'DateTime', 'date' => 'Date' }.fetch(spec['format'], 'String')
      when 'integer' then 'Integer'
      when 'boolean' then 'BOOLEAN'
      when 'number' then 'Float'
      else
        raise "Unsupported parameter type #{spec['type'].inspect} for #{base_name}"
      end
    end

    def v2_primitive(spec)
      V2_TYPES.fetch(spec['type']) do
        raise "Unsupported parameter type #{spec['type'].inspect} for #{base_name}"
      end
    end

    def ref_name(schema)
      ref = schema && schema['$ref']
      raise "Body parameter #{base_name} has no $ref schema" unless ref

      ref.split('/').last
    end
  end
end
