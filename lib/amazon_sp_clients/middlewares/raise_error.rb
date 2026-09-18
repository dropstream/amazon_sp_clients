# frozen_string_literal: true

require 'faraday'
# Faraday::RetriableResponse (raised on 429) lives in the faraday-retry
# gem under Faraday 2; a no-op under Faraday 1, which loads it itself.
require 'faraday/retry'
require 'json'

# Based on https://github.com/lostisland/faraday/blob/main/lib/faraday/response/raise_error.rb
module AmazonSpClients
  module Middlewares
    # RaiseError is a Faraday middleware that raises exceptions on common HTTP
    # client or server error responses.
    # Subclasses Faraday::Middleware (not Faraday::Response::Middleware,
    # which Faraday 2 removed) so one class works on Faraday 1.10 and 2.x.
    class RaiseError < Faraday::Middleware
      # rubocop:disable Naming/ConstantName
      ClientErrorStatuses = (400...500)
      ServerErrorStatuses = (500...600)

      # rubocop:enable Naming/ConstantName

      VALID_SERVICE = %i[token spapi uploads].freeze

      # The error payload ends up in consumer logs; keep secrets out.
      FILTERED = '[FILTERED]'
      SENSITIVE_HEADERS = %w[authorization x-amz-access-token x-amz-security-token].freeze

      def initialize(app, options = {})
        super
        @service = options.fetch(:service)
        raise unless VALID_SERVICE.include?(@service)
      end

      def on_complete(env)
        case env[:status]
        when 400
          raise Faraday::BadRequestError.new(
            error_message(env),
            response_values(env)
          )
        when 401
          raise Faraday::UnauthorizedError.new(
            error_message(env),
            response_values(env)
          )
        when 403
          raise Faraday::ForbiddenError.new(
            error_message(env),
            response_values(env)
          )
        when 404
          raise Faraday::ResourceNotFound.new(
            error_message(env),
            response_values(env)
          )
        when 407
          # mimic the behavior that we get with proxy requests with HTTPS
          msg = '407 "Proxy Authentication Required"'
          raise Faraday::ProxyAuthError.new(msg, response_values(env))
        when 409
          raise Faraday::ConflictError.new(
            error_message(env),
            response_values(env)
          )
        when 422
          raise Faraday::UnprocessableEntityError.new(
            error_message(env),
            response_values(env)
          )
        when 429
          # This assumes you will handle throttling/retires yourself
          raise Faraday::RetriableResponse.new(
            error_message(env),
            response_values(env)
          )
        when ClientErrorStatuses
          raise Faraday::ClientError.new(
            error_message(env),
            response_values(env)
          )
        when ServerErrorStatuses
          raise Faraday::ServerError.new(
            error_message(env),
            response_values(env)
          )
        when nil
          raise Faraday::NilStatusError.new(
            error_message(env),
            response_values(env)
          )
        end
      end

      def error_message(env)
        body = env.body

        unless !body.nil? && !body.empty?
          return "the server responded with status #{env[:status]} (no body)"
        end

        case @service
        when :token
          body = ::JSON.parse(body) if body.is_a?(String)

          "Service 'token' ERR: error: #{body['error']} description: #{body['error_description']}"
        when :spapi
          body = ::JSON.parse(body, symbolize_names: true) if body.is_a?(String)

          err = AmazonSpClients::ApiError.new(body)

          "Service 'spapi' ERR: #{err.full_messages}"
        else
          "the server responded with status #{env[:status]}"
        end
      rescue StandardError => e
        "the server responded with status #{env[:status]} (#{e})"
      end

      def response_values(env)
        {
          service: @service,
          response: {
            status: env.status,
            headers: env.response_headers,
            body: env.body
          },
          request: {
            method: env.method,
            url_path: env.url.path,
            url: redacted_url(env),
            headers: redacted_request_headers(env.request_headers),
            body: redacted_request_body(env)
          }
        }
      end

      private

      # Returns a copy that keeps Faraday's case-insensitive lookup.
      def redacted_request_headers(headers)
        redacted = Faraday::Utils::Headers.new(headers || {})
        SENSITIVE_HEADERS.each do |name|
          redacted[name] = FILTERED unless redacted[name].nil?
        end
        redacted
      end

      # Presigned S3 urls (uploads service) carry their credential in
      # the query string.
      def redacted_url(env)
        return env.url unless @service == :uploads

        env.url.dup.tap { |url| url.query = nil }
      end

      # The LWA token request body carries client_secret and
      # refresh_token as form fields.
      def redacted_request_body(env)
        return FILTERED if @service == :token

        env.request_body
      end
    end
  end
end
