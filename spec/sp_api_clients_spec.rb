require 'spec_helper'
require 'open3'
require 'rbconfig'

# The gem is named sp_api_clients, the code keeps the AmazonSpClients
# namespace and require paths. This shim makes `gem 'sp_api_clients'`
# work with Bundler's automatic require. Fresh process: the suite has
# the gem loaded already.
RSpec.describe 'require "sp_api_clients"' do
  it 'loads the v1 entry point' do
    script = <<~RUBY
      require 'sp_api_clients'
      puts [defined?(AmazonSpClients::Session), defined?(AmazonSpClients::V2)].inspect
    RUBY

    out, err, status = Open3.capture3(RbConfig.ruby, '-Ilib', '-e', script)

    expect(err).to eq('')
    expect(status).to be_success
    expect(out.strip).to eq('["constant", nil]')
  end
end
