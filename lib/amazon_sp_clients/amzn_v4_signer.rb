# frozen_string_literal: true

require 'openssl'
require 'erb'

module AmazonSpClients
  class AmznV4Signer
    ALGO = 'AWS4-HMAC-SHA256'.freeze
    SHA256 = OpenSSL::Digest::SHA256.new

    def initialize(region)
      @region = region
    end

    def create_canonical_request(method, uri, query, headers, payload, time)
      Digest::SHA256.hexdigest(
        _create_canonical_request(method, uri, query, headers, payload, time)
      )
    end

    def string_to_sign(time, canonical_request, service_name = 'execute-api')
      [ALGO, time, scope(time, service_name), canonical_request].join("\n")
    end

    def calculate_signature(
      time,
      access_key,
      string_to_sign,
      service_name = 'execute-api'
    )
      key = signing_key(time, access_key, service_name)
        # key.unpack("H*")
      OpenSSL::HMAC.hexdigest('sha256', key, string_to_sign)
    end

    # def headers
    #   {
    #     'Authorization' => authorization_header,
    #     'Host' => api_endpoint,
    #     'x-amz-access-token' => access_token,
    #     'x-amz-security-token' => role_credentials.security_token,
    #     'x-amz-date' => iso_date
    #   }
    # end

    # def authorization_header
    #   "AWS4-HMAC-SHA256 Credential=#{role_credentials.id}/#{short_date}/#{
    #     region
    #   }/execute-api/aws4_request, SignedHeaders=host;x-amz-access-token;x-amz-date, Signature=#{
    #     signature
    #   }"
    # end

    # TODO, take date/time from req??
    # def iso_date
    #   # TODO: find better location for this method
    #   # Time.current.utc.iso8601
    #   '20150830T123600Z'
    # end

    private

    def signing_key(time, access_key, service_name = 'execute-api')
      [
        "AWS4#{access_key}",
        short_date(time),
        @region,
        service_name,
        'aws4_request'
      ].inject { |memo, arg| OpenSSL::HMAC.digest('sha256', memo, arg) }
    end

    # NOTE: this method already expects properly encoded query params!
    # They can be unsorted.
    def _create_canonical_request(method, uri, query, headers, payload, time)
      canonical_headers, headers_sig = headers_sig(headers)
      hashed_payload = SHA256.hexdigest(payload.to_s)
      canonical_qeury = to_canonical_query(query)

      [
        method.to_s.upcase,
        uri,
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

      canonical = headers.map { |arr| "#{arr[0]}:#{arr[1]}" }.join("\n")
      sig = headers.map { |arr| arr[0] }.join(';')

      return "#{canonical}\n", sig
    end

    def to_canonical_query(hash)
      arr = hash.to_a
      arr.sort_by! { |a| [a[0], a[1]] }
      arr.map! { |a| "#{a[0]}=#{a[1]}" }.join('&')
    end
  end
end
