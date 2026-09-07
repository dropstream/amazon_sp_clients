require 'spec_helper'
require 'open3'
require 'rbconfig'

# V2 must load the region and marketplace tables without loading the
# rest of v1, so they live in a file of their own.
RSpec.describe 'amazon_sp_clients/marketplaces' do
  it 'defines the tables without loading v1' do
    script = <<~RUBY
      require 'amazon_sp_clients/marketplaces'
      puts [
        AmazonSpClients::REGIONS.frozen?,
        AmazonSpClients::MARKETPLACE_IDS.size,
        AmazonSpClients::MARKETPLACE_ENDPOINT_MAP.size,
        AmazonSpClients::REGIONS.fetch(AmazonSpClients::REGION_NA),
        defined?(AmazonSpClients::Session).inspect
      ].join(' ')
    RUBY

    out, err, status = Open3.capture3(RbConfig.ruby, '-Ilib', '-e', script)

    expect(err).to eq('')
    expect(status).to be_success
    expect(out.strip).to eq('true 20 20 sellingpartnerapi-na.amazon.com nil')
  end
end
