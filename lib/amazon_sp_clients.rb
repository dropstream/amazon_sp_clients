# frozen_string_literal: true

require 'amazon_sp_clients/version'
require 'amazon_sp_clients/marketplaces'

require 'amazon_sp_clients/middlewares/raise_error'

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
  # Normal calls
  def self.new_session(refresh_token)
    AmazonSpClients::Session.new.authenticate(refresh_token)
  end

  # Grantless calls
  def self.new_migration_session
    scope = 'sellingpartnerapi::migration'
    AmazonSpClients::Session.new.authenticate_grantless(scope)
  end

  def self.new_callback_session(&)
    AmazonSpClients::Session.new.with_callback(&)
  end

  def self.upload_feed_data(
    feed_document_response,
    document_content_type,
    payload
  )
    uploader = AmazonSpClients::Uploader.new
    uploader.upload(feed_document_response, document_content_type, payload)

    uploader.response
  end

  def self.download_feed_report(feed_processing_report)
    AmazonSpClients::Downloader.new(feed_processing_report).download
  end

  def self.download_report_document(doc_params)
    url = doc_params.fetch(:url)
    conn =
      Faraday.new(request: { timeout: configure.timeout }) do |c|
        c.use AmazonSpClients::Middlewares::RaiseError, { service: :uploads }
      end

    conn.get(url)&.body
  end

  def self.configure
    if block_given?
      yield(Configuration.default)
    else
      Configuration.default
    end
  end
end
