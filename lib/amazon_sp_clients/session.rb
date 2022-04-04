# frozen_string_literal: true

require 'time'
require 'amazon_sp_clients/sp_tokens_2021'
require 'aws-sdk-core'

module AmazonSpClients
  class Session
    RESTRICTED_OPS = {
      orders: {
        restrictedResources: [
          { method: 'GET', path: '/orders/v0/orders', dataElements: %w[buyerInfo shippingAddress] },
        ],
      },
    }.freeze

    attr_reader :access_token, :role_credentials, :restricted_data_token

    def initialize(config = Configuration.default)
      @config = config
      @logger = @config.logger

      @refresh_token = nil
      @access_token = nil
      @access_token_expires_at = nil
      @restricted_data_token = {}
      @restricted_data_token_expirest_at = {}
      @grantless = false
      @scope = nil

      @session_client = nil
      @role_credentials = nil

      init_credentials_provider
    end

    def init_credentials_provider
      @session_client =
        Aws::STS::Client.new(
          region: @config.region,
          access_key_id: @config.access_key,
          secret_access_key: @config.secret_key,
        )

      # The documentation claim that this client is self refreshing
      # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/AssumeRoleCredentials.html
      @role_credentials =
        Aws::AssumeRoleCredentials.new(
          client: @session_client,
          role_arn: @config.role_arn,
          role_session_name: 'SPAPISession',
        )
      rescue => e
        raise Faraday::ForbiddenError.new(e.message, { service: 'sts', request: {}, response: {} })
    end

    # @return [self]
    def authenticate(refresh_token)
      @refresh_token = refresh_token
      @grantless = false
      @scope = nil

      request_access_token
      self
    end

    # @return [self]
    def authenticate_grantless(scope)
      @grantless = true
      @scope = scope

      request_access_token
      self
    end

    def refresh
      if @grantles
        authenticate_grantless(@scope)
      elsif !@refresh_token.nil?
        authenticate(@refresh_token)
      end
    end

    def ask_for_restricted_data_token(restricted_resource)
      unless RESTRICTED_OPS.has_key?(restricted_resource)
        raise "Invalid restricted_opts arg: #{restricted_resource}"
      end

      @logger.debug('this request will require restricted data token')
      if !@restricted_data_token[restricted_resource].nil? &&
           !expired?(@restricted_data_token_expirest_at[restricted_resource])
        @logger.debug(
          "restricted_data_token for `#{restricted_resource}` is still valid, skipping /tokes20210 request",
        )
        return
      else
        @logger.debug(
          "restricted_data_token for `#{restricted_resource}` is nil or stale, making /tokens2021 request",
        )
      end

      tokens_api = AmazonSpClients::SpTokens2021::TokensApi.new(self)

      # TODO: handle errors for restricted_data_token request!
      tokens_resp =
        tokens_api.create_restricted_data_token(RESTRICTED_OPS.fetch(restricted_resource))

      @restricted_data_token_expirest_at[restricted_resource] =
        duration_to_date(tokens_resp.payload[:expiresIn])
      @restricted_data_token[restricted_resource] = tokens_resp.payload[:restrictedDataToken]
    end

    private

    # Returns nil on success, error struct on error
    def request_access_token
      if @access_token && !expired?(@access_token_expires_at)
        @logger.debug('`access_token` is present - skipping token request')
        return
      end
      @logger.debug('`access_token` is nil or expired')
      resp_struct = exchange_token_request
      @access_token = resp_struct.access_token
      @refresh_token = resp_struct.refresh_token
      @access_token_expires_at = duration_to_date(resp_struct.expires_in)
    end

    def exchange_token_request
      auth = AmazonSpClients::TokenExchangeAuth.new(@refresh_token)

      @grantless ? auth.exchange('client_credentials', @scope) : auth.exchange('refresh_token')
    end

    def expired?(expires)
      return true if expires.nil?
      if expires.is_a?(String)
        expires_time = Time.strptime(expires, '%Y-%m-%dT%H:%M:%S%Z')
      else
        expires_time = expires
      end
      now = Time.now.utc
      now >= expires_time - 60 # Shorten expiration time by 60s as a safety net
    end

    def duration_to_date(seconds)
      now = Time.now.utc
      new = now + seconds.to_i
      new.strftime('%Y-%m-%dT%H:%M:%SZ')
    end
  end
end
