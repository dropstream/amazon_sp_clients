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
      signer = AmazonSpClients::AmznV4Signer.new(nil, @request)
      res = signer.hashed_canonical_request_for_api(
        :get, url, query, headers, nil, '20150830T123600Z'
      )
      expect(res).to eq(
        'f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59'
      )
    end
  end
end
