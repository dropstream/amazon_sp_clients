# frozen_string_literal: true

require 'uri'
require 'faraday'
require 'forwardable'

module AmazonSpClients
  module Middlewares
    class StsSigner < Faraday::Middleware
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
        # TODO: only if action is sts?
        env.request_headers.merge!({ "#{CRYPTO_HEADER}" => AmazonSpClients::AmznV4Signer.hexdigest(env.request_body) })

        signer =
          AmazonSpClients::AmznV4Signer.new do |s|
            s.access_key = @options[:access_key]
            s.secret_key = @options[:secret_key]
            s.region = @options[:region]
            # TODO: extract var
            s.service_name = 'sts'

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
        if url.query.nil? || url.query.empty?
          {}
        else
          parse_query(url.query)
        end
      end
    end
  end
end
