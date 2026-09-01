require 'spec_helper'

# Fake session for ApiClient specs. Records calls.
class FakeSpSession
  attr_reader :events, :rdt_resources

  def initialize
    @events = []
    @rdt_resources = []
  end

  def refresh
    @events << :refresh
  end

  def access_token
    'ACCESS_TOKEN'
  end

  def ask_for_restricted_data_token(resource)
    @events << :ask_rdt
    @rdt_resources << resource
  end

  def restricted_data_token
    @rdt_resources.to_h { |r| [r, 'RDT_TOKEN'] }
  end
end

# Bare response stand-in for the pure helper methods.
FakeSpResponse = Struct.new(:body, :headers)

RSpec.describe AmazonSpClients::ApiClient do
  let(:session) { FakeSpSession.new }
  let(:config) { AmazonSpClients::Configuration.new { |c| c.sandbox_env! } }
  let(:client) { described_class.new(session, config) }
  let(:base_url) { 'https://sandbox.sellingpartnerapi-na.amazon.com' }

  describe '#call_api' do
    it 'puts query params in the GET url' do
      stub =
        stub_request(:get, "#{base_url}/orders/v0/orders")
        .with(query: { 'CreatedAfter' => '2021-01-01', 'MarketplaceIds' => 'ATVPDKIKX0DER' })
        .to_return(status: 200, body: '{}')

      client.call_api(
        :GET,
        '/orders/v0/orders',
        query_params: { 'CreatedAfter' => '2021-01-01', 'MarketplaceIds' => 'ATVPDKIKX0DER' }
      )

      expect(stub).to have_been_requested
    end

    it 'sends content type, user agent, access token and amz date headers' do
      Timecop.freeze(Time.utc(2021, 6, 9, 9, 16, 55))

      stub =
        stub_request(:get, "#{base_url}/test")
        .with(
          headers: {
            'Content-Type' => 'application/json',
            'User-Agent' => "Dropstream/1.0 (Language=Ruby/#{RUBY_VERSION})",
            'x-amz-access-token' => 'ACCESS_TOKEN',
            'x-amz-date' => '20210609T091655Z'
          }
        )
        .to_return(status: 200, body: '{}')

      client.call_api(:GET, '/test')

      expect(stub).to have_been_requested
    end

    it 'refreshes the session before the request' do
      stub_request(:get, "#{base_url}/test").to_return do |_req|
        session.events << :http_request
        { status: 200, body: '{}' }
      end

      client.call_api(:GET, '/test')

      expect(session.events).to eq(%i[refresh http_request])
    end

    context 'with auth_names (restricted operation)' do
      it 'asks for a restricted data token and sends it instead' do
        stub =
          stub_request(:get, "#{base_url}/orders/v0/orders/123/address")
          .with(headers: { 'x-amz-access-token' => 'RDT_TOKEN' })
          .to_return(status: 200, body: '{}')

        client.call_api(:GET, '/orders/v0/orders/123/address', auth_names: ['/orders/v0/orders'])

        expect(stub).to have_been_requested
        expect(session.rdt_resources).to eq(['/orders/v0/orders'])
        expect(session.events).not_to include(:refresh)
      end
    end

    it 'sends a hash body as json on POST' do
      stub =
        stub_request(:post, "#{base_url}/feeds/2021-06-30/documents")
        .with(body: '{"contentType":"text/xml"}')
        .to_return(status: 200, body: '{}')

      client.call_api(:POST, '/feeds/2021-06-30/documents', body: { contentType: 'text/xml' })

      expect(stub).to have_been_requested
    end

    it 'sends a string body unchanged on POST' do
      stub =
        stub_request(:post, "#{base_url}/feeds/2021-06-30/documents")
        .with(body: 'already-serialized')
        .to_return(status: 200, body: '{}')

      client.call_api(:POST, '/feeds/2021-06-30/documents', body: 'already-serialized')

      expect(stub).to have_been_requested
    end

    it 'returns nil without a return_type' do
      stub = stub_request(:get, "#{base_url}/test").to_return(status: 200, body: '{}')

      expect(client.call_api(:GET, '/test')).to be_nil
      expect(stub).to have_been_requested
    end

    it 'raises when the session is nil' do
      client = described_class.new(nil, config)

      expect { client.call_api(:GET, '/test') }.to raise_error(
        RuntimeError,
        'Ensure session is valid before calling API methods'
      )
    end

    it 'returns an ApiResponse with symbol keys for the default return_type' do
      stub_request(:get, "#{base_url}/test").to_return(
        status: 200,
        body: '{"payload":{"AmazonOrderId":"902-1"}}'
      )

      result = client.call_api(:GET, '/test', return_type: 'AmazonSpClients::ApiResponse')

      expect(result).to be_instance_of(AmazonSpClients::ApiResponse)
      expect(result.payload).to eq(AmazonOrderId: '902-1')
    end

    it 'returns a plain hash with symbol keys for return_type Object' do
      stub_request(:get, "#{base_url}/test").to_return(status: 200, body: '{"payload":{"x":1}}')

      result = client.call_api(:GET, '/test', return_type: 'Object')

      expect(result).to eq(payload: { x: 1 })
    end
  end

  describe '#deserialize' do
    it 'wraps a json body in an ApiResponse for the default return_type' do
      response = FakeSpResponse.new('{"payload":{"AmazonOrderId":"902-1"}}', {})

      result = client.deserialize(response, 'AmazonSpClients::ApiResponse')

      expect(result).to be_instance_of(AmazonSpClients::ApiResponse)
      expect(result.payload).to eq(AmazonOrderId: '902-1')
    end

    it 'returns the parsed value for return_type String' do
      response = FakeSpResponse.new('"hello"', {})

      expect(client.deserialize(response, 'String')).to eq('hello')
    end

    it 'returns nil for a nil body' do
      response = FakeSpResponse.new(nil, {})

      expect(client.deserialize(response, 'AmazonSpClients::ApiResponse')).to be_nil
    end

    it 'returns nil for an empty json object body' do
      response = FakeSpResponse.new('{}', {})

      expect(client.deserialize(response, 'AmazonSpClients::ApiResponse')).to be_nil
    end

    it 'raises for an empty string body' do
      response = FakeSpResponse.new('', {})

      expect { client.deserialize(response, 'AmazonSpClients::ApiResponse') }.to raise_error(
        JSON::ParserError
      )
    end

    it 'raises for a non-json content type' do
      response = FakeSpResponse.new('{"a":1}', { 'Content-Type' => 'application/xml' })

      expect { client.deserialize(response, 'AmazonSpClients::ApiResponse') }.to raise_error(
        RuntimeError,
        'Content-Type is not supported: application/xml'
      )
    end
  end

  describe '#convert_to_type' do
    it 'returns nil for nil data' do
      expect(client.convert_to_type(nil, 'String', nil)).to be_nil
    end

    it 'converts to String' do
      expect(client.convert_to_type(123, 'String', nil)).to eq('123')
    end

    it 'converts to Integer' do
      expect(client.convert_to_type('42', 'Integer', nil)).to eq(42)
    end

    it 'converts to Float' do
      expect(client.convert_to_type('3.5', 'Float', nil)).to eq(3.5)
    end

    it 'converts to Boolean' do
      expect(client.convert_to_type(true, 'Boolean', nil)).to be(true)
      expect(client.convert_to_type(false, 'Boolean', nil)).to be(false)
    end

    it 'parses DateTime' do
      result = client.convert_to_type('2021-06-09T09:16:55Z', 'DateTime', nil)

      expect(result).to eq(DateTime.new(2021, 6, 9, 9, 16, 55))
    end

    it 'parses Date' do
      expect(client.convert_to_type('2021-06-09', 'Date', nil)).to eq(Date.new(2021, 6, 9))
    end

    it 'returns Object data as is' do
      data = { a: 1 }

      expect(client.convert_to_type(data, 'Object', nil)).to be(data)
    end

    it 'converts each item of an Array type' do
      expect(client.convert_to_type(%w[1 2], 'Array<Integer>', nil)).to eq([1, 2])
    end

    it 'converts each value of Hash<String, Integer>' do
      data = { 'a' => '1', 'b' => '2' }

      result = client.convert_to_type(data, 'Hash<String, Integer>', nil)

      expect(result).to eq('a' => 1, 'b' => 2)
    end
  end

  describe '#json_mime?' do
    it 'accepts json mime types and */*' do
      expect(client.json_mime?('application/json')).to be(true)
      expect(client.json_mime?('application/json; charset=UTF8')).to be(true)
      expect(client.json_mime?('APPLICATION/JSON')).to be(true)
      expect(client.json_mime?('*/*')).to be(true)
    end

    it 'rejects other mime types' do
      expect(client.json_mime?('application/xml')).to be(false)
      expect(client.json_mime?('text/plain')).to be(false)
    end
  end

  describe '#select_header_accept' do
    it 'returns nil for nil or empty list' do
      expect(client.select_header_accept(nil)).to be_nil
      expect(client.select_header_accept([])).to be_nil
    end

    it 'prefers the json type' do
      accepts = ['application/xml', 'application/json; charset=UTF8']

      expect(client.select_header_accept(accepts)).to eq('application/json; charset=UTF8')
    end

    it 'joins all types when none is json' do
      expect(client.select_header_accept(['application/xml', 'text/plain'])).to eq(
        'application/xml,text/plain'
      )
    end
  end

  describe '#select_header_content_type' do
    it 'defaults to application/json for nil or empty list' do
      expect(client.select_header_content_type(nil)).to eq('application/json')
      expect(client.select_header_content_type([])).to eq('application/json')
    end

    it 'prefers the json type' do
      types = ['application/xml', 'application/json']

      expect(client.select_header_content_type(types)).to eq('application/json')
    end

    it 'falls back to the first type when none is json' do
      expect(client.select_header_content_type(['application/xml', 'text/plain'])).to eq(
        'application/xml'
      )
    end
  end

  describe '#build_collection_param' do
    let(:param) { %w[a b c] }

    it 'joins with comma for :csv' do
      expect(client.build_collection_param(param, :csv)).to eq('a,b,c')
    end

    it 'joins with space for :ssv' do
      expect(client.build_collection_param(param, :ssv)).to eq('a b c')
    end

    it 'joins with tab for :tsv' do
      expect(client.build_collection_param(param, :tsv)).to eq("a\tb\tc")
    end

    it 'joins with pipe for :pipes' do
      expect(client.build_collection_param(param, :pipes)).to eq('a|b|c')
    end

    it 'returns the array itself for :multi' do
      expect(client.build_collection_param(param, :multi)).to be(param)
    end

    it 'raises for an unknown format' do
      expect { client.build_collection_param(param, :bogus) }.to raise_error(
        RuntimeError,
        'unknown collection format: :bogus'
      )
    end
  end

  describe '#object_to_http_body' do
    it 'returns nil for nil' do
      expect(client.object_to_http_body(nil)).to be_nil
    end

    it 'returns a string unchanged' do
      body = 'already-serialized'

      expect(client.object_to_http_body(body)).to be(body)
    end

    it 'converts a hash to json' do
      expect(client.object_to_http_body('a' => 1)).to eq('{"a":1}')
    end

    it 'converts an array to json' do
      expect(client.object_to_http_body([{ 'a' => 1 }])).to eq('[{"a":1}]')
    end

    it 'uses to_hash on models' do
      model_class =
        Class.new do
          def to_hash
            { 'x' => 1 }
          end
        end

      expect(client.object_to_http_body(model_class.new)).to eq('{"x":1}')
    end
  end

  describe '#build_request_url' do
    it 'prefixes the path with the base url' do
      expect(client.build_request_url('orders/v0/orders')).to eq("#{base_url}/orders/v0/orders")
    end

    it 'collapses duplicate slashes' do
      expect(client.build_request_url('//orders//v0///orders')).to eq(
        "#{base_url}/orders/v0/orders"
      )
    end
  end
end
