require 'spec_helper'

RSpec.describe AmazonSpClients::AmznV4Signer do
  let(:signer) do
    AmazonSpClients::AmznV4Signer.new('us-east-1')
  end

  let(:string_to_sign) { <<~STR.strip }
      AWS4-HMAC-SHA256
      20150830T123600Z
      20150830/us-east-1/iam/aws4_request
      f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59
    STR

  describe '#create_canonical_request' do
    it 'returns hashed string' do
      headers = {
        'Host': 'iam.amazonaws.com',
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
        'X-Amz-Date': '20150830T123600Z'
      }
      url = '/'
      query = { Version: '2010-05-08', Action: 'ListUsers' }
      res =
        signer.create_canonical_request(
          :get,
          url,
          query,
          headers,
          nil,
          '20150830T123600Z'
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
          '20150830T123600Z',
          'f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59',
          'iam'
        )
      expect(res).to eq(string_to_sign.strip)
    end
  end

  describe '#calculate_signature' do
    it 'returns string signature' do
      expected =
        '5d672d79c15b13162d9279b0855cfba6789a8edb4c82c400e06b5924a6f2b5d7'
      access_key = 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY'
      res =
        signer.calculate_signature(
          '20150830T123600Z',
          access_key,
          string_to_sign,
          'iam'
        )
      expect(res).to eq(expected)
    end
  end
end
