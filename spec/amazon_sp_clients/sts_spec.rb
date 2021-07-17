require 'spec_helper'
require 'webmock/rspec'
require 'logger'

RSpec.describe AmazonSpClients::Sts do
  before do
    c = AmazonSpClients::Configuration.new
    c.access_key = 'key'
    c.secret_key = 'secret'
    c.role_arn = 'arn::****'
    # c.logger = Logger.new($stdout)
    # c.logger.level = Logger::DEBUG
    # c.debugging = true
    @sts = AmazonSpClients::Sts.new(c)
  end

  describe 'success' do
    it 'returns struct on success response' do
      stub_request(:post, 'https://sts.amazonaws.com/')
        .with(
          body: {
            'Action' => 'AssumeRole',
            'DurationSeconds' => '3600',
            'RoleArn' => 'arn::****',
            'RoleSessionName' => 'SPAPISession',
            'Version' => '2011-06-15',
          },
        )
        .to_return(
          status: 200,
          body: fixture('sts_200_response.xml'),
          headers: {
            'Content-Type' => 'application/xml',
          },
        )

      resp = @sts.assume_role
      expect(resp.session_token).to match /^Fwo.+/
    end

    it 'returns error object on response' do
      stub_request(:post, 'https://sts.amazonaws.com/')
        .with(
          body: {
            'Action' => 'AssumeRole',
            'DurationSeconds' => '3600',
            'RoleArn' => 'arn::****',
            'RoleSessionName' => 'SPAPISession',
            'Version' => '2011-06-15',
          },
        )
        .to_return(
          status: 403,
          body: fixture('sts_403_response.xml'),
          headers: {
            'Content-Type' => 'application/xml',
          },
        )

      expect { @sts.assume_role }.to raise_error(
        Faraday::ForbiddenError,
        /Service 'sts' ERR: type: Sender code: SignatureDoesNotMatch message: /,
      )
    end
  end
end
