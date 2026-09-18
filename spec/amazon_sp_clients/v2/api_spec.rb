require 'spec_helper'
require 'amazon_sp_clients/v2'

# The base class every generated API class inherits. Exercised through a
# hand-written subclass shaped like the generator's output.
RSpec.describe AmazonSpClients::V2::Api do
  v2 = AmazonSpClients::V2

  let(:base_url) { 'https://sellingpartnerapi-na.amazon.com' }
  let(:client) { v2::Client.new(v2::Config.new) { 'ACCESS' } }
  let(:things_api) do
    Class.new(described_class) do
      def list_things(ids, next_token: nil, details: nil, rdt: nil)
        query = { 'Ids' => csv(ids), 'NextToken' => next_token, 'details' => details }

        request(:get, '/things/v1/things', query: query, rdt: rdt)
      end

      def get_thing(thing_id, body, x_amzn_idempotency_token:, rdt: nil)
        headers = { 'x-amzn-idempotency-token' => x_amzn_idempotency_token }
        path = "/things/v1/things/#{encode(thing_id)}"

        request(:post, path, headers: headers, body: body, rdt: rdt)
      end
    end
  end
  let(:api) { things_api.new(client) }

  it 'sends only the query keys that have a value, joining arrays with commas' do
    stub = stub_request(:get, "#{base_url}/things/v1/things")
           .with(query: { 'Ids' => 'A,B', 'details' => 'false' })
           .to_return(status: 200, body: '{"payload":{"things":[]}}')

    response = api.list_things(%w[A B], details: false)

    expect(stub).to have_been_requested
    expect(response.payload).to eq(things: [])
  end

  it 'sends an empty value for an empty array, as v1 did' do
    stub = stub_request(:get, "#{base_url}/things/v1/things")
           .with(query: { 'Ids' => '' })
           .to_return(status: 200, body: '{}')

    api.list_things([])

    expect(stub).to have_been_requested
  end

  it 'percent-encodes path parameters and passes header params and the JSON body' do
    stub = stub_request(:post, "#{base_url}/things/v1/things/a%20b%2Fc")
           .with(body: '{"name":"x"}', headers: { 'x-amzn-idempotency-token' => 'IDEMP' })
           .to_return(status: 204, body: '')

    response = api.get_thing('a b/c', { name: 'x' }, x_amzn_idempotency_token: 'IDEMP')

    expect(stub).to have_been_requested
    expect(response).to be_a(AmazonSpClients::ApiResponse)
  end

  it 'passes rdt through to the client' do
    resources = [v2::RDT.resource('GET', '/things/v1/things')]
    tokens = stub_request(:post, "#{base_url}/tokens/2021-03-01/restrictedDataToken")
             .to_return(status: 200, body: '{"restrictedDataToken":"RDT","expiresIn":3600}')
    things = stub_request(:get, "#{base_url}/things/v1/things")
             .with(headers: { 'x-amz-access-token' => 'RDT' })
             .to_return(status: 200, body: '{}')

    api.list_things(nil, rdt: resources)

    expect(tokens).to have_been_requested
    expect(things).to have_been_requested
  end
end
