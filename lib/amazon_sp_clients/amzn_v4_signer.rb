# frozen_string_literal: true

require 'openssl'
require 'erb'

# https://docs.aws.amazon.com/general/latest/gr/sigv4_signing.html
module AmazonSpClients
  class AmznV4Signer
    ALGO = 'AWS4-HMAC-SHA256'.freeze
    SHA256 = OpenSSL::Digest::SHA256.new

    attr_accessor :region,
                  :access_key,
                  :secret_key,
                  :time,
                  :request,
                  :signed_headers,
                  :service_name

    def initialize
      yield self
    end

    def build_authorization_header
      @service_name ||= 'execute-api'
      cannonical_request = create_canonical_request_from_hash(@request)
      credential_scope = scope(@time, @service_name)
      str = string_to_sign(@time, cannonical_request, @service_name)
      signature = calculate_signature(@time, @secret_key, str, @service_name)

      authorization_header(
        @access_key,
        credential_scope,
        @signed_headers,
        signature
      )
    end

    # step 1.
    def create_canonical_request(method, path, query, headers, payload, time)
      SHA256.hexdigest(
        _create_canonical_request(method, path, query, headers, payload, time)
      )
    end

    # step 2.
    def string_to_sign(time, canonical_request, service_name = 'execute-api')
      [ALGO, time, scope(time, service_name), canonical_request].join("\n")
    end

    # step 3.
    def calculate_signature(
      time,
      secret_key,
      string_to_sign,
      service_name = 'execute-api'
    )
      key = signing_key(time, secret_key, service_name)
      OpenSSL::HMAC.hexdigest('sha256', key, string_to_sign)
    end

    # step 4.
    def authorization_header(
      access_key,
      credential_scope,
      signed_headers,
      signature
    )
      "#{ALGO} Credential=#{access_key}/#{
        credential_scope
      }, SignedHeaders=#{signed_headers}, Signature=#{signature}"
    end

    private

    def signing_key(time, secret_key, service_name = 'execute-api')
      [
        "AWS4#{secret_key}",
        short_date(time),
        @region,
        service_name,
        'aws4_request'
      ].inject { |memo, arg| OpenSSL::HMAC.digest('sha256', memo, arg) }
    end

    # NOTE: this method already expects properly encoded query params!
    # They can be unsorted.
    def _create_canonical_request(method, path, query, headers, payload, time)
      canonical_headers, headers_sig = headers_sig(headers)
      hashed_payload = SHA256.hexdigest(payload.to_s)
      canonical_qeury = to_canonical_query(query)

      # Side effect: Set headers signature that is required in last step
      self.signed_headers = headers_sig

      [
        method.to_s.upcase,
        path,
        canonical_qeury,
        canonical_headers,
        headers_sig,
        hashed_payload
      ].join("\n")
    end

    def scope(time, service_name = 'execute-api')
      "#{short_date(time)}/#{@region}/#{service_name}/aws4_request"
    end

    def short_date(time)
      @short_date ||= Date.parse(time).strftime('%Y%m%d')
    end

    def headers_sig(headers)
      headers = headers.to_a
      headers.map! do |arr|
        [arr[0].to_s.downcase, arr[1].to_s.strip.gsub(/\s+/, ' ')]
      end
      headers.sort_by! { |arr| [arr[0], arr[1]] }

      # Side effect: Read the time from x-amz-date if needed
      self.time ||= headers.find { |arr| arr[0] == 'x-amz-date' }&.last

      canonical = headers.map { |arr| "#{arr[0]}:#{arr[1]}" }.join("\n")
      sig = headers.map { |arr| arr[0] }.join(';')

      return "#{canonical}\n", sig
    end

    def to_canonical_query(hash)
      arr = hash.to_a
      arr.sort_by! { |a| [a[0], a[1]] }
      arr.map! { |a| "#{a[0]}=#{a[1]}" }.join('&')
    end

    def create_canonical_request_from_hash(**args)
      create_canonical_request(
        args[:http_method],
        args[:path],
        args[:query],
        args[:headers],
        args[:payload],
        args[:time]
      )
    end
  end
end
