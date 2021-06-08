require 'spec_helper'
require 'webmock/rspec'
require 'pry-byebug'

RSpec.describe AmazonSpClients do
  before do
    AmazonSpClients.configure do |c|
      c.sandbox_env!
      c.marketplace = :us
      c.refresh_token = 'Aztr|...'
      c.client_id = 'a'
      c.client_secret = 'b'
    end
  end

  describe '#exchange' do
    context 'granted' do
      it 'return access_token for success response' do
        stub_request(:post, 'https://api.amazon.com/auth/o2/token')
          .with(
            body: {
              'client_id' => 'a',
              'client_secret' => 'b',
              'grant_type' => 'refresh_token',
              'refresh_token' => 'Aztr|...'
            }
          )
          .to_return(status: 200, body: fixture('token_success.json'))

        resp = AmazonSpClients::TokenExchangeAuth.new.exchange('refresh_token')

        exp = 'Atza|IQEBLjAsAhRmHjNgHpi0U-Dme37rR6CuUpSREXAMPLE'
        expect(resp.access_token).to eq exp
      end
    end

    context 'grantless'
  end
end
