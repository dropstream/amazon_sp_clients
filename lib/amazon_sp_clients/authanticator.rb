# frozen_string_literal: true

require 'time'

module AmazonSpClients
  class Authenticator
    def initialize(config = Configuration.default)
      @config = config
      @logger = @config.logger
    end

    def authenticate!
      # Are required creds configured?
      validate

      # Do we have temporary IAM role credentials?
      if !@config.session_token.nil? && !expired?(@config.role_expires)
        @logger.debug('`session_token` is still valid - skipping STS request')
      else
        @logger.debug(
          '`session_token` is emtpy or stale - asking STS for credentials'
        )
        is_success, resp = assume_role_request
        if is_success
          @config.role_access_key = resp.access_key
          @config.role_secret_key = resp.secret_key
          @config.session_token = resp.session_token
          @config.role_expires = resp.expires
        else
          raise 'Failed getting temporary credentials from STS'
        end
      end

      # Do we have access_token?
      if !@config.access_token.nil? && !expired?(@config.access_token_expires)
        @logger.debug('`access_token` is still valid - skipping auth request')
      else
        @logger.debug('`access_token` is nil or state - trying to exchange')

        is_success, resp = exchange_token_request
        if is_success
          @config.access_token = resp.access_token
          @config.refresh_token = resp.refresh_token
          @config.access_token_expires = duration_to_date(resp.expires_in)
        else
          raise 'Failed to exchange tokens'
        end
      end
    end

    private

    def exchange_token_request
      auth = AmazonSpClients::TokenExchangeAuth.new
      resp = auth.exchange('refresh_token')
      return resp.original_response.success?, resp
    end

    def assume_role_request
      resp = AmazonSpClients::Sts.new.assume_role
      return resp.original_response.success?, resp
    end

    def validate
      # TODO: those are NOT required for grantless ops?
      required = %w[
        access_key
        secret_key
        role_arn
        client_id
        client_secret
        refresh_token
      ]

      required.each do |param|
        unless !@config.send(param).nil? && !@config.send(param).empty?
          msg = "Missing required '#{param}' configuration parameter"
          @logger.error(msg)
          raise msg
        end
      end
    end

    def expired?(expires_str)
      return true if expires_str.nil?
      expires_time = Time.strptime(expires_str, '%Y-%m-%dT%H:%M:%S%Z')
      now = Time.now.utc
      now >= expires_time
    end

    def duration_to_date(seconds)
      now = Time.now.utc
      new = now + seconds.to_i
      new.strftime("%Y-%m-%dT%H:%M:%SZ")
    end
  end
end
