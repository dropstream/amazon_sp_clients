require 'spec_helper'
require 'webmock/rspec'
require 'pry-byebug'

def fixture(name)
  File.read(File.expand_path("../../../spec/fixtures/#{name}.json", __FILE__))
end

RSpec.describe AmazonSpClients do
  before do
    AmazonSpClients.configure do |c|
      c.sandbox_env!
      c.marketplace = :us
      c.refresh_token = 'Aztr|...'
      # c.access_key = 'FooBar'
      # c.secret_key = 'SECRET_KEY'
    end
  end

  describe '#exchange' do
    context 'granted' do
      it 'return access_token for success response' do
        stub_request(:post, 'https://api.amazon.com/auth/o2/token')
          .with(
            body:
              'client_id=foodev&client_secret=Y76SDl2F&grant_type=refresh_token&refresh_token=Aztr%7C...',
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' =>
                'application/x-www-form-urlencoded;charset=UTF-8',
              'User-Agent' => 'Faraday v1.4.2'
            }
          )
          .to_return(status: 200, body: fixture('token_success'))

        resp =
          AmazonSpClients::Auth
            .new('foodev', 'Y76SDl2F')
            .exchange('refresh_token')

        exp = 'Atza|IQEBLjAsAhRmHjNgHpi0U-Dme37rR6CuUpSREXAMPLE'
        expect(resp['access_token']).to eq exp
      end
    end

    context 'grantless'
  end
end
