require 'digest'
require 'erb'

module AmazonSpClients
  class AmznV4Signer
    ALGO = 'AWS4-HMAC-SHA256'.freeze

    def initialize(region)
      @region = region
    end

    def sign_role_credential_request(aws_user); end

    def sign_api_request(access_token, role_credentials); end

    # NOTE: this method already expects properly encoded query params! 
    # They can be unsorted.
    def canonical_request_for_api(method, uri, query, headers, payload, time)
      canonical_headers, headers_sig = headers_sig(headers)
      hashed_payload = Digest::SHA256.hexdigest(payload.to_s)
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

    def hashed_canonical_request_for_api(
      method,
      uri,
      query,
      headers,
      payload,
      time
    )
      Digest::SHA256.hexdigest(
        canonical_request_for_api(method, uri, query, headers, payload, time)
      )
    end

    def string_to_sign(time, canonical_request, action = 'execute-api')
      [
        ALGO,
        time,
        credential_scope(time, action),
        canonical_request,
        ""
      ].join("\n")
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

    def credential_scope(time, action = 'execute-api')
      "#{Date.parse(time).strftime('%Y%m%d')}/#{@region}/#{action}/aws4_request"
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
      arr.map! { |a| "#{a[0]}=#{a[1]}" }.join("&")
    end
  end
end
