# frozen_string_literal: true

require 'erb'
require 'fileutils'
require 'json'

require_relative 'naming'
require_relative 'operation'
require_relative 'specs'

module Generator
  # One entry from codegen-config.yml: a vendored API module generated
  # from one Amazon OpenAPI spec file. Owns three kinds of files:
  #
  #   vendor/<name>/lib/sp_<name>.rb           entry file (requires the APIs)
  #   vendor/<name>/lib/sp_<name>/api/*.rb     one class per spec tag
  #   lib/amazon_sp_clients/sp_<name>.rb       require shim for the main gem
  class ApiModule
    attr_reader :name, :spec_path

    def initialize(name:, spec_path:)
      @name = name
      @spec_path = spec_path
    end

    def gem_name = "sp_#{name}"
    def module_name = "Sp#{Naming.camelize(name)}"

    def generate
      FileUtils.rm_rf(api_dir)
      FileUtils.mkdir_p(api_dir)

      classes.each do |class_name, ops|
        locals = header_locals.merge(
          module_name: module_name,
          class_name: class_name,
          operations: ops.map(&:render).join
        )
        File.write(File.join(api_dir, "#{Naming.underscore(class_name)}.rb"),
                   render('api_class.erb', locals))
      end

      File.write(entry_path, render('vendor_entry.erb',
                                    header_locals.merge(api_requires: api_requires)))
      File.write(shim_path, render('shim.erb', name: name, gem_name: gem_name))

      Generator.logger.info("Generated #{name} (#{classes.size} classes)")
    end

    # Relative paths checked by `rake generate:verify`.
    def owned_paths
      [entry_path, api_dir, shim_path].map { |p| p.delete_prefix("#{BASE_PATH}/") }
    end

    private

    def spec
      @spec ||= JSON.parse(File.read(File.join(Specs.models_dir, spec_path)))
    end

    # Operations grouped into classes by their first tag (first-seen tag
    # order), sorted by method name inside each class - both matching
    # what swagger-codegen used to emit.
    def classes
      @classes ||= begin
        seen = {}
        grouped = {}
        spec.fetch('paths').each do |path, verbs|
          verbs.each do |verb, op|
            next unless Operation::HTTP_VERBS.include?(verb)

            op_id = op.fetch('operationId')
            raise "Duplicate operationId #{op_id} in #{spec_path}" if seen[op_id]

            seen[op_id] = true
            class_name = "#{Naming.camelize(op.fetch('tags').fetch(0))}Api"
            (grouped[class_name] ||= []) <<
              Operation.new(class_name: class_name, path: path, verb: verb, spec: op, root: spec)
          end
        end
        grouped.transform_values { |ops| ops.sort_by(&:method_name) }
      end
    end

    def api_requires
      classes.keys.map { |class_name| "#{gem_name}/api/#{Naming.underscore(class_name)}" }.sort
    end

    def header_locals
      info = spec.fetch('info')
      {
        title: info.fetch('title'),
        description: Naming.flatten(info['description']),
        version: info.fetch('version')
      }
    end

    def render(template_name, locals)
      template = File.read(File.join(__dir__, 'templates', template_name))
      ERB.new(template, trim_mode: '-').result_with_hash(locals)
    end

    def vendor_lib = File.join(BASE_PATH, 'vendor', name, 'lib')
    def api_dir = File.join(vendor_lib, gem_name, 'api')
    def entry_path = File.join(vendor_lib, "#{gem_name}.rb")
    def shim_path = File.join(BASE_PATH, 'lib', 'amazon_sp_clients', "#{gem_name}.rb")
  end
end
