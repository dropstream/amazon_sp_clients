# frozen_string_literal: true

require 'uri'
require 'faraday'
require 'forwardable'

module AmazonSpClients
  module Middlewares
    class RequestSignerV4 < Faraday::Middleware
      AUTH_HEADER = 'Authorization'
      CRYPTO_HEADER = 'x-amz-content-sha256'

      extend Forwardable
      def_delegators :'Faraday::Utils', :parse_query

      attr_reader :app, :options

      def initialize(app, options = {})
        super(app)
        @app = app
        @options = options
      end

      def call(env)
        url = URI(env.url)

        env.request_headers.merge!({ host: url.host })

        if sts_request?
          env.request_headers.merge!(
            {
              "#{CRYPTO_HEADER}" =>
                AmazonSpClients::AmznV4Signer.hexdigest(env.request_body)
            }
          )
        end

        signer =
          AmazonSpClients::AmznV4Signer.new do |s|
            s.access_key = @options[:access_key]
            s.secret_key = @options[:secret_key]

            s.region = @options[:region]

            s.service_name = 'sts' if sts_request?

            s.request = {
              headers: env.request_headers,
              path: url.path,
              http_method: env.method,
              query: query(url),
              payload: env.request_body
            }
          end
        env[:request_headers][AUTH_HEADER] = signer.build_authorization_header

        @app.call env
      end

      private

      def query(url)
        url.query.nil? || url.query.empty? ? {} : parse_query(url.query)
      end

      def sts_request?
        @options.has_key?(:service_name) && @options[:service_name] == 'sts'
      end
    end
  end
end
