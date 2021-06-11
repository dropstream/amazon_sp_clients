require 'faraday'

module AmazonSpClients
  module Middlewares
    class LastRequestResponse < Faraday::Middleware
      def call(_request_env)
        @app
          .call(_request_env)
          .on_complete do |response_env|

            response_env.freeze
            
            Thread.current[:amazon_sp_clients_last_request] = {
              method: response_env.method,
              url: response_env.url,
              body: response_env.request_body,
              request_headers: response_env.request_headers
            }

            Thread.current[:amazon_sp_clients_last_response] = {
              status: response_env.status,
              body: response_env.response_body,
              response_headers: response_env.response_headers
            }

            AmazonSpClients.run_callbacks
          end
      end
    end
  end
end
