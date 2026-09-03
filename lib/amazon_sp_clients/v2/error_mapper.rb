# frozen_string_literal: true

require 'json'
require 'uri'
require 'faraday'
require 'httpclient'
require 'amazon_sp_clients/api_error'
require 'amazon_sp_clients/v2/errors'

module AmazonSpClients
  module V2
    # Turns a Faraday response or a transport exception into the V2
    # error for it. One mapper per service, because the three services
    # V2 talks to fail in different shapes:
    #
    #   :api        SP-API; body {"errors": [{code, message, details}]}
    #   :lwa        token endpoint; body {"error", "error_description"}
    #   :documents  presigned S3 urls; the url carries the credential
    class ErrorMapper
      # The three services V2 talks to.
      SERVICES = %i[api lwa documents].freeze

      # Exceptions the HTTPClient adapter lets out of a request: Faraday's
      # own, plus the ones it re-raises untouched. Nothing else is
      # wrapped, so an exception delivered by Thread#raise passes through.
      TRANSPORT_ERRORS = [
        Faraday::Error, HTTPClient::KeepAliveDisconnected, SystemCallError, IOError, SocketError
      ].freeze

      # Too Many Requests; also what LWA answers when the token endpoint
      # is called too often.
      THROTTLED_STATUS = 429
      # SP-API statuses with their own error class; other 4xx and 5xx
      # fall to ClientError and ServerError.
      STATUS_ERRORS = {
        400 => BadRequestError,
        401 => UnauthorizedError,
        403 => ForbiddenError,
        404 => NotFoundError,
        THROTTLED_STATUS => ThrottledError
      }.freeze
      # Statuses mapped to ClientError when not in STATUS_ERRORS.
      CLIENT_ERROR_STATUSES = (400...500)
      # Statuses mapped to ServerError.
      SERVER_ERROR_STATUSES = (500...600)

      # LWA error codes with their own class; other codes raise AuthError.
      LWA_ERRORS = {
        'invalid_grant' => InvalidGrantError,
        'invalid_client' => InvalidClientError
      }.freeze

      # Response header carrying Amazon's request id.
      REQUEST_ID_HEADER = 'x-amzn-RequestId'
      # Response header carrying the usage plan rate, in requests per second.
      RATE_LIMIT_HEADER = 'x-amzn-RateLimit-Limit'

      # The error ends up in consumer logs; keep secrets out of it.
      FILTERED = V2::FILTERED
      # Request headers replaced by FILTERED on the error.
      SENSITIVE_HEADERS = %w[authorization x-amz-access-token x-amz-security-token].freeze

      # @param service [Symbol] one of SERVICES
      # @raise [ArgumentError] on an unknown service
      def initialize(service)
        raise ArgumentError, "unknown service #{service.inspect}" unless SERVICES.include?(service)

        @service = service
      end

      # @param response [Faraday::Response]
      # @return [Faraday::Response] the same response, when it is a 2xx
      # @raise [Error] the mapped error otherwise
      def check!(response)
        env = response.env
        raise ConnectionError.new('no status in response', **context(env)) if env.status.nil?
        return response if response.success?

        raise error_for(env)
      end

      # A 2xx response whose body could not be used, with the same
      # redacted context every other error carries.
      #
      # @param message [String]
      # @param response [Faraday::Response]
      # @return [ParseError]
      def parse_error(message, response)
        ParseError.new(message, **context(response.env))
      end

      # Wraps an exception raised by the transport. Call it inside the
      # rescue, so Ruby records the original exception as +cause+.
      #
      # @param exception [Exception]
      # @param method [Symbol] HTTP method of the failed request
      # @param url [String] full url of the failed request
      # @return [ConnectionError]
      def transport_error(exception, method:, url:)
        klass = exception.is_a?(Faraday::TimeoutError) ? TimeoutError : ConnectionError

        klass.new("#{exception.class}: #{exception.message}",
                  request: { method: method, url: redacted_url(url), path: URI(url).path })
      end

      private

      def error_for(env)
        case @service
        when :api then api_error(env)
        when :lwa then lwa_error(env)
        else document_error(env)
        end
      end

      def api_error(env)
        parsed = parse_json(env.body)
        errors = api_errors(parsed)
        messages = parsed && errors.map { |e| describe(e) }
        klass = STATUS_ERRORS.fetch(env.status) { generic_class(env.status) }

        klass.new("#{env.status} #{summary(env.body, messages)}",
                  errors: errors, rate_limit: rate_limit(env), **context(env))
      end

      # The documented shape is {errors: [{code, message, details}]}; this
      # is the last line of defence, so anything else yields no errors
      # rather than an exception.
      def api_errors(parsed)
        list = parsed.is_a?(Hash) ? parsed[:errors] : parsed
        return [] unless list.is_a?(Array)

        ApiError.new(list.grep(Hash)).errors
      end

      def lwa_error(env)
        return lwa_server_error(env) if SERVER_ERROR_STATUSES.cover?(env.status)

        parsed = parse_json(env.body)
        parsed = nil unless parsed.is_a?(Hash)
        code = parsed&.fetch(:error, nil)
        description = parsed&.fetch(:error_description, nil)
        messages = parsed && [[code, description].compact.join(': ')].reject(&:empty?)
        message = "#{env.status} #{summary(env.body, messages)}"
        return ThrottledError.new(message, **context(env)) if env.status == THROTTLED_STATUS

        LWA_ERRORS.fetch(code, AuthError)
                  .new(message, code: code, description: description, **context(env))
      end

      def lwa_server_error(env)
        ServerError.new("#{env.status} #{summary(env.body, [])}", **context(env))
      end

      def document_error(env)
        DocumentError.new("#{env.status} #{env.reason_phrase}".strip, **context(env))
      end

      # Status text: the parsed error messages, or why there are none.
      # +messages+ is nil when the body was not JSON.
      def summary(body, messages)
        return '(no body)' if body.nil? || body.empty?
        return '(body is not JSON)' if messages.nil?
        return '(no error details)' if messages.empty?

        messages.join('; ')
      end

      def describe(error)
        text = "#{error.code}: #{error.message}"
        return text if error.details.to_s.empty?

        "#{text} (#{error.details})"
      end

      def generic_class(status)
        return ClientError if CLIENT_ERROR_STATUSES.cover?(status)
        return ServerError if SERVER_ERROR_STATUSES.cover?(status)

        ResponseError
      end

      def parse_json(body)
        return nil if body.nil? || body.empty?

        JSON.parse(body, symbolize_names: true)
      rescue JSON::ParserError
        nil
      end

      def context(env)
        {
          status: env.status,
          request_id: env.response_headers&.[](REQUEST_ID_HEADER),
          request: request_details(env),
          response: { status: env.status, headers: env.response_headers, body: env.body }
        }
      end

      def request_details(env)
        {
          method: env.method,
          url: redacted_url(env.url.to_s),
          path: env.url.path,
          headers: redacted_headers(env.request_headers),
          body: @service == :lwa ? FILTERED : env.request_body
        }
      end

      # A copy that keeps Faraday's case-insensitive lookup.
      def redacted_headers(headers)
        redacted = Faraday::Utils::Headers.new(headers || {})
        SENSITIVE_HEADERS.each do |name|
          redacted[name] = FILTERED unless redacted[name].nil?
        end
        redacted
      end

      # Presigned S3 urls carry their credential in the query string.
      def redacted_url(url)
        return url unless @service == :documents

        URI(url).tap { |uri| uri.query = nil }.to_s
      end

      def rate_limit(env)
        env.response_headers&.[](RATE_LIMIT_HEADER)&.to_f
      end
    end
  end
end
