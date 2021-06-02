require 'spec_helper'
require 'pry-byebug'

RSpec.describe AmazonSpClients::AmznV4Signer do
  subject(:signer) do
    AmazonSpClients::AmznV4Signer.new do |s|
      s.region = 'us-east-1'
      s.access_key = access_key
      s.secret_key = secret_key
      s.time = time # TODO: take time from z-amz-date header!!!
      s.service_name = service_name

      s.request = {
        headers: request_headers,
        path: '/',
        http_method: http_method,
        query: query,
        payload: payload
      }
    end
  end

  let(:string_to_sign) { <<~STR.strip }
      AWS4-HMAC-SHA256
      20150830T123600Z
      20150830/us-east-1/iam/aws4_request
      f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59
  STR

  let(:request_headers) do
    {
      'Host': 'iam.amazonaws.com',
      'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
      'X-Amz-Date': '20150830T123600Z'
    }
  end
  let(:http_method) { :get }
  let(:path) { '/' }
  let(:query) { { Version: '2010-05-08', Action: 'ListUsers' } }
  let(:payload) { nil }

  let(:time) { '20150830T123600Z' }

  let(:service_name) { 'iam' }

  let(:secret_key) { 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY' }

  let(:access_key) { 'AKIDEXAMPLE' }

  describe '#build_authorization_header' do
    it 'returns signing information for authorization header' do
      expected =
        'AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/iam/aws4_request, SignedHeaders=content-type;host;x-amz-date, Signature=5d672d79c15b13162d9279b0855cfba6789a8edb4c82c400e06b5924a6f2b5d7'
      res = signer.build_authorization_header
      expect(res).to eq(expected)
    end
  end

  describe '#create_canonical_request' do
    it 'returns hashed string' do
      res =
        signer.create_canonical_request(
          http_method,
          path,
          query,
          request_headers,
          payload,
          time
        )
      expect(res).to eq(
        'f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59'
      )
    end
  end

  describe '#string_to_sign' do
    it 'returns prepared string' do
      res =
        signer.string_to_sign(
          time,
          'f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59',
          service_name
        )
      expect(res).to eq(string_to_sign.strip)
    end
  end

  describe '#calculate_signature' do
    it 'returns string signature' do
      expected =
        '5d672d79c15b13162d9279b0855cfba6789a8edb4c82c400e06b5924a6f2b5d7'
      res =
        signer.calculate_signature(
          time,
          secret_key,
          string_to_sign,
          service_name
        )
      expect(res).to eq(expected)
    end
  end
end
