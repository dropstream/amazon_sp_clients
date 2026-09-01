# frozen_string_literal: true

require 'logger'
require 'yaml'

# Regenerates the committed API clients under vendor/ from Amazon's
# OpenAPI specs, checked out at the revision pinned in
# selling-partner-api-models.sha. Pure Ruby + ERB; no Java.
#
# Not shipped with the gem. Entry points are the rake tasks:
# `generate`, `generate:setup`, `generate:update`, `generate:verify`.
module Generator
  BASE_PATH = File.expand_path('..', __dir__)
  CONFIG_FILE = File.join(BASE_PATH, 'codegen-config.yml')

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
      api_modules.each(&:generate)
      logger.info("Generated #{api_modules.size} API modules")
    end

    # Paths the generator owns; `rake generate:verify` checks that
    # regeneration leaves them identical to the committed tree.
    def generated_paths
      api_modules.flat_map(&:owned_paths)
    end

    def api_modules
      @api_modules ||= config.fetch('list_of_apis').map do |entry|
        ApiModule.new(name: entry.fetch('name'), spec_path: entry.fetch('path'))
      end
    end

    private

    def config
      YAML.load_file(CONFIG_FILE)
    end
  end
end
