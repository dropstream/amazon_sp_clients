# frozen_string_literal: true

require 'logger'

module AmazonSpClients
  class Configuration
    # SP specific
    attr_reader :marketplace_id
    attr_reader :region

    attr_reader :endpoint

    # App credentials
    attr_accessor :client_id
    attr_accessor :client_secret

    # Deprecated AWS/SigV4-era settings. Amazon dropped the SigV4
    # requirement in October 2023. Accepted and ignored since 1.8.0;
    # they will be removed in 2.0.
    attr_accessor :credentials_provider
    attr_accessor :access_key
    attr_accessor :secret_key
    attr_accessor :role_arn

    # Defines url scheme
    attr_accessor :scheme

    # Defines url base path
    attr_accessor :base_path

    # Set this to enable/disable debugging. When enabled (set to true), HTTP
    # request/response details will be logged with `logger.debug` (see the
    # `logger` attribute). Default to false.
    #
    # @return [true, false]
    attr_accessor :debugging

    # Defines the logger used for debugging.
    # Default to `Rails.logger` (when in Rails) or logging to STDOUT.
    #
    # @return [#debug]
    attr_accessor :logger

    # The time limit for HTTP request in seconds.
    # Default to 0 (never times out).
    attr_accessor :timeout

    # Set this to false to skip client side validation in the operation.
    # Default to true.
    # @return [true, false]
    attr_accessor :client_side_validation

    def initialize
      @sandbox_env = false

      @credentials_provider = nil

      @marketplace_id = nil

      # iam
      @role_arn = nil
      @access_key = nil
      @secret_key = nil

      # app
      @client_id = nil
      @client_secret = nil

      @endpoint = nil
      @scheme = 'https'
      @region = 'us-east-1'
      @base_path = '/'
      @timeout = 60
      @client_side_validation = true
      @debugging = false
      @logger = Logger.new(STDOUT)
      @logger.level = 1
      yield(self) if block_given?
    end

    # The default Configuration object.
    def self.default
      Thread.current[:amazon_sp_configuration] ||= Configuration.new
    end

    def configure
      yield(self) if block_given?
    end

    def scheme=(scheme)
      # remove :// from scheme
      @scheme = scheme.sub(%r{://}, '')
    end

    def host
      "#{'sandbox.' if @sandbox_env}#{AmazonSpClients::REGIONS.fetch(@region)}"
    end

    def base_path=(base_path)
      # Add leading and trailing slashes to base_path
      @base_path = "/#{base_path}".gsub(%r{/+}, '/')
      @base_path = '' if @base_path == '/'
    end

    def base_url
      "#{scheme}://#{[host, base_path].join('/').gsub(%r{/+}, '/')}".sub(%r{/+\z}, '')
    end

    def region=(region)
      # The fetch validates the region; host is computed from it.
      AmazonSpClients::REGIONS.fetch(region)
      @region = region
    end

    # When sandbox mode is enabled, all requests will go to 'sandbox.' host.
    def sandbox_env!
      @sandbox_env = true
    end

    def disable_sandbox!
      @sandbox_env = false
    end

    def set_endpoint_by_marketplace_id(marketplace_id)
      # Validate before assigning so a bad id cannot corrupt state.
      endpoint = AmazonSpClients::MARKETPLACE_ENDPOINT_MAP.fetch(marketplace_id)

      @marketplace_id = marketplace_id
      self.endpoint = endpoint
    end

    def endpoint=(str)
      set_region_by_endpoint(str)
      @endpoint = str
    end

    def set_region_by_endpoint(str)
      self.region =
        case str
        when 'na'
          AmazonSpClients::REGION_NA
        when 'fe'
          AmazonSpClients::REGION_FE
        when 'eu'
          AmazonSpClients::REGION_EU
        when 'br', 'ca', 'mx', 'us'
          AmazonSpClients::REGION_NA
        when 'sg', 'au', 'jp'
          AmazonSpClients::REGION_FE
        when 'ae', 'de', 'eg', 'es', 'fr', 'gb', 'in', 'it', 'nl', 'sa', 'tr', 'pl', 'se'
          AmazonSpClients::REGION_EU
        else
          raise ArgumentError, "unknown endpoint #{str.inspect}"
        end
    end
  end
end
