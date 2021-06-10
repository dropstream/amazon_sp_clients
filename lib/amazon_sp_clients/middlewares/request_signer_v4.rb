# frozen_string_literal: true

require 'uri'
require 'faraday'
require 'forwardable'

module AmazonSpClients
  module Middlewares
    class RequestSignerV4 < Faraday::Middleware
      AUTH_HEADER = 'Authorization'
      CRYPTO_HEADER = 'x-amz-content-sha256'
      SESSION_HEADER = 'x-amz-security-token'

      extend Forwardable
      def_delegators :'Faraday::Utils', :parse_query

      attr_reader :app, :options

      def initialize(app, options = {})
        super(app)
        @app = app
        @options = options

        if options.has_key?(:session)
          @session = options.delete(:session)
        end
      end

      def call(env)
        url = URI(env.url)

        if @session
          role_credentials = @session.role_credentials
          access_key = role_credentials.access_key
          secret_key = role_credentials.secret_key
          session_token = role_credentials.session_token
        else
          access_key = @options[:access_key]
          secret_key = @options[:secret_key]
          session_token = nil
        end

        env.request_headers.merge!({ host: url.host })

        if sts_request?
          env.request_headers.merge!(
            {
              "#{CRYPTO_HEADER}" =>
                AmazonSpClients::AmznV4Signer.hexdigest(env.request_body)
            }
          )
        else
          if session_token
            env.request_headers.merge!(
              {
                "#{SESSION_HEADER}" => session_token
              }
            )
          end
        end

        signer =
          AmazonSpClients::AmznV4Signer.new do |s|
            s.access_key = access_key
            s.secret_key = secret_key

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
