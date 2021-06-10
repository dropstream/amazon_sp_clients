# frozen_string_literal: true

require 'time'
require 'thread'

module AmazonSpClients
  class Session
    @@lock = Mutex.new
    @@role_credentials = AmazonSpClients::StsResponse.new

    def initialize(refresh_token, config = Configuration.default)
      @config = config
      @logger = @config.logger

      @refresh_token = refresh_token

      @access_token = nil
      @access_token_expires_at = nil
      @refresh_token = nil # FIXME: unused
    end

    def access_token
      if @access_token && !expired?(@access_token_expires_at)
        @logger.debug('`access_token` is present')
        return @access_token
      end
      @logger.debug('`access_token` is nil or expired')
      is_success, resp = exchange_token_request
      if is_success
        @access_token = resp.access_token
        @refresh_token = resp.refresh_token
        @access_token_expires_at = duration_to_date(resp.expires_in)
        return @access_token
      else
        # TODO: how to pass/propagate errors to integration?
        # TODO: how to pass/propagate errors to integration?
        raise 'Failed to exchange tokens'
      end
    end

    def role_credentials
      @@lock.synchronize do
        if !@@role_credentials.session_token.nil? &&
             !expired?(@@role_credentials.role_expires)
          @logger.debug('`session_token` is still valid - skipping STS request')
          return @@role_credentials
        end
        @logger.debug(
          '`session_token` is emtpy or stale - asking STS for credentials'
        )
        is_success, resp_struct = assume_role_request
        if is_success
          @@role_credentials = resp_struct
          return @@role_credentials
        else
          # TODO: how to pass/propagate errors to integration?
          # TODO: how to pass/propagate errors to integration?
          raise 'Failed getting temporary credentials from STS'
        end
      end
    end

    private

    def exchange_token_request
      auth = AmazonSpClients::TokenExchangeAuth.new(@refresh_token)
      resp_struct = auth.exchange('refresh_token')
      return resp_struct.original_response.success?, resp_struct
    end

    def assume_role_request
      resp_struct = AmazonSpClients::Sts.new.assume_role
      return resp_struct.original_response.success?, resp_struct
    end

    # def validate
    #   # TODO: those are NOT required for grantless ops?
    #   required = %w[
    #     access_key
    #     secret_key
    #     role_arn
    #     client_id
    #     client_secret
    #   ]

    #   required.each do |param|
    #     unless !@config.send(param).nil? && !@config.send(param).empty?
    #       msg = "Missing required '#{param}' configuration parameter"
    #       @logger.error(msg)
    #       raise msg
    #     end
    #   end
    # end

    def expired?(expires_str)
      return true if expires_str.nil?
      expires_time = Time.strptime(expires_str, '%Y-%m-%dT%H:%M:%S%Z')
      now = Time.now.utc
      now >= expires_time - 60 # 60s safety net
    end

    def duration_to_date(seconds)
      now = Time.now.utc
      new = now + seconds.to_i
      new.strftime('%Y-%m-%dT%H:%M:%SZ')
    end
  end
end
