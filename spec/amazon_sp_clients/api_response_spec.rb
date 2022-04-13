require 'spec_helper'

RSpec.describe AmazonSpClients::ApiResponse do
  subject(:api_response) { described_class }

  describe '.build_from_hash' do
    it 'accepts optional pagination key (this differs between different APIs)' do
      input = {
        pagination: {
          nextToken: 'seed',
        },
        payload: {
          BogusField: {
            MWSAuthToken: 'test',
          },
        },
      }

      response = api_response.build_from_hash(input)
      expect(response.pagination[:nextToken]).to eq 'seed'
    end

    it 'set payload attr at success response body' do
      input = { payload: { BogusField: { MWSAuthToken: 'test' } } }
      expected = { BogusField: { MWSAuthToken: 'test' } }
      response = api_response.build_from_hash(input)
      expect(response.payload).to eq(expected)
    end

    it 'wraps single error with ApiError' do
      input = { 'errors': [{ 'code': 'InvalidInput', 'message': 'Invalid Input' }] }
      response = api_response.build_from_hash(input)
      errors = response.errors
      expect(errors).to be_a(AmazonSpClients::ApiError)
      expect(errors.errors.first.code).to eq 'InvalidInput'
    end

    it 'always sets payload attr on no errors' do
      input = { feedId: 1, ResultDocumentId: 'test' }
      expected = { feedId: 1, ResultDocumentId: 'test' }
      response = api_response.build_from_hash(input)

      expect(response.payload).to eq(expected)
    end
  end
end
