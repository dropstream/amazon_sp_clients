# frozen_string_literal: true

require 'faraday'

module AmazonSpClients
  module Middlewares
    # This exists only to allow extensions used by some services
    class DefaultMiddleware < Faraday::Middleware
      VALID_SERVICE = %i[sts token spapi uploads].freeze

      def initialize(app, options = {})
        super(app)
        @app = app
        @options = options
        @service = options.fetch(:service)
        raise unless VALID_SERVICE.include?(@service)

        @last_error = options[:last_error]
      end

      def call(request_env)
        @app
          .call(request_env)
          .on_complete do |response_env|
            # implement
          end
      end
    end
  end
end
