# frozen_string_literal: true

module AmazonSpClients
  module V2
    # Replaces a secret wherever V2 renders one: error payloads and
    # inspect output.
    FILTERED = '[FILTERED]'

    # Base class of every error V2 raises.
    #
    # Match on the class and on +code+, never on the message. Rescue
    # subclasses before their parents: ThrottledError, UnauthorizedError,
    # ForbiddenError and NotFoundError before ClientError; TimeoutError
    # before ConnectionError. The exception that caused a transport
    # error is available as +cause+.
    class Error < StandardError
      # @return [Integer, nil] HTTP status, when a response was received
      attr_reader :status
      # @return [String, nil] Amazon's request id (x-amzn-RequestId)
      attr_reader :request_id
      # @return [Hash, nil] method, url, path, headers and body of the
      #   request; secrets redacted
      attr_reader :request
      # @return [Hash, nil] status, headers and body of the response
      attr_reader :response

      # @param message [String, nil]
      def initialize(message = nil, status: nil, request_id: nil, request: nil, response: nil)
        super(message)
        @status = status
        @request_id = request_id
        @request = request
        @response = response
      end
    end

    # The request got no usable response: connection refused, DNS or
    # SSL failure, a dropped keep-alive socket, a malformed response, a
    # response without status.
    class ConnectionError < Error; end

    # The request timed out while connecting, reading or writing.
    class TimeoutError < ConnectionError; end

    # A 2xx response whose body is not valid JSON.
    class ParseError < Error; end

    # The LWA token endpoint rejected the request (4xx).
    class AuthError < Error
      # @return [String, nil] LWA error code, e.g. 'invalid_grant'
      attr_reader :code
      # @return [String, nil] LWA error description
      attr_reader :description

      # @param message [String, nil]
      # @param code [String, nil]
      # @param description [String, nil]
      def initialize(message = nil, code: nil, description: nil, **context)
        super(message, **context)
        @code = code
        @description = description
      end
    end

    # The refresh token is revoked or invalid (LWA +invalid_grant+).
    class InvalidGrantError < AuthError; end

    # The app credentials are wrong (LWA +invalid_client+).
    class InvalidClientError < AuthError; end

    # SP-API answered with a non-2xx status.
    class ResponseError < Error
      # @return [Array<AmazonSpClients::ApiError::Error>] parsed SP-API
      #   errors (code, message, details); empty when the body had none
      attr_reader :errors
      # @return [Float, nil] x-amzn-RateLimit-Limit header, when present
      attr_reader :rate_limit

      # @param message [String, nil]
      # @param errors [Array<AmazonSpClients::ApiError::Error>]
      # @param rate_limit [Float, nil]
      def initialize(message = nil, errors: [], rate_limit: nil, **context)
        super(message, **context)
        @errors = errors
        @rate_limit = rate_limit
      end

      # @return [String, nil] code of the first SP-API error
      def code = errors.first&.code
    end

    # 429: the request was throttled. Kept out of ClientError on
    # purpose, so a +rescue ClientError+ cannot swallow it.
    class ThrottledError < ResponseError; end

    # Any 4xx other than 429.
    class ClientError < ResponseError; end

    # 400.
    class BadRequestError < ClientError; end

    # 401.
    class UnauthorizedError < ClientError; end

    # 403.
    class ForbiddenError < ClientError; end

    # 404.
    class NotFoundError < ClientError; end

    # 5xx.
    class ServerError < ResponseError; end

    # A presigned S3 upload or download failed.
    class DocumentError < Error; end
  end
end
