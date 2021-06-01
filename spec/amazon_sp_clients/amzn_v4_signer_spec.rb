require 'spec_helper'

RSpec.describe AmazonSpClients::AmznV4Signer do
  describe '#hashed_canonical_request_for_api' do
    it 'returns hashed string' do
      headers = {
        'Host': 'iam.amazonaws.com',
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
        'X-Amz-Date': '20150830T123600Z'
      }
      url = '/'
      query = { Version: '2010-05-08', Action: 'ListUsers' }
      signer = AmazonSpClients::AmznV4Signer.new('us-east-1')
      res =
        signer.hashed_canonical_request_for_api(
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
      expected = <<-STR
AWS4-HMAC-SHA256
20150830T123600Z
20150830/us-east-1/iam/aws4_request
f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59
STR
      signer = AmazonSpClients::AmznV4Signer.new('us-east-1')
      res =
        signer.string_to_sign(
          '20150830T123600Z',
          'f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59',
          'iam'
        )
      expect(res).to eq(expected)
    end
  end
end
