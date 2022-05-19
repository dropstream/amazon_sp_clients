require 'faraday'
require 'amazon_sp_clients/sp_authorization'

module AmazonSpClients
  class TokenMigration
    def initialize(options = {})
      @redirect_uri = options.delete(:redirect_uri)

      if options.has_key?(:secret_access_key)
        AmazonSpClients.configure do |c|
          c.endpoint = options[:endpoint] || 'na'
          c.access_key = options[:access_key_id]
          c.secret_key = options[:secret_access_key]
          c.role_arn = options[:role_arn]
          c.client_id = options[:client_id]
          c.client_secret = options[:client_secret]
        end
      end

      @conn =
        Faraday.new('https://api.amazon.com/') do |c|
          c.adapter Faraday::Adapter::HTTPClient
          c.request :url_encoded
          c.response :json
        end
    end

    # @return Hash success response returns hash 'refresh_token' as key
    def get_refresh_token(selling_partner_id, developer_id, mws_auth_token)
      auth_resp = auth_api.get_authorization_code(selling_partner_id, developer_id, mws_auth_token)
      raise "Failed to get authorizationCode: '#{response.errors.inspect}'" if auth_resp.errors

      auth_code = auth_resp.payload[:authorizationCode]

      # exchange authorization code for refresh_token
      response =
        @conn.post(
          '/auth/o2/token',
          {
            grant_type: 'authorization_code',
            code: auth_code,
            redirect_uri: @redirect_uri,
            client_id: AmazonSpClients.configure.client_id,
            client_secret: AmazonSpClients.configure.client_secret,
          },
        )

      response.body
    end

    private

    def session
      @api_session ||= AmazonSpClients.new_migration_session
    end

    def auth_api
      @auth_api ||= AmazonSpClients::SpAuthorization::AuthorizationApi.new(session)
    end
  end
end



