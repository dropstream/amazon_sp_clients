# frozen_string_literal: true

module Generator
  # String transforms matching swagger-codegen's, so regenerated files
  # stay diffable against the previously committed output.
  module Naming
    # Handlebars-style HTML escaping; swagger-codegen 3 rendered doc
    # comments through handlebars-java, which escapes this exact set.
    ESCAPES = {
      '&' => '&amp;', '<' => '&lt;', '>' => '&gt;',
      '"' => '&quot;', "'" => '&#x27;', '`' => '&#x60;', '=' => '&#x3D;'
    }.freeze

    module_function

    # 'orders_v0' => 'OrdersV0'; 'vendorShipping' => 'VendorShipping'
    def camelize(str)
      str.split(/[^a-zA-Z0-9]+/).reject(&:empty?).map { |w| w[0].upcase + w[1..] }.join
    end

    # 'OrdersV0Api' => 'orders_v0_api'; 'NextToken' => 'next_token'
    def underscore(str)
      str.gsub(/[^a-zA-Z0-9]+/, '_')
         .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
         .gsub(/([a-z\d])([A-Z])/, '\1_\2')
         .downcase
    end

    def escape(str)
      str.to_s.gsub(/[&<>"'`=]/, ESCAPES)
    end

    # Doc text handling copied from swagger-codegen's escapeText: every
    # newline becomes a space, and double quotes get a backslash.
    def flatten(str)
      str.to_s.tr("\n", ' ').gsub('"', '\"')
    end

    # Doc text for the V2 templates: one line, nothing escaped.
    def oneline(str)
      str.to_s.split(/\s*\n\s*/).join(' ').strip
    end
  end
end
