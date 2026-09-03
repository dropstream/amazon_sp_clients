# frozen_string_literal: true

require 'amazon_sp_clients/v2/token'

module AmazonSpClients
  module V2
    # Restricted data tokens (RDT). The Tokens API issues a short-lived
    # token for named restricted resources; a call that returns PII sends
    # that token instead of the normal access token.
    #
    #   client.orders_v0.get_orders(ids, rdt: RDT::ORDERS_AND_ITEMS)
    #   client.reports_2021.get_report_document(id, rdt: [RDT.resource('GET', path)])
    module RDT
      # One restricted resource: HTTP method, path template and the PII
      # data elements wanted. A value object, so equal resources make
      # equal cache keys.
      Resource = Data.define(:http_method, :path, :data_elements)

      class Resource
        # @return [Hash] the shape the Tokens API expects
        def to_request
          { method: http_method, path: path, dataElements: data_elements }.compact
        end
      end

      # Orders with buyer info and shipping address (v1's :orders).
      ORDERS = [
        Resource.new(http_method: 'GET', path: '/orders/v0/orders',
                     data_elements: %w[buyerInfo shippingAddress].freeze)
      ].freeze

      # ORDERS plus order items with buyer info (v1's :orders_and_items).
      ORDERS_AND_ITEMS = [
        *ORDERS,
        Resource.new(http_method: 'GET', path: '/orders/v0/orders/{orderId}/orderItems',
                     data_elements: %w[buyerInfo].freeze)
      ].freeze

      # @param http_method [String] e.g. 'GET'
      # @param path [String] path template, e.g. '/orders/v0/orders/{orderId}'
      # @param data_elements [Array<String>, nil] PII fields wanted
      # @return [Resource]
      def self.resource(http_method, path, data_elements = nil)
        Resource.new(http_method: http_method, path: path, data_elements: data_elements)
      end

      # Restricted tokens per resource list, with expiry. One lock, held
      # while a missing token is fetched, so concurrent callers for the
      # same resources cause one Tokens API call. The fetch block runs
      # inside the lock and must not come back to this cache.
      class Cache
        def initialize
          @entries = {}
          @mutex = Mutex.new
        end

        # @param resources [Array<Resource>]
        # @yieldreturn [Token] a fresh restricted token, asked for on a miss
        # @return [String] the restricted data token
        def fetch(resources)
          key = cache_key(resources)

          @mutex.synchronize do
            entry = @entries[key]
            return entry.access_token if entry && !entry.expired?

            sweep
            token = yield
            @entries[key] = token
            token.access_token
          end
        end

        # @return [Integer] cached tokens, expired ones included until the next miss
        def size = @mutex.synchronize { @entries.size }

        private

        # A frozen copy, so the caller's own array is left alone.
        def cache_key(resources)
          list = Array(resources)
          list.frozen? ? list : list.dup.freeze
        end

        def sweep
          @entries.delete_if { |_, token| token.expired? }
        end
      end
    end
  end
end
