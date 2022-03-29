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
            credentials_provider: @options[:session].role_credentials,
          )
        signature =
          signer.sign_request(
            http_method: env.method.to_s.upcase!,
            url: env.url,
            headers: env.request_headers,
            body: env.request_body,
          )

        # Add signature headers
        signature_headers = signature.headers
        env.request_headers.merge!(
          {
            'authorization' => signature_headers['authorization'],
            'host' => signature_headers['host'],
            CRYPTO_HEADER => signature_headers[CRYPTO_HEADER],
            'x-amz-date' => signature_headers['x-amz-date'],
            SESSION_HEADER => signature_headers[SESSION_HEADER],
          },
        )

        @app.call env
      end
    end
  end
end
