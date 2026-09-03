# frozen_string_literal: true

require 'erb'

require_relative 'names'
require_relative 'naming'
require_relative 'param'

module Generator
  # One API operation. For v1 it renders the convenience method plus the
  # `_with_http_info` variant through templates/operation.erb, matching
  # the layout swagger-codegen used to emit. For V2 it renders one
  # method through templates/v2_operation.erb.
  class Operation
    HTTP_VERBS = %w[get put post delete patch head options].freeze
    INDENT = '        '

    attr_reader :class_name, :method_name, :http_method, :operation_id, :verb

    def self.template
      @template ||= ERB.new(
        File.read(File.join(__dir__, 'templates', 'operation.erb')), trim_mode: '-'
      )
    end

    def self.v2_template
      @v2_template ||= ERB.new(
        File.read(File.join(__dir__, 'templates', 'v2_operation.erb')), trim_mode: '-'
      )
    end

    def initialize(class_name:, path:, verb:, spec:, root:)
      @class_name = class_name
      @path = path
      @verb = verb
      @spec = spec
      @root = root
      @operation_id = spec.fetch('operationId')
      @method_name = Naming.underscore(@operation_id)
      @http_method = verb.upcase
    end

    def render
      self.class.template.result(binding)
    end

    # The V2 method: required params positional in v1 order, the rest
    # keywords, plus rdt:. Names that would not survive as Ruby
    # arguments fail here.
    def render_v2
      Names.check_method!(method_name)
      Names.check_unique!(params.map(&:name), what: 'parameter')
      params.reject(&:body?).each { |p| Names.check_param!(p.name, operation: method_name) }

      self.class.v2_template.result(binding)
    end

    private

    def params
      @params ||= (@spec['parameters'] || []).map { |p| Param.new(p) }
    end

    def body_param = params.find(&:body?)

    # swagger-codegen keeps spec order for body-less operations, but for
    # operations with a body it regroups: body first, then query, path
    # and header parameters (spec order inside each group).
    def ordered_params
      return params unless body_param

      groups = params.group_by(&:location)
      [body_param, *groups['query'], *groups['path'], *groups['header']]
    end

    # Required parameters before optional ones, order otherwise kept.
    def signature_params = ordered_params.select(&:required?)
    def optional_params = ordered_params.reject(&:required?)
    def all_params = signature_params + optional_params

    def sig_args
      signature_params.map { |p| "#{p.name}, " }.join
    end

    def summary = presence(Naming.flatten(@spec['summary']))
    def notes = presence(Naming.flatten(@spec['description']))
    def escaped_summary = Naming.escape(summary)
    def escaped_notes = Naming.escape(notes)

    # Only scalar params got a "(default to x)" doc suffix; array
    # defaults were dropped by swagger-codegen.
    def default_suffix(param)
      return '' if param.array? || param.default_value.nil?

      " (default to #{param.default_value})"
    end

    # -- return type ------------------------------------------------------

    def response_schema
      @spec.fetch('responses').each do |code, resp|
        return resp['schema'] if code.match?(/\A2\d\d\z/) && resp['schema']
      end
      nil
    end

    def return_type? = !response_schema.nil?

    def return_doc
      return 'nil' unless return_type?

      ref = response_schema['$ref']
      raise "Unsupported inline response schema in #{class_name}.#{method_name}" unless ref

      ref.split('/').last
    end

    # -- request building pieces -----------------------------------------

    def path_expr
      subs = params.select { |p| p.location == 'path' }.map do |p|
        ".sub('{' + '#{p.base_name}' + '}', #{p.name}.to_s)"
      end
      "'#{@path}'#{subs.join}"
    end

    def query_assign_lines
      req, opt = params.select { |p| p.location == 'query' }.partition(&:required?)
      lines = req.map { |p| "#{INDENT}query_params[:'#{p.base_name}'] = #{value_expr(p)}\n" }
      lines += opt.map do |p|
        "#{INDENT}query_params[:'#{p.base_name}'] = #{value_expr(p)} if !opts[:'#{p.name}'].nil?\n"
      end
      lines.join
    end

    def header_assign_lines
      lines = []
      if produces.any?
        lines << "#{INDENT}# HTTP header 'Accept' (if needed)\n"
        lines << "#{INDENT}header_params['Accept'] = " \
                 "@api_client.select_header_accept([#{quoted_list(produces)}])\n"
      end
      if body_param
        lines << "#{INDENT}# HTTP header 'Content-Type'\n"
        lines << "#{INDENT}header_params['Content-Type'] = " \
                 "@api_client.select_header_content_type([#{quoted_list(consumes)}])\n"
      end
      req, opt = params.select { |p| p.location == 'header' }.partition(&:required?)
      lines += req.map { |p| "#{INDENT}header_params[:'#{p.base_name}'] = #{value_expr(p)}\n" }
      lines += opt.map do |p|
        "#{INDENT}header_params[:'#{p.base_name}'] = #{value_expr(p)} if !opts[:'#{p.name}'].nil?\n"
      end
      lines.join
    end

    def body_suffix
      return '' unless body_param

      arg = body_param.required? ? 'body' : "opts[:'body']"
      "|| @api_client.object_to_http_body(#{arg}) "
    end

    def return_type_suffix
      return_type? ? "|| 'AmazonSpClients::ApiResponse' " : ''
    end

    # Accept mirrors the operation's (or spec's) `produces`, plus any
    # response `examples` keys: the swagger 2->3 converter treated those
    # keys as media types, and the old output kept them (e.g. 'payload').
    # Content-Type is emitted only for operations that take a body.
    def produces
      base = @spec['produces'] || @root['produces'] || []
      example_keys = @spec.fetch('responses').values.flat_map { |r| (r['examples'] || {}).keys }
      base + example_keys.uniq.reject { |k| base.include?(k) }
    end

    def consumes = @spec['consumes'] || @root['consumes'] || ['application/json']

    # -- client-side validation guards ------------------------------------

    def guard_lines
      all_params.map { |p| param_guards(p) }.join
    end

    # swagger-codegen 3 never emitted length/bounds/pattern guards for
    # these specs, so neither do we - only nil and enum checks.
    def param_guards(param)
      out = +''
      out << required_guard(param) if param.required?
      out << enum_guard(param)
      out
    end

    def required_guard(param)
      n = param.name
      indent(<<~RUBY)
        # verify the required parameter '#{n}' is set
        if @api_client.config.client_side_validation && #{n}.nil?
          fail ArgumentError, "Missing the required parameter '#{n}' when calling #{class_name}.#{method_name}"
        end
      RUBY
    end

    def enum_guard(param)
      values = param.enum_values
      return '' if values.nil? || values.empty?

      if param.required?
        # containers get no enum check in the required branch
        param.array? ? '' : required_enum_guard(param, values)
      elsif param.array?
        optional_enum_list_guard(param, values)
      else
        optional_enum_guard(param, values)
      end
    end

    def required_enum_guard(param, values)
      indent(<<~RUBY)
        # verify enum value
        if @api_client.config.client_side_validation && !#{quoted_array(values)}.include?(#{param.name})
          fail ArgumentError, "invalid value for '#{param.name}', must be one of #{values.join(', ')}"
        end
      RUBY
    end

    def optional_enum_list_guard(param, values)
      n = param.name
      indent(<<~RUBY)
        if @api_client.config.client_side_validation && opts[:'#{n}'] && !opts[:'#{n}'].all? { |item| #{quoted_array(values)}.include?(item) }
          fail ArgumentError, 'invalid value for "#{n}", must include one of #{values.join(', ')}'
        end
      RUBY
    end

    def optional_enum_guard(param, values)
      n = param.name
      indent(<<~RUBY)
        if @api_client.config.client_side_validation && opts[:'#{n}'] && !#{quoted_array(values)}.include?(opts[:'#{n}'])
          fail ArgumentError, 'invalid value for "#{n}", must be one of #{values.join(', ')}'
        end
      RUBY
    end

    # -- V2 template pieces --------------------------------------------------

    def v2_params = all_params

    def v2_signature
      parts = signature_params.map(&:name)
      parts += optional_params.map { |p| "#{p.name}: nil" }
      parts << 'rdt: nil'
      parts.join(', ')
    end

    def query_params = params.select { |p| p.location == 'query' }
    def header_params = params.select { |p| p.location == 'header' }
    def path_params = params.select { |p| p.location == 'path' }

    def v2_value_expr(param)
      param.array? ? "csv(#{param.name})" : param.name
    end

    # '/orders/v0/orders/{orderId}' => "/orders/v0/orders/#{encode(order_id)}"
    def v2_path_expr
      return "'#{@path}'" if path_params.empty?

      expr = path_params.reduce(@path) do |acc, p|
        acc.sub("{#{p.base_name}}", "\#{encode(#{p.name})}")
      end
      "\"#{expr}\""
    end

    def v2_request_args
      args = []
      args << 'query: query' if query_params.any?
      args << 'headers: headers' if header_params.any?
      args << 'body: body' if body_param
      args << 'rdt: rdt'
      args.join(', ')
    end

    def v2_summary
      Naming.oneline(@spec['summary'] || @spec['description'])
    end

    # -- small helpers -----------------------------------------------------

    def value_expr(param)
      source = param.required? ? param.name : "opts[:'#{param.name}']"
      return source unless param.collection_format

      "@api_client.build_collection_param(#{source}, :#{param.collection_format})"
    end

    def quoted_list(values)
      values.map { |v| "'#{v}'" }.join(', ')
    end

    def quoted_array(values)
      "[#{quoted_list(values)}]"
    end

    def indent(text)
      text.gsub(/^(?!$)/, INDENT)
    end

    def presence(str)
      str && !str.empty? ? str : nil
    end
  end
end
