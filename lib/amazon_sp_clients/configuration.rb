# frozen_string_literal: true

module AmazonSpClients
  class Configuration
    # SP specific
    attr_reader :marketplace_id
    attr_reader :region

    attr_reader :endpoint

    # App credentials
    attr_accessor :client_id
    attr_accessor :client_secret

    # IAM credentials
    attr_accessor :access_key
    attr_accessor :secret_key

    attr_accessor :role_arn

    # Defines url scheme
    attr_accessor :scheme

    # Defines url host
    attr_accessor :host

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

    # Defines the temporary folder to store downloaded files
    # (for API endpoints that have file response).
    # Default to use `Tempfile`.
    #
    # @return [String]
    attr_accessor :temp_folder_path

    # The time limit for HTTP request in seconds.
    # Default to 0 (never times out).
    attr_accessor :timeout

    # Set this to false to skip client side validation in the operation.
    # Default to true.
    # @return [true, false]
    attr_accessor :client_side_validation

    ### TLS/SSL setting
    # Set this to false to skip verifying SSL certificate when calling API    .
    # from https server Default to true                                       .
    #
    # @note Do NOT set it to false in production code, otherwise you would face
    # multiple types of cryptographic attacks.
    #
    # @return [true, false]
    attr_accessor :verify_ssl

    ### TLS/SSL setting
    # Set this to false to skip verifying SSL host name
    # Default to true.
    #
    # @note Do NOT set it to false in production code, otherwise you would face
    # multiple types of cryptographic attacks.
    #
    # @return [true, false]
    attr_accessor :verify_ssl_host

    ### TLS/SSL setting
    # Set this to customize the certificate file to verify the peer.
    #
    # @return [String] the path to the certificate file
    #
    # @see The `cainfo` option of Typhoeus, `--cert` option of libcurl. Related
    # source code:
    # https://github.com/typhoeus/typhoeus/blob/master/lib/typhoeus/easy_factory.rb#L145
    attr_accessor :ssl_ca_cert

    ### TLS/SSL setting
    # Client certificate file (for client certificate)
    attr_accessor :cert_file

    ### TLS/SSL setting
    # Client private key file (for client certificate)
    attr_accessor :key_file

    # Set this to customize parameters encoding of array parameter with multi
    # collectionFormat. Default to nil.
    #
    # @see The params_encoding option of Ethon. Related source code:
    # https://github.com/typhoeus/ethon/blob/master/lib/ethon/easy/queryable.rb#L96
    attr_accessor :params_encoding

    attr_accessor :inject_format

    attr_accessor :force_ending_format

    def initialize
      @sandbox_env = false

      # ap api
      @refresh_token = nil
      @marketplace_id = AmazonSpClients::MARKETPLACE_IDS.fetch(:us)

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
      @host = "#{@sandbox_env ? 'sandbox.' : ''}#{AmazonSpClients::REGIONS.fetch(@region)}"
      @base_path = '/'
      @timeout = 60
      @client_side_validation = true
      @verify_ssl = true
      @verify_ssl_host = true
      @params_encoding = nil
      @cert_file = nil
      @key_file = nil
      @debugging = false
      @inject_format = false
      @force_ending_format = false
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
      @scheme = scheme.sub(%r{:\/\/}, '')
    end

    def host=(host)
      # remove http(s):// and anything after a slash
      @host = host.sub(%r{https?:\/\/}, '').split('/').first
    end

    def host
      "#{@sandbox_env ? 'sandbox.' : ''}#{AmazonSpClients::REGIONS.fetch(@region)}"
    end

    def base_path=(base_path)
      # Add leading and trailing slashes to base_path
      @base_path = "/#{base_path}".gsub(%r{\/+}, '/')
      @base_path = '' if @base_path == '/'
    end

    def base_url
      "#{scheme}://#{[host, base_path].join('/').gsub(%r{\/+}, '/')}".sub(%r{\/+\z}, '')
    end

    # Gets Basic Auth token string
    def basic_auth_token
      'Basic ' + ["#{username}:#{password}"].pack('m').delete("\r\n")
    end

    def region=(region)
      @region = region
      @host = AmazonSpClients::REGIONS.fetch(@region)
    end

    # When sandbox mode is enabled, all requests will go to 'sandbox.' host.
    def sandbox_env!
      @sandbox_env = true
    end

    def disable_sandbox!
      @sandbox_env = false
    end

    def set_endpoint_by_marketplace_id(marketplace_id)
      self.endpoint = AmazonSpClients::MARKETPLACE_ENDPOINT_MAP.fetch(marketplace_id, 'na')
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
        end
    end
  end
end
