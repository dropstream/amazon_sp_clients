module AmazonSpClients
  class ApiError
    class Error < Struct.new(:code, :message, :details)
    end

    attr_reader :errors

    # attr_reader :code, :response_headers, :errors

    # SP API returns errors in this format:
    #
    #   {"errors"=>[{"code"=>"InvalidInput", "message"=>"Invalid Input"}]}
    #
    def initialize(errors)
      @errors =
        errors.map do |h|
          AmazonSpClients::ApiError::Error.new(
            h[:code],
            h[:message],
            h[:details]
          )
        end
    end

    def full_messages
      @errors.map do |err|
        "#{err.code}: #{err.message}#{err.details ? ' - ' + err.details : ''}"
      end.join(', ')
    end
  end
end
