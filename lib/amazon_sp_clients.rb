# frozen_string_literal: true

require 'amazon_sp_clients/version'

require 'amazon_sp_clients/amzn_v4_signer'
require 'amazon_sp_clients/middlewares/request_signer_v4'
require 'amazon_sp_clients/middlewares/last_request_response'

require 'amazon_sp_clients/sts'
require 'amazon_sp_clients/token_exchange_auth'
require 'amazon_sp_clients/session'

require 'amazon_sp_clients/api_client'
require 'amazon_sp_clients/api_error'
require 'amazon_sp_clients/configuration'
require 'amazon_sp_clients/api_response'

require 'amazon_sp_clients/uploader'

require 'faraday'
require 'httpclient'

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

  # Set default adapter (can be any other but don't use net/http with this gem!)
  Faraday.default_adapter = Faraday::Adapter::HTTPClient

  def self.new_session(refresh_token)
    AmazonSpClients::Session.new.authenticate(refresh_token)
  end

  def self.new_migration_session
    scope = 'sellingpartnerapi::migration'
    AmazonSpClients::Session.new.authenticate_grantless(scope)
  end

  # FIXME: other way for defining/running callbacks?
  Thread.current[:amazon_sp_clients_callbacks] = []

  class << self
    def upload_feed_data(feed_document_response, document_content_type, xml_str)
      u = AmazonSpClients::Uploader.new(feed_document_response, document_content_type, xml_str)
      resp = u.upload
      resp
    end

    def configure
      if block_given?
        yield(Configuration.default)
      else
        Configuration.default
      end
    end

    # def on_request(&block)
    #   Thread.current[:amazon_sp_clients_callbacks].push(
    #     -> () { block.call(Thread.current[:amazon_sp_clients_last_request]) }
    #   )
    #   nil
    # end

    def on_response(&block)
      Thread.current[:amazon_sp_clients_callbacks].push(
        -> () { block.call(Thread.current[:amazon_sp_clients_last_response]) }
      )
      nil
    end

    def run_callbacks
      Thread.current[:amazon_sp_clients_callbacks].each do |cb|
        cb.call
      end
    end
  end
end
