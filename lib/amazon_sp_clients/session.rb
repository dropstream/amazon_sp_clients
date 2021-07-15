# frozen_string_literal: true

require 'time'
require 'amazon_sp_clients/sp_tokens_2021'

module AmazonSpClients
  class Session
    RESTRICTED_OPS = {
      restrictedResources: [
        { method: 'GET', path: '/orders/v0/orders/{orderId}/buyerInfo' }.freeze,
        { method: 'GET', path: '/orders/v0/orders/{orderId}/address' }.freeze,
      ].freeze,
    }.freeze

    attr_reader :access_token, :role_credentials, :restricted_data_token

    def initialize(config = Configuration.default)
      @config = config
      @logger = @config.logger

      @refresh_token = nil
      @access_token = nil
      @access_token_expires_at = nil
      @restricted_data_token = nil
      @restricted_data_token_expirest_at = nil
      @role_credentials = nil
      @grantless = false
      @scope = nil
    end

    # @return [self]
    def authenticate(refresh_token)
      @refresh_token = refresh_token
      @grantless = false
      @scope = nil

      request_role_credentials
      request_access_token
      self
    end

    # @return [self]
    def authenticate_grantless(scope)
      @grantless = true
      @scope = scope

      request_role_credentials
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

    def ask_for_restricted_data_token
      @logger.debug('this request will require restricted data token')
      if @restricted_data_token && !expired?(@restricted_data_token_expirest_at)
        @logger.debug(
          'restricted_data_token` is nil or state, making /tokens2021 request',
        )
        @logger.debug(
          'restricted_data_token is still valid, skipping /tokes20210 request',
        )
        return
      end
      @logger.debug('`access_token` is nil or expired')
      tokens_api = AmazonSpClients::SpTokens2021::TokensApi.new(self)

      # TODO: handle errors for restricted_data_token request!
      tokens_resp = tokens_api.create_restricted_data_token(RESTRICTED_OPS)

      @restricted_data_token_expirest_at =
        duration_to_date(tokens_resp.expires_in)
      @restricted_data_token = tokens_resp.restricted_data_token
    end

    private

    # Returns nil on success, error struct on error
    def request_role_credentials
      if !@role_credentials.nil? && !@role_credentials.session_token.nil? &&
           !expired?(@role_credentials.expires)
        @logger.debug('`session_token` is still valid - skipping STS request')
        return
      end
      @logger.debug(
        '`session_token` is emtpy or stale - asking STS for credentials',
      )
      resp_struct = AmazonSpClients::Sts.new.assume_role
      @role_credentials = resp_struct

      # STS returns expiration date (instead of duration, like all
      # more recent amz services). This, would make "old" VCR cassettes to
      # fail. It seems that session token is vailid for 1h, so we force/set
      # new date here:
      @role_credentials.expires = duration_to_date(3600)
    end

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

      if @grantless
        auth.exchange('client_credentials', @scope)
      else
        auth.exchange('refresh_token')
      end
    end

    def expired?(expires_str)
      return true if expires_str.nil?
      expires_time = Time.strptime(expires_str, '%Y-%m-%dT%H:%M:%S%Z')
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
