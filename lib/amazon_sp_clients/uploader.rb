# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'zlib'
require 'multi_xml'

module AmazonSpClients
  class Uploader
    attr_reader :response

    def initialize
      config = AmazonSpClients.configure
      @conn =
        Faraday.new(request: { timeout: config.timeout }) do |c|
          c.adapter Faraday::Adapter::HTTPClient
          c.use AmazonSpClients::Middlewares::RaiseError, { service: :uploads }
          c.response :logger, config.logger, {}
        end
    end

    def upload(feed_doc, doc_content_type, payload)
      upload_url = feed_doc[:url]
      document = payload

      file = StringIO.new(document)

      @response =
        @conn.put(upload_url) do |req|
          req.headers.merge!('Content-Type' => doc_content_type)
          req.body = file
        end
    end
  end

  class Downloader
    # {
    #   "compressionAlgorithm": "GZIP",
    #   "feedDocumentId": "amzn1.tortuga.3.ed4cd0d8-447b-4c22-96b5-52da8ace1207.T3YUVYPGKE9BMY",
    #   "url": "https://tortuga-prod-na.s3.amazonaws.com/%2FNinetyDays/amzn1.tortuga.3.920614b0-fc4c-4393-b0d9-fff175300000.T29XK4YL08B2VM?xxx
    # }
    def initialize(feed_processing_report)
      @config = AmazonSpClients.configure
      @feed_document_id = feed_processing_report[:feedDocumentId]

      @url = feed_processing_report[:url]
      @compression_algorithm = feed_processing_report[:compressionAlgorithm]

      @conn =
        Faraday.new(request: { timeout: @config.timeout }) do |c|
          c.use AmazonSpClients::Middlewares::RaiseError, { service: :uploads }
          c.response :logger, @config.logger, {}
        end
    end

    def download
      resp = @conn.get(@url)
      decoded_body = inflate_document(resp.body)

      content_type = resp.headers['content-type'].to_s.downcase

      if content_type =~ /json/
        JSON.parse(decoded_body)
      else
        MultiXml.parse(decoded_body)
      end
    end

    private

    def inflate_document(body)
      if @compression_algorithm.to_s.downcase == 'gzip'
        Zlib.gunzip(body)
      else
        body
      end
    end
  end
end
