# frozen_string_literal: true

require 'time'
require 'amazon_sp_clients/sp_tokens_2021'

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

    attr_reader :access_token, :restricted_data_token

    def initialize(config = Configuration.default, &block)
      @config = config

      @refresh_token = nil
      @access_token = nil
      @access_token_expires_at = nil
      @restricted_data_token = {}
      @restricted_data_token_expires_at = {}
      @grantless = false
      @scope = nil

      @callback = block
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
      elsif @grantless
        authenticate_grantless(@scope)
      elsif !@refresh_token.nil?
        authenticate(@refresh_token)
      end
    end

    def ask_for_restricted_data_token(restricted_resource)
      if !@restricted_data_token[restricted_resource].nil? &&
         !expired?(@restricted_data_token_expires_at[restricted_resource])
        return
      end

      tokens_api = AmazonSpClients::SpTokens2021::TokensApi.new(self)

      token_params = if restricted_resource.is_a?(Symbol)
                       RESTRICTED_OPS.fetch(restricted_resource)
                     else
                       { restrictedResources: [restricted_resource] }
                     end
      # TODO: handle errors for restricted_data_token request!
      tokens_resp = tokens_api.create_restricted_data_token(token_params)

      @restricted_data_token_expires_at[restricted_resource] =
        duration_to_time(tokens_resp.payload[:expiresIn])
      @restricted_data_token[restricted_resource] = tokens_resp.payload[:restrictedDataToken]
    end

    private

    # Returns nil on success, error struct on error
    def request_access_token
      return if @access_token && !expired?(@access_token_expires_at)

      resp_struct = exchange_token_request
      @access_token = resp_struct.access_token
      @refresh_token = resp_struct.refresh_token
      @access_token_expires_at = duration_to_time(resp_struct.expires_in)
    end

    def exchange_token_request
      auth = AmazonSpClients::TokenExchangeAuth.new(@refresh_token)

      @grantless ? auth.exchange('client_credentials', @scope) : auth.exchange('refresh_token')
    end

    def expired?(expires)
      return true if expires.nil?

      # Shorten expiration time by 60s as a safety net.
      Time.now.utc >= expires - 60
    end

    def duration_to_time(seconds)
      Time.now.utc + seconds.to_i
    end
  end
end
