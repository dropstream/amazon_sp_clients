# frozen_string_literal: true

require 'faraday'

module AmazonSpClients
  # Loads the HTTPClient Faraday adapter (Faraday 2 no longer auto-loads
  # adapter gems; a no-op under Faraday 1).
  #
  # Bundler can pair Faraday 2 with faraday-httpclient 1.x — that adapter
  # gem has no runtime dependency on faraday, so a stale lock entry
  # survives a `bundle update faraday`. The pair fails at require time
  # with a cryptic NoMethodError; turn it into a message that names the
  # fix.
  module AdapterLoader
    FIX_CMD = 'bundle update faraday faraday-httpclient faraday-retry'

    def self.require_adapter!
      require 'faraday/httpclient'
    rescue NoMethodError
      version = Gem.loaded_specs['faraday-httpclient']&.version
      raise LoadError,
            "faraday-httpclient #{version} cannot load under " \
            "Faraday #{Faraday::VERSION}. Run: #{FIX_CMD}"
    end
  end
end

AmazonSpClients::AdapterLoader.require_adapter!
