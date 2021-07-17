# frozen_string_literal: true

require 'multi_xml'
require 'json'

# Based on https://github.com/lostisland/faraday/blob/main/lib/faraday/response/raise_error.rb
module AmazonSpClients
  module Middlewares
    # RaiseError is a Faraday middleware that raises exceptions on common HTTP
    # client or server error responses.
    class RaiseError < Faraday::Response::Middleware
      # rubocop:disable Naming/ConstantName
      ClientErrorStatuses = (400...500).freeze
      ServerErrorStatuses = (500...600).freeze

      # rubocop:enable Naming/ConstantName

      VALID_SERVICE = %i[sts token spapi uploads].freeze

      def initialize(app, options = {})
        super(app)
        @app = app
        @service = options.fetch(:service)
        raise unless VALID_SERVICE.include?(@service)
      end

      def on_complete(env)
        case env[:status]
        when 400
          raise Faraday::BadRequestError.new(
                  error_message(env),
                  response_values(env),
                )
        when 401
          raise Faraday::UnauthorizedError.new(
                  error_message(env),
                  response_values(env),
                )
        when 403
          raise Faraday::ForbiddenError.new(
                  error_message(env),
                  response_values(env),
                )
        when 404
          raise Faraday::ResourceNotFound.new(
                  error_message(env),
                  response_values(env),
                )
        when 407
          # mimic the behavior that we get with proxy requests with HTTPS
          msg = '407 "Proxy Authentication Required"'
          raise Faraday::ProxyAuthError.new(msg, response_values(env))
        when 409
          raise Faraday::ConflictError.new(
                  error_message(env),
                  response_values(env),
                )
        when 422
          raise Faraday::UnprocessableEntityError.new(
                  error_message(env),
                  response_values(env),
                )
        when 429
          # This assumes you will handle throttling/retires yourself
          raise Faraday::RetriableResponse.new(
                  error_message(env),
                  response_values(env),
                )
        when ClientErrorStatuses
          raise Faraday::ClientError.new(
                  error_message(env),
                  response_values(env),
                )
        when ServerErrorStatuses
          raise Faraday::ServerError.new(
                  error_message(env),
                  response_values(env),
                )
        when nil
          raise Faraday::NilStatusError.new(
                  error_message(env),
                  response_values(env),
                )
        end
      end

      def error_message(env)
        body = env.body

        unless !body.nil? && !body.empty?
          return "the server responded with status #{env[:status]} (no body)"
        end

        case @service
        when :sts
          if body.kind_of?(String)
            body = ::MultiXml.parse(body)
            env.body = body # replace xml body with parsed Hash
          end
          err = body['ErrorResponse']['Error']

          "Service 'sts' ERR: type: #{err['Type']} code: #{err['Code']} message: #{err['Message']}"
        when :token
          body = ::JSON.parse(body) if body.kind_of?(String)

          "Service 'token' ERR: error: #{body['error']} description: #{body['error_description']}"
        when :spapi
          body = ::JSON.parse(body, symbolize_names: true) if body.kind_of?(String)

          err = AmazonSpClients::ApiError.new(body)

          "Service 'spapi' ERR: #{err.full_messages}"
        else
          "the server responded with status #{env[:status]}"
        end
      rescue => e
        "the server responded with status #{env[:status]} (#{e})"
      end

      def response_values(env)
        {
          service: @service,
          response: {
            status: env.status,
            headers: env.response_headers,
            body: env.body,
          },
          request: {
            method: env.method,
            url_path: env.url.path,
            url: env.url,
            params: env.params,
            headers: env.request_headers,
            body: env.request_body,
          },
        }
      end
    end
  end
end
