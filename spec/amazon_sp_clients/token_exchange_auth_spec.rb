require 'spec_helper'
require 'webmock/rspec'

RSpec.describe AmazonSpClients do
  before do
    c = AmazonSpClients::Configuration.new
    c.access_key = 'key'
    c.secret_key = 'secret'
    c.role_arn = 'arn::****'
    # c.logger = Logger.new($stdout)
    # c.logger.level = Logger::DEBUG
    # c.debugging = true
    @token = AmazonSpClients::TokenExchangeAuth.new(c)
  end

  context 'granted' do
    describe '#exchange' do
      it 'raises' do
        stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(
          status: 400,
          body: fixture('token_error.json'),
        )

        expect { @token.exchange }.to raise_error(
          Faraday::BadRequestError,
          /Service 'token' ERR: error: invalid_client/,
        )
      end
    end

    context 'grantless'
  end
end
