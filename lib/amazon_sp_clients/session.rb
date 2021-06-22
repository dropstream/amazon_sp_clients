# frozen_string_literal: true

require 'time'

module AmazonSpClients
  class Session
    class Error < Struct.new(:error, :message, :original_response)
    end

    attr_reader :access_token, :error, :role_credentials

    def initialize(config = Configuration.default)
      @config = config
      @logger = @config.logger

      @sts_err = nil
      @token_err = nil
      @refresh_token = nil
      @access_token = nil
      @access_token_expires_at = nil
      @role_credentials = nil
    end

    # @return [AmazonSpClients::Session::Error | nil] does not raise
    def authenticate(refresh_token)
      @refresh_token = refresh_token

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

    def refresh
      return if @refresh_token.nil?
      authenticate(@refresh_token)
    end

    private

    # Returns nil on success, error struct on error
    def request_role_credentials
      if !@role_credentials.nil? && !@role_credentials.session_token.nil? &&
          !expired?(@role_credentials.expires)
        @logger.info('`session_token` is still valid - skipping STS request')
      end
      @logger.info(
        '`session_token` is emtpy or stale - asking STS for credentials'
      )
      is_success, resp_struct = assume_role_request
      if is_success
        @role_credentials = resp_struct
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
      resp_struct = auth.exchange('refresh_token')
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
