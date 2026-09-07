# frozen_string_literal: true

require 'uri'

module AmazonSpClients
  module V2
    # Base class of the generated API classes. Holds the client and the
    # small helpers the generated methods use to shape a request.
    #
    #   class OrdersV0 < Api
    #     def get_order(order_id, rdt: nil)
    #       request(:get, "/orders/v0/orders/#{encode(order_id)}", rdt: rdt)
    #     end
    #   end
    class Api
      # @param client [Client]
      def initialize(client)
        @client = client
      end

      private

      # @see Client#request
      def request(method, path, query: {}, headers: {}, body: nil, rdt: nil)
        @client.request(method, path, query: query, headers: headers, body: body, rdt: rdt)
      end

      # Array parameters travel comma-separated (collectionFormat csv).
      # nil stays nil so the parameter is left out; an empty array sends
      # an empty value, as v1 did.
      def csv(value)
        return nil if value.nil?

        Array(value).join(',')
      end

      # Percent-encodes one path segment; SKUs can hold spaces and slashes.
      def encode(value)
        URI.encode_uri_component(value.to_s)
      end
    end
  end
end
