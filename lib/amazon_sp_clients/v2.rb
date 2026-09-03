# frozen_string_literal: true

require 'amazon_sp_clients/version'
require 'amazon_sp_clients/marketplaces'
require 'amazon_sp_clients/api_error'
require 'amazon_sp_clients/api_response'

require 'amazon_sp_clients/v2/errors'
require 'amazon_sp_clients/v2/config'
require 'amazon_sp_clients/v2/token'
require 'amazon_sp_clients/v2/error_mapper'
require 'amazon_sp_clients/v2/lwa'
require 'amazon_sp_clients/v2/credentials'
require 'amazon_sp_clients/v2/rdt'
require 'amazon_sp_clients/v2/documents'
require 'amazon_sp_clients/v2/api'
require 'amazon_sp_clients/v2/client'

# Ruby clients for the Amazon Selling Partner API.
module AmazonSpClients
  # The second-generation client: explicit per-client configuration, a
  # thread-safe token source, first-class restricted data tokens and
  # typed errors. Loads without the v1 code.
  #
  #   require 'amazon_sp_clients/v2'
  #
  #   config = AmazonSpClients::V2::Config.new(endpoint: 'na')
  #   client = AmazonSpClients::V2::Client.new(config) { current_access_token }
  #   client.orders_v0.get_orders(marketplace_ids, created_after: since)
  module V2
  end
end
