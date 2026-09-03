# frozen_string_literal: true

require 'erb'
require 'fileutils'
require 'json'

require_relative 'names'
require_relative 'naming'
require_relative 'operation'
require_relative 'specs'

module Generator
  # One entry from codegen-config.yml: an API module generated from one
  # Amazon OpenAPI spec file, in one or both template sets.
  #
  # v1 (the swagger-codegen shape, one class per spec tag):
  #   vendor/<name>/lib/sp_<name>.rb           entry file (requires the APIs)
  #   vendor/<name>/lib/sp_<name>/api/*.rb     API classes
  #   lib/amazon_sp_clients/sp_<name>.rb       require shim for the main gem
  #
  # v2 (AmazonSpClients::V2, one class per module):
  #   lib/amazon_sp_clients/v2/apis/<name>.rb
  class ApiModule
    TEMPLATES = %w[v1 v2].freeze

    attr_reader :name, :spec_path, :templates

    def initialize(name:, spec_path:, templates:, models_dir: Specs.models_dir)
      unknown = templates - TEMPLATES
      raise ArgumentError, "unknown templates #{unknown.inspect} for #{name}" unless unknown.empty?
      raise ArgumentError, "no templates listed for #{name}" if templates.empty?

      @name = name
      @spec_path = spec_path
      @templates = templates
      @models_dir = models_dir
    end

    def gem_name = "sp_#{name}"
    def module_name = "Sp#{Naming.camelize(name)}"
    def v2_class_name = Naming.camelize(name)
    def v1? = templates.include?('v1')
    def v2? = templates.include?('v2')

    # The spec title, for the V2 entry file.
    def title = spec.fetch('info').fetch('title').strip

    def generate
      generate_v1 if v1?
      generate_v2 if v2?

      Generator.logger.info("Generated #{name} (#{templates.join(', ')})")
    end

    # Relative paths checked by `rake generate:verify`.
    def owned_paths
      paths = []
      paths.push(entry_path, api_dir, shim_path) if v1?
      paths << v2_path if v2?
      paths.map { |p| p.delete_prefix("#{BASE_PATH}/") }
    end

    # Source of the V2 class: every operation of the spec in one class,
    # sorted by method name.
    def render_v2
      Names.check_module!(name)
      Names.check_unique!(operations.map(&:operation_id), what: 'operationId')

      render('v2_api_class.erb',
             title: title,
             description: Naming.oneline(spec.fetch('info')['description']),
             version: spec.fetch('info').fetch('version'),
             class_name: v2_class_name,
             operations: operations.map(&:render_v2).join("\n"))
    end

    private

    def generate_v1
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
    end

    def generate_v2
      FileUtils.mkdir_p(File.dirname(v2_path))
      File.write(v2_path, render_v2)
    end

    def spec
      @spec ||= JSON.parse(File.read(File.join(@models_dir, spec_path)))
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

    # Every operation of the spec, tags merged.
    def operations
      classes.values.flatten.sort_by(&:method_name)
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
    def v2_path = File.join(Generator::V2_APIS_DIR, "#{name}.rb")
  end
end
