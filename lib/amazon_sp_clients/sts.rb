# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

# You needed to assume the role that was used when adding an
# application. This step is not described in the documentation.
# https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html You
# will get an ID, secret and token. The Id and secret should be used instead of
# the id and secret for your user. The token should be added to the header as
# x-amz-security-token.
module AmazonSpClients
  class StsResponse < Struct.new(
    :access_key,
    :secret_key,
    :session_token,
    :expires,
  )
  end

  class Sts
    STS_HOST = 'sts.amazonaws.com'

    def initialize(config = Configuration.default)
      @role_arn = config.role_arn
      @logger = config.logger
      @debugging = config.debugging

      @conn =
        Faraday.new("https://#{STS_HOST}") do |conn|
          conn.adapter Faraday::Adapter::HTTPClient
          conn.request :url_encoded
          conn.response :xml
          conn.use AmazonSpClients::Middlewares::RequestSignerV4,
                   {
                     access_key: config.access_key,
                     secret_key: config.secret_key,
                     region: config.region,
                     service_name: 'sts',
                   }
        end
    end

    def assume_role
      resp =
        @conn.post '/', request_params do |req|
          req.headers.merge!(
            { 'x-amz-date' => Time.now.utc.strftime('%Y%m%dT%H%M%SZ') },
          )
        end

      if @debugging == true
        @logger.debug "STS response body ~BEGIN~\n#{resp.body}\n~END~\n"
      end

      unless resp.success?
        err = resp.body['ErrorResponse']['Error']
        @logger.debug "#{self.class.name} returned error response: #{resp.status}): #{err['Code']} - #{err['Message']}"
        raise AmazonSpClients::ServiceError.new(
                "type: #{err['Type']} code: #{err['Code']} message: #{err['Message']}",
                :sts,
              )
      end
      @logger.debug "#{self.class.name} returned success response"

      creds = resp.body['AssumeRoleResponse']['AssumeRoleResult']['Credentials']

      StsResponse.new(
        creds['AccessKeyId'],
        creds['SecretAccessKey'],
        creds['SessionToken'],
        creds['Expiration'],
      )
    end

    private

    def request_params
      {
        'Action' => 'AssumeRole',
        'DurationSeconds' => '3600',
        'RoleArn' => @role_arn,
        'RoleSessionName' => 'SPAPISession',
        'Version' => '2011-06-15',
      }
    end
  end
end
