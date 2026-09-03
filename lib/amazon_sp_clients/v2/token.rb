# frozen_string_literal: true

require 'amazon_sp_clients/v2/errors'

module AmazonSpClients
  module V2
    # An access token with its expiry, as returned by LWA or by the
    # Tokens API (restricted data tokens). Frozen: a refresh swaps the
    # whole object, so a reader never sees a token paired with another
    # exchange's expiry.
    Token = Data.define(:access_token, :token_type, :expires_in, :expires_at, :refresh_token)

    class Token
      # Seconds before the real expiry at which the token counts as
      # expired, so a request started just before it never carries a
      # dead token.
      EXPIRY_SKEW = 60

      # @param now [Time]
      # @return [Boolean] true within EXPIRY_SKEW of expiry, or when
      #   the token has no expiry at all
      def expired?(now = Time.now.utc)
        return true if expires_at.nil?

        now >= expires_at - EXPIRY_SKEW
      end

      # Token values stay out of consoles and error trackers.
      #
      # @return [String]
      def inspect
        fields = to_h.merge(access_token: access_token && FILTERED,
                            refresh_token: refresh_token && FILTERED)

        "#<#{self.class.name} #{fields.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')}>"
      end
    end
  end
end
