# frozen_string_literal: true

# require 'uri'
require 'faraday'
# require 'forwardable'
require 'aws-sigv4'
require 'aws-sdk-core'

module AmazonSpClients
  module Middlewares
    class RequestSignerV4 < Faraday::Middleware
      CRYPTO_HEADER = 'x-amz-content-sha256'
      SESSION_HEADER = 'x-amz-security-token'

      # extend Forwardable
      # def_delegators :'Faraday::Utils', :parse_query

      # attr_reader :app, :options

      def initialize(app, options = {})
        super(app)
        @app = app
        @options = options
        # @session = options.delete(:session)

        # if options.has_key?(:session)
        #   @session = options.delete(:session)
        # end
      end

      def call(env)

        # TODO: remove me ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        require 'pry-byebug'
        binding.pry
        # TODO: remove me ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        # https://www.rubydoc.info/gems/aws-sigv4/1.0.0/Aws/Sigv4/Signer#sign_request-instance_method
        # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/AssumeRoleCredentials.html
        signer = Aws::Sigv4::Signer.new(
          service: 'execute-api',
          region: @options[:region],
          credentials_provider: @options[:session].role_credentials,
          # access_key_id: @config.access_key,
          # secret_access_key: @config.secret_key
        )
        signature = signer.sign_request(
          http_method: env.method.to_s.upcase!,
          url: env.url,
          headers: env.request_headers,
          body: env.request_body
        )

        # Add signature headers
        signature_headers = signature.headers
        env.request_headers.merge!({
          'authorization' => signature_headers['authorization'],
          'host' => signature_headers['host'],
          CRYPTO_HEADER => signature_headers[CRYPTO_HEADER],
          'x-amz-date' => signature_headers['x-amz-date'],
          SESSION_HEADER => signature_headers[SESSION_HEADER],
        })

        @app.call env
      end
    end
  end
end
