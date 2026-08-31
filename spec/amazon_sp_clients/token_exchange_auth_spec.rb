require 'spec_helper'

RSpec.describe AmazonSpClients::TokenExchangeAuth do
  before do
    c = AmazonSpClients::Configuration.new
    c.client_id = 'CLIENT_ID'
    c.client_secret = 'CLIENT_SECRET'
    @token = AmazonSpClients::TokenExchangeAuth.new('REFRESH_TOKEN', c)
  end

  describe '#exchange' do
    context 'granted (refresh_token)' do
      it 'returns AuthResponse with token fields' do
        stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(
          status: 200,
          body: fixture('token_success.json')
        )

        resp = @token.exchange

        expect(resp).to be_a(AmazonSpClients::AuthResponse)
        expect(resp.access_token).to eq(
          'Atza|IQEBLjAsAhRmHjNgHpi0U-Dme37rR6CuUpSREXAMPLE'
        )
        expect(resp.token_type).to eq('bearer')
        expect(resp.expires_in).to eql(3600)
        expect(resp.refresh_token).to eq(
          'Atzr|IQEBLzAtAhRPpMJxdwVz2Nn6f2y-tpJX2DeXEXAMPLE'
        )
      end

      it 'posts form-encoded credentials and refresh token' do
        stub =
          stub_request(:post, 'https://api.amazon.com/auth/o2/token')
          .with(
            body: {
              'grant_type' => 'refresh_token',
              'client_id' => 'CLIENT_ID',
              'client_secret' => 'CLIENT_SECRET',
              'refresh_token' => 'REFRESH_TOKEN'
            },
            headers: {
              'Content-Type' => 'application/x-www-form-urlencoded'
            }
          )
          .to_return(status: 200, body: fixture('token_success.json'))

        @token.exchange

        expect(stub).to have_been_requested
      end

      it 'raises Faraday::BadRequestError on 400' do
        stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(
          status: 400,
          body: fixture('token_error.json')
        )

        expect { @token.exchange }.to raise_error(
          Faraday::BadRequestError,
          "Service 'token' ERR: error: invalid_client " \
          'description: Client authentication failed'
        ) do |err|
          expect(err.response[:service]).to eq(:token)
          expect(err.response[:response][:status]).to eq(400)
        end
      end
    end

    context 'grantless (client_credentials)' do
      it 'sends scope and no refresh token' do
        stub =
          stub_request(:post, 'https://api.amazon.com/auth/o2/token')
          .with(
            body: {
              'grant_type' => 'client_credentials',
              'client_id' => 'CLIENT_ID',
              'client_secret' => 'CLIENT_SECRET',
              'scope' => 'some::scope'
            }
          )
          .to_return(status: 200, body: fixture('token_success.json'))

        @token.exchange('client_credentials', 'some::scope')

        expect(stub).to have_been_requested
      end

      it 'requires scope' do
        expect { @token.exchange('client_credentials') }.to raise_error(
          RuntimeError,
          'Grantless operations require scope'
        )
      end
    end

    it 'rejects unknown grant type' do
      expect { @token.exchange('bogus') }.to raise_error(
        RuntimeError,
        'Invalid grant_type'
      )
    end
  end
end
