# frozen_string_literal: true

require 'json'
require 'zlib'
require 'faraday'
require 'multi_xml'
require 'amazon_sp_clients/adapter_loader'
require 'amazon_sp_clients/v2/config'
require 'amazon_sp_clients/v2/errors'
require 'amazon_sp_clients/v2/error_mapper'

module AmazonSpClients
  module V2
    # Feed and report documents live on presigned S3 urls: outside the
    # SP-API host, without the access token. A feed goes out in three
    # steps (create the document, PUT the content to its url, create the
    # feed); feed results and reports come back by GET, gzipped when the
    # document says so.
    #
    # Every +document+ argument is the payload Hash the Feeds or Reports
    # API returned for it (+:url+, +:compressionAlgorithm+).
    class Documents
      # Value of +compressionAlgorithm+ for gzipped documents.
      GZIP = 'GZIP'
      # Set on uploads; read on downloads to pick the parser.
      CONTENT_TYPE_HEADER = 'Content-Type'
      # Content types parsed as JSON; anything else is parsed as XML.
      JSON_TYPES = /json/i

      # @param config [Config] timeouts and user agent
      def initialize(config)
        @config = config
        @errors = ErrorMapper.new(:documents)
        @conn = build_connection
      end

      # @param document [Hash] payload of createFeedDocument
      # @param content_type [String] the one given to createFeedDocument
      # @param body [String] feed content
      # @return [nil]
      # @raise [DocumentError, ConnectionError]
      def upload(document, content_type, body)
        send_request(:put, document.fetch(:url), body, CONTENT_TYPE_HEADER => content_type)

        nil
      end

      # @param document [Hash] payload of getFeedDocument
      # @return [Hash] the processing report, string-keyed; JSON or XML by content type
      # @raise [DocumentError, ConnectionError]
      def download_feed_result(document)
        response = fetch(document)

        parse(inflate(response.body, document), response.headers[CONTENT_TYPE_HEADER])
      end

      # @param document [Hash] payload of getReportDocument
      # @return [String] the report; UTF-8 tagged when it was gzipped,
      #   otherwise as delivered
      # @raise [DocumentError, ConnectionError]
      def download_report_document(document)
        inflate(fetch(document).body, document)
      end

      private

      def build_connection
        options = { timeout: @config.timeout, open_timeout: @config.open_timeout }
        headers = { 'User-Agent' => @config.user_agent }

        Faraday.new(request: options, headers: headers) do |conn|
          conn.adapter Faraday::Adapter::HTTPClient
        end
      end

      def fetch(document)
        send_request(:get, document.fetch(:url), nil, {})
      end

      def send_request(method, url, body, headers)
        response = @conn.run_request(method, url, body, headers)

        @errors.check!(response)
      rescue *ErrorMapper::TRANSPORT_ERRORS => e
        raise @errors.transport_error(e, method: method, url: url)
      end

      # Zlib.gunzip returns binary; the documents are text.
      def inflate(body, document)
        return body unless document[:compressionAlgorithm].to_s.casecmp?(GZIP)

        Zlib.gunzip(body).force_encoding(Encoding::UTF_8)
      end

      def parse(body, content_type)
        return JSON.parse(body) if content_type.to_s.match?(JSON_TYPES)

        MultiXml.parse(body)
      end
    end
  end
end
