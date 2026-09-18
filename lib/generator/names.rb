# frozen_string_literal: true

require 'amazon_sp_clients/v2/api'
require 'amazon_sp_clients/v2/client'
require_relative 'naming'

module Generator
  # Guards the names the V2 templates emit. Amazon renames parameters
  # and operations over time; a bad name must fail generation, not the
  # first production call.
  module Names
    RUBY_KEYWORDS = %w[
      BEGIN END alias and begin break case class def defined? do else elsif end ensure
      false for if in module next nil not or redo rescue retry return self super then
      true undef unless until when while yield __FILE__ __LINE__ __ENCODING__
    ].freeze

    # Names every generated method already uses: its rdt: and body
    # arguments and the locals its body builds.
    SIGNATURE_NAMES = %w[rdt body query headers].freeze

    # What a snake_case name must look like to be a Ruby identifier.
    IDENTIFIER = /\A[a-z_][a-z0-9_]*\z/

    # The generated accessors live here; they are not collisions.
    APIS_FILE = %r{/v2/apis\.rb\z}

    module_function

    # A parameter that is not the body: positional or keyword.
    def check_param!(name, operation:)
      check_identifier!(name, "Parameter #{name.inspect} of #{operation}")
      return unless RUBY_KEYWORDS.include?(name) || SIGNATURE_NAMES.include?(name)

      raise "Parameter #{name.inspect} of #{operation} cannot be a method argument"
    end

    def check_method!(name)
      check_identifier!(name, "Operation #{name.inspect}")
      taken = RUBY_KEYWORDS.include?(name) || methods_of(AmazonSpClients::V2::Api).include?(name)
      return unless taken

      raise "Operation #{name.inspect} collides with a Ruby or Api method"
    end

    def check_identifier!(name, what)
      return if name.match?(IDENTIFIER)

      raise "#{what} is not a Ruby identifier"
    end

    def check_module!(name)
      return unless methods_of(AmazonSpClients::V2::Client).include?(name)

      raise "Module #{name.inspect} collides with a Client method"
    end

    # @param raw_names [Array<String>] names as the spec spells them
    def check_unique!(raw_names, what:)
      raw_names.group_by { |raw| Naming.underscore(raw) }.each do |snake, group|
        next if group.size == 1

        raise "#{what} names #{group.join(', ')} all become #{snake}"
      end
    end

    # Public and private instance method names, except the accessors the
    # generator itself writes into Client.
    def methods_of(klass)
      (klass.instance_methods + klass.private_instance_methods).map(&:to_s).reject do |name|
        klass.instance_method(name).source_location&.first&.match?(APIS_FILE)
      end
    end
  end
end
