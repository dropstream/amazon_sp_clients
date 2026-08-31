# frozen_string_literal: true

require 'faraday'
require 'aws-sigv4'

module AmazonSpClients
  module Middlewares
    class RequestSignerV4 < Faraday::Middleware
      CRYPTO_HEADER = 'x-amz-content-sha256'
      SESSION_HEADER = 'x-amz-security-token'

      def initialize(app, options = {})
        super(app)
        @app = app
        @options = options
      end

      def call(env)
        # https://www.rubydoc.info/gems/aws-sigv4/1.0.0/Aws/Sigv4/Signer#sign_request-instance_method
        signer =
          Aws::Sigv4::Signer.new(
            service: 'execute-api',
            region: @options[:region],
            credentials_provider: @options[:session].credentials_provider
          )

        signature =
          signer.sign_request(
            http_method: env.method.to_s.upcase!,
            url: env.url,
            headers: env.request_headers,
            body: env.request_body
          )

        signature_headers = signature.headers
        env.request_headers.merge!(
          'authorization' => signature_headers['authorization'],
          'host' => signature_headers['host'],
          CRYPTO_HEADER => signature_headers[CRYPTO_HEADER],
          'x-amz-date' => signature_headers['x-amz-date']
        )

        # Only include SESSION_HEADER if it exists in signature_headers
        if signature_headers.key?(SESSION_HEADER)
          env.request_headers[SESSION_HEADER] = signature_headers[SESSION_HEADER]
        end

        @app.call env
      end
    end
  end
end
