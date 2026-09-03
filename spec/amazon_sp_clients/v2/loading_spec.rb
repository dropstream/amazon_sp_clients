require 'spec_helper'
require 'open3'
require 'rbconfig'

# V2 shares only the dependency-free files with v1 (ApiResponse,
# ApiError, the marketplace tables, the adapter loader). This runs in a
# fresh process because the suite itself always has v1 loaded.
RSpec.describe 'require "amazon_sp_clients/v2"' do
  it 'loads every V2 class without loading v1' do
    script = <<~RUBY
      require 'amazon_sp_clients/v2'
      AmazonSpClients::V2.constants.each { |c| AmazonSpClients::V2.const_get(c) }

      v1_only = %i[Session ApiClient Configuration TokenExchangeAuth Uploader Downloader
                   AuthResponse Middlewares]
      loaded_v1 = v1_only.select { |c| AmazonSpClients.const_defined?(c, false) }
      loaded_v1 += AmazonSpClients.constants.grep(/\\ASp[A-Z]/)
      vendor_dir = File.expand_path('vendor')
      vendored = $LOADED_FEATURES.select { |f| f.start_with?("\#{vendor_dir}/") }
      client = AmazonSpClients::V2::Client
      accessors = client.instance_methods(false).count do |m|
        client.instance_method(m).source_location.first.end_with?('/v2/apis.rb')
      end

      puts loaded_v1.inspect
      puts vendored.size
      puts accessors
    RUBY

    out, err, status = Open3.capture3(RbConfig.ruby, '-Ilib', '-e', script)

    expect(err).to eq('')
    expect(status).to be_success
    expect(out.lines.map(&:strip)).to eq(['[]', '0', '14'])
  end
end
