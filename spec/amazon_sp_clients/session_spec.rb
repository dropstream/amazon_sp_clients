require 'spec_helper'

# Characterization specs. They pin what Session does today, before the
# modernization refactor. They are not a statement of intended design.
RSpec.describe AmazonSpClients::Session do
  let(:token_url) { 'https://api.amazon.com/auth/o2/token' }

  # From spec/fixtures/token_success.json.
  let(:fixture_access_token) { 'Atza|IQEBLjAsAhRmHjNgHpi0U-Dme37rR6CuUpSREXAMPLE' }
  let(:fixture_refresh_token) { 'Atzr|IQEBLzAtAhRPpMJxdwVz2Nn6f2y-tpJX2DeXEXAMPLE' }

  let(:config) do
    AmazonSpClients::Configuration.new do |c|
      c.client_id = 'CLIENT_ID'
      c.client_secret = 'CLIENT_SECRET'
      c.sandbox_env!
    end
  end

  # Session.new takes the config positionally.
  let(:session) { described_class.new(config) }

  before do
    # TokenExchangeAuth and ApiClient read Configuration.default, not the
    # config passed to Session.new, so the default must be the same object.
    Thread.current[:amazon_sp_configuration] = config

    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
  end

  after { Thread.current[:amazon_sp_configuration] = nil }

  describe '#authenticate' do
    before do
      stub_request(:post, token_url).to_return(status: 200, body: fixture('token_success.json'))
    end

    it 'returns self' do
      expect(session.authenticate('REFRESH_TOKEN')).to be(session)
    end

    it 'exposes the access token from the response' do
      session.authenticate('REFRESH_TOKEN')

      expect(session.access_token).to eq(fixture_access_token)
    end

    it 'sends a refresh_token grant with client credentials' do
      session.authenticate('REFRESH_TOKEN')

      expect(
        a_request(:post, token_url).with(
          body: {
            'grant_type' => 'refresh_token',
            'client_id' => 'CLIENT_ID',
            'client_secret' => 'CLIENT_SECRET',
            'refresh_token' => 'REFRESH_TOKEN'
          }
        )
      ).to have_been_made.once
    end

    it 'skips the token request while the token is valid' do
      session.authenticate('REFRESH_TOKEN')
      session.authenticate('REFRESH_TOKEN')

      expect(a_request(:post, token_url)).to have_been_made.once
    end
  end

  describe '#refresh with a refresh token session' do
    before do
      stub_request(:post, token_url).to_return(status: 200, body: fixture('token_success.json'))
    end

    it 'makes no request while the token is valid' do
      session.authenticate('REFRESH_TOKEN')

      session.refresh

      expect(a_request(:post, token_url)).to have_been_made.once
    end

    it 're-requests after the token expires' do
      session.authenticate('REFRESH_TOKEN')

      Timecop.freeze(Time.now + 3601)
      session.refresh

      expect(a_request(:post, token_url)).to have_been_made.times(2)
    end

    it 'uses the refresh token from the last response' do
      session.authenticate('REFRESH_TOKEN')

      Timecop.freeze(Time.now + 3601)
      session.refresh

      expect(
        a_request(:post, token_url).with(
          body: hash_including('refresh_token' => fixture_refresh_token)
        )
      ).to have_been_made.once
    end
  end

  describe '#refresh with a grantless session' do
    # Grantless (client_credentials) responses carry no refresh_token.
    let(:grantless_body) do
      '{"access_token":"Atza|GRANTLESS","token_type":"bearer","expires_in":3600}'
    end

    before do
      stub_request(:post, token_url).to_return(status: 200, body: grantless_body)
    end

    it 'makes no request while the token is valid' do
      session.authenticate_grantless('test::scope')

      session.refresh

      expect(a_request(:post, token_url)).to have_been_made.once
    end

    it 're-requests with the client_credentials grant after expiry' do
      session.authenticate_grantless('test::scope')

      Timecop.freeze(Time.now + 3601)
      session.refresh

      expect(
        a_request(:post, token_url).with(
          body: hash_including(
            'grant_type' => 'client_credentials',
            'scope' => 'test::scope'
          )
        )
      ).to have_been_made.times(2)
    end
  end

  describe '#authenticate_grantless' do
    before do
      stub_request(:post, token_url).to_return(status: 200, body: fixture('token_success.json'))
    end

    it 'returns self' do
      expect(session.authenticate_grantless('test::scope')).to be(session)
    end

    it 'exposes the access token from the response' do
      session.authenticate_grantless('test::scope')

      expect(session.access_token).to eq(fixture_access_token)
    end

    # The exact body match also pins that no refresh_token param is sent.
    it 'sends a client_credentials grant with the scope' do
      session.authenticate_grantless('test::scope')

      expect(
        a_request(:post, token_url).with(
          body: {
            'grant_type' => 'client_credentials',
            'client_id' => 'CLIENT_ID',
            'client_secret' => 'CLIENT_SECRET',
            'scope' => 'test::scope'
          }
        )
      ).to have_been_made.once
    end
  end

  describe '#with_callback' do
    it 'returns self' do
      expect(session.with_callback { 'T' }).to be(session)
    end

    it 'refresh adopts the callback return value as access token' do
      session.with_callback { 'CB_TOKEN' }

      session.refresh

      expect(session.access_token).to eq('CB_TOKEN')
    end

    it 'refresh calls the callback every time' do
      tokens = %w[first second].each
      session.with_callback { tokens.next }

      session.refresh
      expect(session.access_token).to eq('first')

      session.refresh
      expect(session.access_token).to eq('second')
    end
  end

  describe '#ask_for_restricted_data_token' do
    let(:rdt_url) do
      'https://sandbox.sellingpartnerapi-na.amazon.com/tokens/2021-03-01/restrictedDataToken'
    end

    # Callback session: refresh never needs the token endpoint.
    let(:session) { described_class.new(config).with_callback { 'CB_TOKEN' } }

    before do
      stub_request(:post, rdt_url).to_return(
        status: 200,
        body: '{"payload":{"restrictedDataToken":"RDT","expiresIn":3600}}'
      )
    end

    it 'sends the known resource list for a symbol' do
      session.ask_for_restricted_data_token(:orders)

      expect(
        a_request(:post, rdt_url).with(
          body: {
            restrictedResources: [
              {
                method: 'GET',
                path: '/orders/v0/orders',
                dataElements: %w[buyerInfo shippingAddress]
              }
            ]
          }
        )
      ).to have_been_made.once
    end

    it 'wraps a non-symbol resource in restrictedResources' do
      resource = { method: 'GET', path: '/custom/path', dataElements: ['buyerInfo'] }

      session.ask_for_restricted_data_token(resource)

      expect(
        a_request(:post, rdt_url).with(body: { restrictedResources: [resource] })
      ).to have_been_made.once
    end

    it 'exposes the token keyed by resource' do
      session.ask_for_restricted_data_token(:orders)

      expect(session.restricted_data_token[:orders]).to eq('RDT')
    end

    it 'authorizes the request with the session access token' do
      session.ask_for_restricted_data_token(:orders)

      expect(
        a_request(:post, rdt_url).with(headers: { 'x-amz-access-token' => 'CB_TOKEN' })
      ).to have_been_made.once
    end

    it 'caches the token per resource' do
      session.ask_for_restricted_data_token(:orders)
      session.ask_for_restricted_data_token(:orders)

      expect(a_request(:post, rdt_url)).to have_been_made.once
    end

    it 'requests once per distinct resource' do
      session.ask_for_restricted_data_token(:orders)
      session.ask_for_restricted_data_token(:orders_and_items)

      expect(a_request(:post, rdt_url)).to have_been_made.times(2)

      # :orders_and_items has its own resource list, not the :orders one.
      expect(
        a_request(:post, rdt_url).with(
          body: {
            restrictedResources: [
              {
                method: 'GET',
                path: '/orders/v0/orders',
                dataElements: %w[buyerInfo shippingAddress]
              },
              {
                method: 'GET',
                path: '/orders/v0/orders/{orderId}/orderItems',
                dataElements: %w[buyerInfo]
              }
            ]
          }
        )
      ).to have_been_made.once
    end

    it 're-requests after the token expires' do
      session.ask_for_restricted_data_token(:orders)

      Timecop.freeze(Time.now + 3601)
      session.ask_for_restricted_data_token(:orders)

      expect(a_request(:post, rdt_url)).to have_been_made.times(2)
    end
  end
end
