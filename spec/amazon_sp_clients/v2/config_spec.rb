require 'spec_helper'
require 'amazon_sp_clients/v2'

RSpec.describe AmazonSpClients::V2::Config do
  describe 'defaults' do
    subject(:config) { described_class.new }

    it 'points at the NA production host' do
      expect(config.endpoint).to eq('na')
      expect(config.region).to eq('us-east-1')
      expect(config.base_url).to eq('https://sellingpartnerapi-na.amazon.com')
    end

    it 'sets timeouts and no credentials' do
      expect(config.timeout).to eq(60)
      expect(config.open_timeout).to eq(10)
      expect(config.client_id).to be_nil
      expect(config.client_secret).to be_nil
    end

    it 'names the gem and Ruby in the user agent' do
      expect(config.user_agent).to eq(
        "amazon_sp_clients/#{AmazonSpClients::VERSION} (Language=Ruby/#{RUBY_VERSION})"
      )
    end

    it 'falls back to the default user agent when given nil' do
      expect(described_class.new(user_agent: nil).user_agent).to eq(config.user_agent)
    end
  end

  describe 'endpoint' do
    {
      'eu' => ['eu-west-1', 'sellingpartnerapi-eu.amazon.com'],
      'fe' => ['us-west-2', 'sellingpartnerapi-fe.amazon.com'],
      'de' => ['eu-west-1', 'sellingpartnerapi-eu.amazon.com'],
      'jp' => ['us-west-2', 'sellingpartnerapi-fe.amazon.com'],
      'us' => ['us-east-1', 'sellingpartnerapi-na.amazon.com']
    }.each do |code, (region, host)|
      it "maps #{code} to #{region}" do
        config = described_class.new(endpoint: code)

        expect(config.region).to eq(region)
        expect(config.base_url).to eq("https://#{host}")
      end
    end

    it 'rejects an unknown code' do
      expect { described_class.new(endpoint: 'zz') }
        .to raise_error(ArgumentError, /unknown endpoint "zz"/)
    end
  end

  it 'prefixes the host in sandbox mode' do
    config = described_class.new(endpoint: 'eu', sandbox: true)

    expect(config.base_url).to eq('https://sandbox.sellingpartnerapi-eu.amazon.com')
  end

  it 'is frozen and builds variants with #with' do
    config = described_class.new(client_id: 'ID')
    variant = config.with(sandbox: true)

    expect(config).to be_frozen
    expect(config.sandbox).to be(false)
    expect(variant.sandbox).to be(true)
    expect(variant.client_id).to eq('ID')
  end

  it 'rejects unknown settings' do
    expect { described_class.new(region: 'us-east-1') }.to raise_error(ArgumentError)
  end
end
