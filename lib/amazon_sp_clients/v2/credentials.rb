# frozen_string_literal: true

require 'amazon_sp_clients/v2/token'

module AmazonSpClients
  module V2
    # Where the client gets the access token for each request. Every
    # kind answers one message, +access_token+, and returns the value to
    # the caller: the token is never parked on a shared object and read
    # back in a second step, so a request cannot carry another thread's
    # token.
    module Credentials
      # Asks a block for the current token before every request. This
      # is the production path: the host refreshes tokens out of band
      # and the block returns whatever it holds now, so a client that
      # runs for hours keeps sending fresh tokens.
      #
      #   Credentials::Callback.new { store.access_token }
      #
      # The block's value goes on the wire as it is; a missing token
      # surfaces as Amazon's own 401 or 403.
      class Callback
        # @yieldreturn [String] the current access token
        def initialize(&block)
          raise ArgumentError, 'a block returning the access token is required' unless block

          @block = block
        end

        # @return [String]
        def access_token = @block.call
      end

      # Exchanges a refresh token with LWA and caches the result until it
      # expires. One exchange per expiry, even when many threads ask at
      # once: the expiry check runs again under the lock.
      class RefreshToken
        # @param lwa [LWA] anything answering +exchange(refresh_token:)+ with a Token
        # @param refresh_token [String] the refresh token to start from
        def initialize(lwa, refresh_token)
          @lwa = lwa
          @initial_refresh_token = refresh_token
          @token = nil
          @mutex = Mutex.new
        end

        # @return [String] a fresh access token, exchanging when needed
        def access_token
          token = @token
          return token.access_token if token && !token.expired?

          @mutex.synchronize do
            token = @token
            return token.access_token if token && !token.expired?

            token = exchange
            @token = token
            token.access_token
          end
        end

        # The refresh token the next exchange will send: the latest one
        # LWA returned, else the initial one. Persist it if it changes.
        #
        # @return [String]
        def refresh_token
          @token&.refresh_token || @initial_refresh_token
        end

        private

        # LWA may leave refresh_token out of the response; keep the one
        # we have, so the stored Token always knows what to send next.
        def exchange
          token = @lwa.exchange(refresh_token: refresh_token)
          return token if token.refresh_token

          token.with(refresh_token: refresh_token)
        end
      end
    end
  end
end
