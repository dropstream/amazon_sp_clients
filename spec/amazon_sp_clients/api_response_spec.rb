require 'spec_helper'

RSpec.describe AmazonSpClients::ApiResponse do
  subject(:api_response) { described_class }

  describe '.build_from_hash' do
    it 'accepts optional pagination key (this differs between different APIs)' do
      input = {
        pagination: {
          nextToken: 'seed'
        },
        payload: {
          BogusField: {
            MWSAuthToken: 'test'
          }
        }
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
      input = { errors: [{ code: 'InvalidInput', message: 'Invalid Input' }] }
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

  describe '#initialize' do
    it 'raises ArgumentError when attributes is not a hash' do
      expect { api_response.new('not a hash') }.to raise_error(
        ArgumentError,
        'The input argument (attributes) must be a hash in `ApiResponse` initialize method'
      )
    end

    it 'leaves errors nil on success' do
      response = api_response.new(payload: { feedId: 1 })
      expect(response.errors).to be_nil
    end

    it 'leaves pagination nil when absent' do
      response = api_response.new(payload: { feedId: 1 })
      expect(response.pagination).to be_nil
    end

    it 'sets both payload and errors when both are present' do
      input = {
        payload: { feedId: 1 },
        errors: [{ code: 'InvalidInput', message: 'Invalid Input' }]
      }

      response = api_response.new(input)

      expect(response.payload).to eq(feedId: 1)
      expect(response.errors).to be_a(AmazonSpClients::ApiError)
      expect(response.errors.errors.first.code).to eq 'InvalidInput'
    end

    it 'leaves payload nil on an error-only response' do
      input = { errors: [{ code: 'InvalidInput', message: 'Invalid Input' }] }
      response = api_response.new(input)

      expect(response.payload).to be_nil
      expect(response.errors).to be_a(AmazonSpClients::ApiError)
    end

    # The envelope keys are always symbols (deserialize symbolizes).
    # A string-keyed hash used to match the guard but read nothing,
    # silently turning the payload into nil.
    it 'keeps a string-keyed hash intact as the payload' do
      response = api_response.new('payload' => { 'feedId' => 1 })

      expect(response.payload).to eq('payload' => { 'feedId' => 1 })
    end

    it 'exposes attributes and response readers' do
      attrs = { payload: { feedId: 1 } }
      http_response = double('response')

      response = api_response.new(attrs, http_response)

      expect(response.attributes).to equal(attrs)
      expect(response.response).to equal(http_response)
    end
  end

  describe '#response_headers' do
    it 'returns the response headers' do
      headers = Faraday::Utils::Headers.new('Content-Type' => 'application/json')
      response = api_response.new({ payload: {} }, double('response', headers: headers))

      expect(response.response_headers).to equal(headers)
    end

    it 'is nil without a response' do
      response = api_response.new(payload: {})
      expect(response.response_headers).to be_nil
    end
  end

  describe '#reported_rate_limit' do
    it 'reads the rate limit header as a float, case-insensitive' do
      headers = Faraday::Utils::Headers.new('x-amzn-RateLimit-Limit' => '0.2')
      response = api_response.new({ payload: {} }, double('response', headers: headers))

      expect(response.reported_rate_limit).to eq 0.2
    end

    it 'is nil without a response' do
      response = api_response.new(payload: {})
      expect(response.reported_rate_limit).to be_nil
    end

    it 'is nil without the header' do
      headers = Faraday::Utils::Headers.new
      response = api_response.new({ payload: {} }, double('response', headers: headers))

      expect(response.reported_rate_limit).to be_nil
    end
  end
end

RSpec.describe AmazonSpClients::ApiError do
  describe '#errors' do
    it 'builds error structs from an errors hash' do
      input = {
        errors: [
          { code: 'InvalidInput', message: 'Invalid Input', details: 'Bad feedId' }
        ]
      }

      error = described_class.new(input)

      expect(error.errors.size).to eq 1
      expect(error.errors.first.code).to eq 'InvalidInput'
      expect(error.errors.first.message).to eq 'Invalid Input'
      expect(error.errors.first.details).to eq 'Bad feedId'
    end

    it 'is empty for non-array input' do
      error = described_class.new('boom')
      expect(error.errors).to eq []
    end

    it 'is empty for a hash without :errors key' do
      error = described_class.new(code: 'InvalidInput')
      expect(error.errors).to eq []
    end
  end

  describe '#full_messages' do
    it 'joins "code: message" pairs with a comma' do
      input = {
        errors: [
          { code: 'InvalidInput', message: 'Invalid Input' },
          { code: 'QuotaExceeded', message: 'Slow down' }
        ]
      }

      error = described_class.new(input)

      expect(error.full_messages).to eq 'InvalidInput: Invalid Input, QuotaExceeded: Slow down'
    end

    it 'appends details when present' do
      input = {
        errors: [{ code: 'InvalidInput', message: 'Invalid Input', details: 'Bad feedId' }]
      }

      error = described_class.new(input)

      expect(error.full_messages).to eq 'InvalidInput: Invalid Input - Bad feedId'
    end

    it 'is empty for non-array input' do
      error = described_class.new('boom')
      expect(error.full_messages).to eq ''
    end
  end
end
