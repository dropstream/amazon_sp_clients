require 'faraday'

module AmazonSpClients
  module Middlewares
    class LastRequestResponse < Faraday::Middleware
      def initialize(app, options = {})
        super(app)
        @app = app
        @options = options
      end

      def call(_request_env)
        @app
          .call(_request_env)
          .on_complete do |response_env|

            response_env.freeze
            
            Thread.current[:amazon_sp_clients_last_response] = {
              method: response_env.method,
              url: response_env.url,
              request_body: response_env.request_body,
              request_headers: response_env.request_headers,
              status: response_env.status,
              response_body: response_env.response_body,
              response_headers: response_env.response_headers,
              api_call_opts: @options.call[:opts]
            }

            AmazonSpClients.run_callbacks
          end
      end
    end
  end
end
