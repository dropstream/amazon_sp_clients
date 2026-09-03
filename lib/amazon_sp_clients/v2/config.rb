# frozen_string_literal: true

require 'amazon_sp_clients/version'
require 'amazon_sp_clients/marketplaces'
require 'amazon_sp_clients/v2/errors'

module AmazonSpClients
  module V2
    # Per-client settings: which SP-API host to talk to, timeouts, the
    # user agent, and the LWA app credentials (only needed by clients
    # that exchange refresh tokens themselves). Frozen; build a variant
    # with +with+:
    #
    #   config = Config.new(endpoint: 'eu', sandbox: true)
    #   config.with(sandbox: false)
    Config = Data.define(:endpoint, :sandbox, :timeout, :open_timeout,
                         :client_id, :client_secret, :user_agent)

    class Config
      # Endpoint codes consumers store per merchant, mapped to the AWS
      # region that names the SP-API host. Same table as v1's
      # Configuration#endpoint=.
      ENDPOINT_REGIONS = {
        'na' => REGION_NA, 'br' => REGION_NA, 'ca' => REGION_NA, 'mx' => REGION_NA,
        'us' => REGION_NA,
        'fe' => REGION_FE, 'au' => REGION_FE, 'jp' => REGION_FE, 'sg' => REGION_FE,
        'eu' => REGION_EU, 'ae' => REGION_EU, 'de' => REGION_EU, 'eg' => REGION_EU,
        'es' => REGION_EU, 'fr' => REGION_EU, 'gb' => REGION_EU, 'in' => REGION_EU,
        'it' => REGION_EU, 'nl' => REGION_EU, 'pl' => REGION_EU, 'sa' => REGION_EU,
        'se' => REGION_EU, 'tr' => REGION_EU
      }.freeze

      # North America, where every consumer started.
      DEFAULT_ENDPOINT = 'na'
      # Seconds to read or write on an open connection.
      DEFAULT_TIMEOUT = 60
      # Seconds to open a connection.
      DEFAULT_OPEN_TIMEOUT = 10
      # Names the gem and Ruby version, as Amazon asks.
      DEFAULT_USER_AGENT = "amazon_sp_clients/#{VERSION} (Language=Ruby/#{RUBY_VERSION})".freeze
      # Host prefix of the SP-API sandbox.
      SANDBOX_PREFIX = 'sandbox.'

      # @param endpoint [String] region or country code ('na', 'eu', 'fe', 'de', ...)
      # @param sandbox [Boolean] send requests to the sandbox host
      # @param timeout [Integer] read/write timeout in seconds
      # @param open_timeout [Integer] connect timeout in seconds
      # @param client_id [String, nil] LWA app client id
      # @param client_secret [String, nil] LWA app client secret
      # @param user_agent [String, nil] nil selects the default
      # @raise [ArgumentError] on an unknown endpoint code
      def initialize(endpoint: DEFAULT_ENDPOINT, sandbox: false, timeout: DEFAULT_TIMEOUT,
                     open_timeout: DEFAULT_OPEN_TIMEOUT, client_id: nil, client_secret: nil,
                     user_agent: DEFAULT_USER_AGENT)
        ENDPOINT_REGIONS.fetch(endpoint) do
          raise ArgumentError, "unknown endpoint #{endpoint.inspect}"
        end

        super(endpoint: endpoint, sandbox: sandbox, timeout: timeout, open_timeout: open_timeout,
              client_id: client_id, client_secret: client_secret,
              user_agent: user_agent || DEFAULT_USER_AGENT)
      end

      # @return [String] AWS region of the endpoint, e.g. 'us-east-1'
      def region = ENDPOINT_REGIONS.fetch(endpoint)

      # @return [String] SP-API host, with the sandbox prefix when enabled
      def host
        "#{SANDBOX_PREFIX if sandbox}#{REGIONS.fetch(region)}"
      end

      # @return [String] base URL of every API request
      def base_url = "https://#{host}"

      # Consoles and error trackers inspect configs; the secret stays out.
      #
      # @return [String]
      def inspect
        fields = to_h.merge(client_secret: client_secret && FILTERED)

        "#<#{self.class.name} #{fields.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')}>"
      end
    end
  end
end
