# frozen_string_literal: true

require 'amazon_sp_clients/version'

require 'amazon_sp_clients/api_client'
require 'amazon_sp_clients/api_error'
require 'amazon_sp_clients/configuration'

# require 'amazon_sp_clients/auth'
require 'amazon_sp_clients/amzn_v4_signer'

module AmazonSpClients
  REGIONS = {
    'us-east-1' => 'sellingpartnerapi-na.amazon.com',
    'eu-west-1' => 'sellingpartnerapi-eu.amazon.com',
    'us-west-2' => 'sellingpartnerapi-fe.amazon.com',
  }.freeze

  MARKETPLACE_IDS = {
    # NA
    us: 'ATVPDKIKX0DER',
    ca: 'A2EUQ1WTGCTBG2',
    mx: 'A1AM78C64UM0Y8',
    br: 'A2Q3Y263D00KWC',
    # EU
    es: 'A1RKKUPIHCS9HS',
    gb: 'A1F83G8C2ARO7P',
    fr: 'A13V1IB3VIYZZH',
    nl: 'A1805IZSGTT6HS',
    de: 'A1PA6795UKMFR9',
    it: 'APJ6JRA9NG5V4',
    se: 'A2NODRKZP88ZB9',
    pl: 'A1C3SOZRARQ6R3',
    eg: 'ARBP9OOSHTCHU',
    tr: 'A33AVAJ2PDY3EV',
    ae: 'A2VIGQ35RCS4UG',
    in: 'A21TJRUUN4KGV',
    # FE
    sg: 'A19VAU5U5O7RUS',
    au: 'A39IBJ37TRP1C6',
    jp: 'A1VC38T7YXB528'
  }.freeze

  class << self
    # If no block given, return the default Configuration object.
    def configure
      if block_given?
        yield(Configuration.default)
      else
        Configuration.default
      end
    end
  end
end
