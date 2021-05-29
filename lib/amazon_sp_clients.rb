require 'amazon_sp_clients/version'
require 'amazon_sp_clients/api_client'
require 'amazon_sp_clients/api_error'
require 'amazon_sp_clients/configuration'
require 'amazon_sp_clients/version'
require 'amazon_sp_clients/version'

module AmazonSpClients
  class << self
    AmazonSpClients.configure do |config|
      config.username = 'xxx'
      config.password = 'xxx'
    end

    # If no block given, return the default Configuration object.
    def configure
      if block_given?
        yield(Configuration.default)
      else
        Configuration.default
      end
    end
  end
end
