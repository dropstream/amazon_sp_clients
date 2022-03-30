require 'spec_helper'

RSpec.describe AmazonSpClients::ApiResponse do
  subject(:api_response) { described_class }

  describe '.build_from_hash' do
    it 'underscores first level of response hash' do
      input = { 'payload' => { BogusField: { MWSAuthToken: 'test' } } }
      expected = { BogusField: { MWSAuthToken: 'test' } }
      response = api_response.build_from_hash(input)
      expect(response.payload).to eq(expected)
    end

    it 'wraps errors attribute with ApiError' do
      input = {"errors": [{"code": "InvalidInput", "message": "Invalid Input"}]}
      response = api_response.build_from_hash(input)
      errors = response.errors
      expect(errors).to be_a(AmazonSpClients::ApiError)
      expect(errors.errors.first.code).to eq "InvalidInput"
    end

    it 'always wraps non-erro attributes with payload' do
      input = { feedId: 1, ResultDocumentId: 'test' }
      expected = { feed_id: 1, result_document_id: 'test' }
      response = api_response.build_from_hash(input)

      expect(response.payload).to eq(expected)
    end
  end
end
