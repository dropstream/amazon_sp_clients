# frozen_string_literal: true

require 'net/http'

# https://github.com/amzn/selling-partner-api-docs/issues/292#issuecomment-759904882
module Net::HTTPHeader
  def capitalize(name)
    name
  end
  private :capitalize
end
