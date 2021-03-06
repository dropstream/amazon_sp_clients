# frozen_string_literal: true

require 'time'
require 'json'
require 'tempfile'
require 'faraday'
require 'faraday_middleware'

module AmazonSpClients
  class ApiClient
    # The Configuration object holding settings to be used in the API client.
    attr_accessor :config

    attr_accessor :connection

    # Defines the headers to be used in HTTP requests of all API calls by
    # default.
    #
    # @return [Hash]
    attr_accessor :default_headers

    # Initializes the ApiClient
    # @option config [Configuration] Configuration for initializing the object,
    # default to Configuration.default
    def initialize(session, config = Configuration.default)
      @session = session

      @config = config
      @user_agent = "Dropstream/1.0 (Language=Ruby/#{RUBY_VERSION})"
      @default_headers = { 'Content-Type' => 'application/json', 'User-Agent' => @user_agent }
      @api_req_otps = {}
      @connection =
        Faraday.new(
          url: @config.base_url,
          headers: @default_headers,
          request: {
            timeout: @config.timeout,
          },
        ) do |conn|
          conn.adapter Faraday::Adapter::HTTPClient

          conn.use AmazonSpClients::Middlewares::RequestSignerV4,
                   { session: @session, region: @config.region }

          conn.use AmazonSpClients::Middlewares::RaiseError, { service: :spapi }
        end
    end

    # Call an API with given options.
    #
    # @return [Array<(Object, Integer, Hash)>] an array of 3 elements: the data
    # deserialized from response body (could be nil), response status code and
    # response headers.
    def call_api(http_method, path, opts = {})
      # Non standard usage of auth_names to determine if this is restricted access data kind
      # of request:
      restricted_resource = (Array(opts.delete(:auth_names)).first if opts.has_key?(:auth_names))

      url, req_opts = build_request(http_method, path, opts)

      raise 'Ensure session is valid before calling API methods' if @session.nil?

      access_token = ''
      if restricted_resource
        @session.ask_for_restricted_data_token(restricted_resource)
        access_token = @session.restricted_data_token[restricted_resource]
      else
        @session.refresh
        access_token = @session.access_token
      end

      response =
        @connection.send(req_opts[:method], url, req_opts[:params]) do |req|
          req.body = req_opts[:body]
          req.headers.merge!(
            {
              'x-amz-date' => Time.now.utc.strftime('%Y%m%dT%H%M%SZ'),
              'x-amz-access-token' => access_token,
            },
          )
        end

      if @config.debugging
        @config.logger.debug "HTTP response body ~BEGIN~\n#{response.body}\n~END~\n"
      end

      # Skipping error check and raise (use middleware for that instead)

      if opts[:return_type]
        data = deserialize(response, opts[:return_type])
      else
        data = nil
      end

      return data
    end

    # Builds the HTTP request
    #
    # @param [String] http_method HTTP method/verb (e.g. POST)
    # @param [String] path URL path (e.g. /account/new)
    # @option opts [Hash] :header_params Header parameters
    # @option opts [Hash] :query_params Query parameters
    # @option opts [Hash] :form_params Query parameters
    # @option opts [Object] :body HTTP body (JSON/XML)
    # @return [Typhoeus::Request] A Typhoeus Request
    def build_request(http_method, path, opts = {})
      url = build_request_url(path)
      http_method = http_method.to_sym.downcase

      header_params = @default_headers.merge(opts[:header_params] || {})
      query_params = opts[:query_params] || {}
      form_params = opts[:form_params] || {}

      # set ssl_verifyhosts option based on @config.verify_ssl_host (true/false)
      _verify_ssl_host = @config.verify_ssl_host ? 2 : 0

      req_opts = {
        method: http_method,
        headers: header_params,
        params: query_params,
        params_encoding: @config.params_encoding,
        timeout: @config.timeout,
        ssl_verifypeer: @config.verify_ssl,
        ssl_verifyhost: _verify_ssl_host,
        sslcert: @config.cert_file,
        sslkey: @config.key_file,
        verbose: @config.debugging,
      }

      # set custom cert, if provided
      req_opts[:cainfo] = @config.ssl_ca_cert if @config.ssl_ca_cert

      if %i[post patch put delete].include?(http_method)
        req_body = build_request_body(header_params, form_params, opts[:body])
        req_opts.update body: req_body
        if @config.debugging
          @config.logger.debug "HTTP request body param ~BEGIN~\n#{req_body}\n~END~\n"
        end
      end

      # download_file(request) if opts[:return_type] == 'File'
      return url, req_opts
    end

    # Builds the HTTP request body
    #
    # @param [Hash] header_params Header parameters
    # @param [Hash] form_params Query parameters
    # @param [Object] body HTTP body (JSON/XML)
    # @return [String] HTTP body data in the form of string
    def build_request_body(header_params, form_params, body)
      # http form
      if header_params['Content-Type'] == 'application/x-www-form-urlencoded' ||
           header_params['Content-Type'] == 'multipart/form-data'
        data = {}
        form_params.each do |key, value|
          case value
          when ::File, ::Array, nil
            # TODO: how does http lib support File and Array params?
            data[key] = value
          else
            data[key] = value.to_s
          end
        end
      elsif body
        data = body.is_a?(String) ? body : body.to_json
      else
        data = nil
      end
      data
    end

    # Check if the given MIME is a JSON MIME.
    # JSON MIME examples:
    #   application/json
    #   application/json; charset=UTF8
    #   APPLICATION/JSON
    #   */*
    # @param [String] mime MIME
    # @return [Boolean] True if the MIME is application/json
    def json_mime?(mime)
      (mime == '*/*') || !(mime =~ %r{Application\/.*json(?!p)(;.*)?}i).nil?
    end

    # Deserialize the response to the given return type.
    #
    # @param [Response] response HTTP response
    # @param [String] return_type some examples: "User", "Array<User>",
    # "Hash<String, Integer>"
    def deserialize(response, return_type)
      body = response.body
      body = JSON.parse(body, symbolize_names: true) if body.is_a?(String)

      # handle file downloading - return the File instance processed in request
      # callbacks note that response body is empty when the file is written in
      # chunks in request on_body callback
      return @tempfile if return_type == 'File'

      return nil if body.nil? || body.empty?

      # return response body directly for String return type
      return body if return_type == 'String'

      # ensuring a default content type
      content_type = response.headers['Content-Type'] || 'application/json'

      fail "Content-Type is not supported: #{content_type}" unless json_mime?(content_type)

      begin
        if body.is_a?(String)
          data = JSON.parse("[#{body}]", symbolize_names: true)[0]
        else
          data = body
        end
      rescue JSON::ParserError => e
        if %w[String Date DateTime].include?(return_type)
          data = body
        else
          raise e
        end
      end

      convert_to_type(data, return_type, response)
    end

    # Convert data to the given return type.
    # @param [Object] data Data to be converted
    # @param [String] return_type Return type
    # @return [Mixed] Data in a particular type
    def convert_to_type(data, return_type, response)
      return nil if data.nil?
      case return_type
      when 'String'
        data.to_s
      when 'Integer'
        data.to_i
      when 'Float'
        data.to_f
      when 'Boolean'
        data == true
      when 'DateTime'
        # parse date time (expecting ISO 8601 format)
        DateTime.parse data
      when 'Date'
        # parse date time (expecting ISO 8601 format)
        Date.parse data
      when 'Object'
        # generic object (usually a Hash), return directly
        data
      when /\AArray<(.+)>\z/
        # e.g. Array<Pet>
        sub_type = $1
        data.map { |item| convert_to_type(item, sub_type, response) }
      when /\AHash\<String, (.+)\>\z/
        # e.g. Hash<String, Integer>
        sub_type = $1
        {}.tap { |hash| data.each { |k, v| hash[k] = convert_to_type(v, sub_type, response) } }
      else
        AmazonSpClients::ApiResponse.build_from_hash(data, response)
      end
    end

    def build_request_url(path)
      # Add leading and trailing slashes to path
      path = "/#{path}".gsub(%r{\/+}, '/')
      @config.base_url + path
    end

    ## Update hearder and query params based on authentication settings.
    ##
    ## @param [Hash] header_params Header parameters
    ## @param [Hash] query_params Query parameters
    ## @param [String] auth_names Authentication scheme name
    #def update_params_for_auth!(header_params, query_params, auth_names)
    #  Array(auth_names).each do |auth_name|
    #    auth_setting = @config.auth_settings[auth_name]
    #    next unless auth_setting
    #    case auth_setting[:in]
    #    when 'header'
    #      header_params[auth_setting[:key]] = auth_setting[:value]
    #    when 'query'
    #      query_params[auth_setting[:key]] = auth_setting[:value]
    #    else
    #      fail ArgumentError,
    #           'Authentication token must be in `query` of `header`'
    #    end
    #  end
    #end

    # Sets user agent in HTTP header
    #
    # @param [String] user_agent User agent (e.g. swagger-codegen/ruby/1.0.0)
    def user_agent=(user_agent)
      @user_agent = user_agent
      @default_headers['User-Agent'] = @user_agent
    end

    # Return Accept header based on an array of accepts provided.
    # @param [Array] accepts array for Accept
    # @return [String] the Accept header (e.g. application/json)
    def select_header_accept(accepts)
      return nil if accepts.nil? || accepts.empty?

      # use JSON when present, otherwise use all of the provided
      json_accept = accepts.find { |s| json_mime?(s) }
      json_accept || accepts.join(',')
    end

    # Return Content-Type header based on an array of content types provided.
    # @param [Array] content_types array for Content-Type
    # @return [String] the Content-Type header  (e.g. application/json)
    def select_header_content_type(content_types)
      # use application/json by default
      return 'application/json' if content_types.nil? || content_types.empty?

      # use JSON when present, otherwise use the first one
      json_content_type = content_types.find { |s| json_mime?(s) }
      json_content_type || content_types.first
    end

    # Convert object (array, hash, object, etc) to JSON string.
    # @param [Object] model object to be converted into JSON string
    # @return [String] JSON string representation of the object
    def object_to_http_body(model)
      return model if model.nil? || model.is_a?(String)
      local_body = nil
      if model.is_a?(Array)
        local_body = model.map { |m| object_to_hash(m) }
      else
        local_body = object_to_hash(model)
      end
      local_body.to_json
    end

    # Convert object(non-array) to hash.
    # @param [Object] obj object to be converted into JSON string
    # @return [String] JSON string representation of the object
    def object_to_hash(obj)
      obj.respond_to?(:to_hash) ? obj.to_hash : obj
    end

    # Build parameter value according to the given collection format.
    # @param [String] collection_format one of :csv, :ssv, :tsv, :pipes and :multi
    def build_collection_param(param, collection_format)
      case collection_format
      when :csv
        param.join(',')
      when :ssv
        param.join(' ')
      when :tsv
        param.join("\t")
      when :pipes
        param.join('|')
      when :multi
        # return the array directly as typhoeus will handle it as expected
        param
      else
        fail "unknown collection format: #{collection_format.inspect}"
      end
    end
  end
end
