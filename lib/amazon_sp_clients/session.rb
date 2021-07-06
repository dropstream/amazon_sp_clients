# frozen_string_literal: true

require 'time'
require 'amazon_sp_clients/sp_tokens_2021'

module AmazonSpClients
  class Session
    class Error < Struct.new(:error, :message, :original_response)
    end

    RESTRICTED_OPS = {
      restrictedResources: [
        {
          method: "GET",
          path: "/orders/v0/orders/{orderId}/buyerInfo"
        }.freeze,
        {
          method: "GET",
          path: "/orders/v0/orders/{orderId}/address"
        }.freeze,
      ].freeze
    }.freeze

    attr_reader :access_token, :error, :role_credentials, :restricted_data_token

    def initialize(config = Configuration.default)
      @config = config
      @logger = @config.logger

      @sts_err = nil
      @token_err = nil
      @refresh_token = nil
      @access_token = nil
      @access_token_expires_at = nil
      @restricted_data_token = nil
      @restricted_data_token_err = nil
      @restricted_data_token_expirest_at = nil
      @role_credentials = nil
      @grantless = false
      @scope = nil
    end

    # @return [AmazonSpClients::Session::Error | nil, self | nil]
    def authenticate(refresh_token)
      @refresh_token = refresh_token
      @grantless = false
      @scope = nil
      
      auth_with_sts
    end

    # @return [AmazonSpClients::Session::Error | nil, self | nil]
    def authenticate_grantless(scope)
      @grantless = true
      @scope = scope

      auth_with_sts
    end

    def refresh
      if @grantles
        authenticate_grantless(@scope)
      elsif !@refresh_token.nil?
        authenticate(@refresh_token)
      end
    end

    def ask_for_restricted_data_token
      @logger.info('this request will require restricted data token')
      if @restricted_data_token && !expired?(@restricted_data_token_expirest_at)
        @logger.info(
          'restricted_data_token` is nil or state, making /tokens2021 request'
        )
        @logger.info(
          'restricted_data_token is still valid, skipping /tokes20210 request'
        )
        return
      end
      @logger.info('`access_token` is nil or expired')
      tokens_api = AmazonSpClients::SpTokens2021::TokensApi.new(self)
      # TODO: handle errors for restricted_data_token request!
      tokens_resp = tokens_api.create_restricted_data_token(RESTRICTED_OPS)

      @restricted_data_token_expirest_at = duration_to_date(tokens_resp.expires_in)
      @restricted_data_token = tokens_resp.restricted_data_token
    end

    private

    def auth_with_sts
      request_role_credentials
      if @sts_err
        return nil, AmazonSpClients::Session::Error.new(
            "#{@sts_err.type}: #{@sts_err.code}",
            @sts_err.message,
            @sts_err.original_response
          )
      end

      request_access_token
      if @token_err
        return nil, AmazonSpClients::Session::Error.new(
            @token_err.error,
            @token_err.error_description,
            @token_err.original_response
          )
      end

      return self, nil
    end

    # Returns nil on success, error struct on error
    def request_role_credentials
      if !@role_credentials.nil? && !@role_credentials.session_token.nil? &&
          !expired?(@role_credentials.expires)
        @logger.info('`session_token` is still valid - skipping STS request')
        return
      end
      @logger.info(
        '`session_token` is emtpy or stale - asking STS for credentials'
      )
      is_success, resp_struct = assume_role_request
      if is_success
        @role_credentials = resp_struct
        # STS returns expiration date (instead of duration, like all
        # more recent amz services). This, would make "old" VCR cassettes to
        # fail. It seems that session token is vailid for 1h, so we force/set
        # new date here:
        @role_credentials.expires = duration_to_date(3600)
      else
        @logger.error('STS request returned error')
        @role_credentials = nil
        @sts_err = resp_struct
      end
    end

    # Returns nil on success, error struct on error
    def request_access_token
      if @access_token && !expired?(@access_token_expires_at)
        @logger.info('`access_token` is present - skipping token request')
        return
      end
      @logger.info('`access_token` is nil or expired')
      is_success, resp_struct = exchange_token_request
      if is_success
        @access_token = resp_struct.access_token
        @refresh_token = resp_struct.refresh_token
        @access_token_expires_at = duration_to_date(resp_struct.expires_in)
      else
        @logger.error('token request returned error')
        @access_token = nil
        @refresh_token = nil
        @access_token_expires_at = nil
        @token_err = resp_struct
      end
    end

    def exchange_token_request
      auth = AmazonSpClients::TokenExchangeAuth.new(@refresh_token)
      if @grantless
        resp_struct = auth.exchange('client_credentials', @scope)
      else
        resp_struct = auth.exchange('refresh_token')
      end
      return resp_struct.original_response.success?, resp_struct
    end

    def assume_role_request
      resp_struct = AmazonSpClients::Sts.new.assume_role
      return resp_struct.original_response.success?, resp_struct
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
