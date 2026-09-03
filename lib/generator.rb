# frozen_string_literal: true

require 'erb'
require 'logger'
require 'open3'
require 'yaml'

# Regenerates the committed API clients from Amazon's OpenAPI specs,
# checked out at the revision pinned in selling-partner-api-models.sha.
# Pure Ruby + ERB; no Java. Two template sets: v1 writes vendor/ and the
# sp_*.rb shims, V2 writes lib/amazon_sp_clients/v2/apis/.
#
# Not shipped with the gem. Entry points are the rake tasks:
# `generate`, `generate:setup`, `generate:update`, `generate:verify`.
module Generator
  BASE_PATH = File.expand_path('..', __dir__)
  CONFIG_FILE = File.join(BASE_PATH, 'codegen-config.yml')
  V2_APIS_DIR = File.join(BASE_PATH, 'lib', 'amazon_sp_clients', 'v2', 'apis')
  V2_APIS_FILE = File.join(BASE_PATH, 'lib', 'amazon_sp_clients', 'v2', 'apis.rb')

  # Everything tracked under these paths is generated output, and every
  # file there must belong to a module in codegen-config.yml.
  GENERATED_ROOTS = %w[
    vendor
    lib/amazon_sp_clients/sp_*.rb
    lib/amazon_sp_clients/v2/apis
    lib/amazon_sp_clients/v2/apis.rb
  ].freeze

  require_relative 'generator/specs'
  require_relative 'generator/api_module'

  class << self
    def logger
      @logger ||= Logger.new($stdout, level: :info)
    end

    def setup
      Specs.sync(ref: Specs.pinned_sha)
    end

    def generate
      setup
      check_owned!
      api_modules.each(&:generate)
      File.write(V2_APIS_FILE, render_v2_apis(api_modules))
      logger.info("Generated #{api_modules.size} API modules")
    end

    # Paths the generator owns; `rake generate:verify` checks that
    # regeneration leaves them identical to the committed tree.
    def generated_paths
      api_modules.flat_map(&:owned_paths) + [relative(V2_APIS_FILE)]
    end

    # Source of lib/amazon_sp_clients/v2/apis.rb: an autoload per V2
    # class and a Client accessor per module.
    def render_v2_apis(modules)
      template = File.read(File.join(__dir__, 'generator', 'templates', 'v2_apis.erb'))
      ERB.new(template, trim_mode: '-').result_with_hash(modules: modules.select(&:v2?))
    end

    def api_modules
      @api_modules ||= config.fetch('list_of_apis').map do |entry|
        ApiModule.new(name: entry.fetch('name'), spec_path: entry.fetch('path'),
                      templates: entry.fetch('templates'))
      end
    end

    private

    def config
      YAML.load_file(CONFIG_FILE)
    end

    # A module removed from the config leaves its output behind, tracked
    # but never regenerated or verified. Abort before writing anything.
    def check_owned!
      owned = generated_paths
      stale = tracked_files.reject do |file|
        owned.any? { |path| file == path || file.start_with?("#{path}/") }
      end
      return if stale.empty?

      raise "Generated files no module in codegen-config.yml owns:\n  #{stale.join("\n  ")}\n" \
            'Remove them with git rm, or add the module back.'
    end

    def tracked_files
      stdout, stderr, status = Open3.capture3('git', '-C', BASE_PATH, 'ls-files', '--',
                                              *GENERATED_ROOTS)
      raise "git ls-files failed: #{stderr}" unless status.success?

      stdout.split("\n")
    end

    def relative(path)
      path.delete_prefix("#{BASE_PATH}/")
    end
  end
end
