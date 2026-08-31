# frozen_string_literal: true

require 'time'
require 'amazon_sp_clients/sp_tokens_2021'
require 'aws-sdk-core'

module AmazonSpClients
  class Session
    RESTRICTED_OPS = {
      orders: {
        restrictedResources: [
          { method: 'GET', path: '/orders/v0/orders', dataElements: %w[buyerInfo shippingAddress] }
        ]
      },
      orders_and_items: {
        restrictedResources: [
          { method: 'GET', path: '/orders/v0/orders', dataElements: %w[buyerInfo shippingAddress] },
          { method: 'GET', path: '/orders/v0/orders/{orderId}/orderItems',
            dataElements: ['buyerInfo'] }
        ]
      }
    }.freeze

    attr_reader :access_token, :restricted_data_token, :credentials_provider

    def initialize(config = Configuration.default, &block)
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
      @credentials_provider = @config.credentials_provider || role_credentials

      @callback = block
    end

    # NOTE: usually will make immediate web request
    def role_credentials
      Aws::AssumeRoleCredentials.new(
        client: Aws::STS::Client.new(
          credentials: Aws::Credentials.new(@config.access_key,
                                            @config.secret_key), region: @config.region
        ),
        role_arn: @config.role_arn,
        role_session_name: 'SPAPISession'
      )
    rescue StandardError => e
      raise Faraday::ForbiddenError.new(e.message, { service: 'sts', request: {}, response: {} })
    end

    def with_callback(&block)
      @callback = block
      self
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
      if @callback
        @access_token = @callback.call
        @access_token_expires_at = nil
      elsif @grantles
        authenticate_grantless(@scope)
      elsif !@refresh_token.nil?
        authenticate(@refresh_token)
      end
    end

    def ask_for_restricted_data_token(restricted_resource)
      @logger.debug('this request will require restricted data token')
      if !@restricted_data_token[restricted_resource].nil? &&
         !expired?(@restricted_data_token_expirest_at[restricted_resource])
        @logger.debug(
          "restricted_data_token for `#{restricted_resource}` is still valid, skipping /tokes20210 request"
        )
        return
      else
        @logger.debug(
          "restricted_data_token for `#{restricted_resource}` is nil or stale, making /tokens2021 request"
        )
      end

      tokens_api = AmazonSpClients::SpTokens2021::TokensApi.new(self)

      token_params = if restricted_resource.is_a?(Symbol)
                       RESTRICTED_OPS.fetch(restricted_resource)
                     else
                       { restrictedResources: [restricted_resource] }
                     end
      # TODO: handle errors for restricted_data_token request!
      tokens_resp = tokens_api.create_restricted_data_token(token_params)

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

      expires_time = if expires.is_a?(String)
                       Time.strptime(expires, '%Y-%m-%dT%H:%M:%S%Z')
                     else
                       expires
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
