# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'openssl'

# You needed to assume the role that was used when adding an
# application. This step is not described in the documentation.
# https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html You
# will get an ID, secret and token. The Id and secret should be used instead of
# the id and secret for your user. The token should be added to the header as
# x-amz-security-token.
module AmazonSpClients
  class StsResponse < Struct.new(:access_key, :secret_key, :session_token)
  end

  class Sts
    STS_HOST = 'sts.amazonaws.com'

    # TODO: convert this to amazon user?
    def initialize(
      role_arn,
      access_key,
      secret_key,
      config = Configuration.default
    )
      @config = config
      @role_arn = role_arn

      @conn =
        Faraday.new("https://#{STS_HOST}") do |conn|
          conn.request :url_encoded
          conn.response :xml, content_type: /\bxml$/
          conn.response :json, content_type: /\bjson$/
          conn.use AmazonSpClients::Middlewares::StsSigner,
                   {
                     # TODO: GET THOSE FROM config?
                     access_key: access_key,
                     secret_key: secret_key,
                     region: @config.region,
                     service_name: 'sts'
                   }
        end
    end

    def assume_role
      resp =
        @conn.post '/', request_params do |req|
          req.headers.merge!(
            { 'x-amz-date' => Time.now.utc.strftime('%Y%m%dT%H%M%SZ') }
          )
        end

      response_struct = nil
      if resp.success?
        creds =
          resp.body['AssumeRoleResponse']['AssumeRoleResult']['Credentials']
        response_struct =
          StsResponse.new(
            creds['AccessKeyId'],
            creds['SecretAccessKey'],
            creds['SessionToken'],
            creds['Expiration'],
            resp
          )
        @logger.debug "#{self.class.name} returned success response"
      else
        err = resp.body['ErrorResponse']['Error']
        response_struct =
          StsErrorResponse.new(err['Type'], err['Code'], err['Message'], resp)
        @logger.error "#{self.class.name} returned error response (#{
                        resp.status
                      }): #{response_struct.code} - #{response_struct.message}"
      end

      if @debugging == true
        @logger.debug "STS response body ~BEGIN~\n#{resp.body}\n~END~\n"
      end

      response_struct
    end

    private

    def request_params
      {
        'Action' => 'AssumeRole',
        'DurationSeconds' => '3600',
        'RoleArn' => @role_arn,
        'RoleSessionName' => 'SPAPISession',
        'Version' => '2011-06-15'
      }
    end

    def assume_role
      resp =
        @conn.post '/', params do |req|
          req.headers.merge!(
            { 'x-amz-date' => Time.now.utc.strftime('%Y%m%dT%H%M%SZ') }
          )
        end

      # TODO: handle errors responses
      creds = resp.body['AssumeRoleResponse']['AssumeRoleResult']['Credentials']
      StsResponse.new(
        creds['AccessKeyId'],
        creds['SecretAccessKey'],
        creds['SessionToken']
      )
    end
  end
end
