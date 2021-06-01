require 'amazon_sp_clients/version'

require 'amazon_sp_clients/api_client'
require 'amazon_sp_clients/api_error'
require 'amazon_sp_clients/configuration'

require 'amazon_sp_clients/auth'

module AmazonSpClients
  MARKETPLACE_IDS = {
    # NA
    us: 'ATVPDKIKX0DER'.freeze,
    ca: 'A2EUQ1WTGCTBG2'.freeze,
    mx: 'A1AM78C64UM0Y8'.freeze,
    br: 'A2Q3Y263D00KWC'.freeze,
    # EU
    es: 'A1RKKUPIHCS9HS'.freeze,
    gb: 'A1F83G8C2ARO7P'.freeze,
    fr: 'A13V1IB3VIYZZH'.freeze,
    nl: 'A1805IZSGTT6HS'.freeze,
    de: 'A1PA6795UKMFR9'.freeze,
    it: 'APJ6JRA9NG5V4'.freeze,
    se: 'A2NODRKZP88ZB9'.freeze,
    pl: 'A1C3SOZRARQ6R3'.freeze,
    eg: 'ARBP9OOSHTCHU'.freeze,
    tr: 'A33AVAJ2PDY3EV'.freeze,
    ae: 'A2VIGQ35RCS4UG'.freeze,
    in: 'A21TJRUUN4KGV'.freeze,
    # FE
    sg: 'A19VAU5U5O7RUS'.freeze,
    au: 'A39IBJ37TRP1C6'.freeze,
    jp: 'A1VC38T7YXB528'.freeze
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
