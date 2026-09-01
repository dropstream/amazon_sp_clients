require 'spec_helper'

RSpec.describe AmazonSpClients::Configuration do
  subject(:config) { described_class.new }

  describe 'defaults' do
    it 'uses the NA region' do
      expect(config.region).to eq('us-east-1')
    end

    it 'uses https' do
      expect(config.scheme).to eq('https')
    end

    it 'uses base path "/"' do
      expect(config.base_path).to eq('/')
    end

    it 'has a 60 second timeout' do
      expect(config.timeout).to eq(60)
    end

    it 'has no endpoint or marketplace id' do
      expect(config.endpoint).to be_nil
      expect(config.marketplace_id).to be_nil
    end

    it 'points host at the NA API' do
      expect(config.host).to eq('sellingpartnerapi-na.amazon.com')
    end
  end

  describe '.new with a block' do
    it 'yields the new config' do
      yielded = nil
      config = described_class.new { |c| yielded = c }

      expect(yielded).to be(config)
    end
  end

  describe '#configure' do
    it 'yields self' do
      yielded = nil
      config.configure { |c| yielded = c }

      expect(yielded).to be(config)
    end
  end

  describe '#region=' do
    it 'updates region and host together' do
      config.region = 'eu-west-1'

      expect(config.region).to eq('eu-west-1')
      expect(config.host).to eq('sellingpartnerapi-eu.amazon.com')
    end
  end

  describe 'sandbox mode' do
    it 'prefixes host with "sandbox."' do
      config.sandbox_env!

      expect(config.host).to eq('sandbox.sellingpartnerapi-na.amazon.com')
    end

    it 'prefixes base_url with "sandbox."' do
      config.sandbox_env!

      expect(config.base_url)
        .to eq('https://sandbox.sellingpartnerapi-na.amazon.com')
    end

    it 'returns to the plain host when disabled' do
      config.sandbox_env!
      config.disable_sandbox!

      expect(config.host).to eq('sellingpartnerapi-na.amazon.com')
      expect(config.base_url).to eq('https://sellingpartnerapi-na.amazon.com')
    end
  end

  describe '#set_endpoint_by_marketplace_id' do
    it 'sets up NA for the US marketplace' do
      config.set_endpoint_by_marketplace_id('ATVPDKIKX0DER')

      expect(config.marketplace_id).to eq('ATVPDKIKX0DER')
      expect(config.endpoint).to eq('na')
      expect(config.region).to eq('us-east-1')
      expect(config.host).to eq('sellingpartnerapi-na.amazon.com')
    end

    it 'sets up EU for the German marketplace' do
      config.set_endpoint_by_marketplace_id('A1PA6795UKMFR9')

      expect(config.marketplace_id).to eq('A1PA6795UKMFR9')
      expect(config.endpoint).to eq('eu')
      expect(config.region).to eq('eu-west-1')
      expect(config.host).to eq('sellingpartnerapi-eu.amazon.com')
    end

    it 'sets up FE for the Japanese marketplace' do
      config.set_endpoint_by_marketplace_id('A1VC38T7YXB528')

      expect(config.marketplace_id).to eq('A1VC38T7YXB528')
      expect(config.endpoint).to eq('fe')
      expect(config.region).to eq('us-west-2')
      expect(config.host).to eq('sellingpartnerapi-fe.amazon.com')
    end

    it 'keeps its state on an unknown marketplace id' do
      config.set_endpoint_by_marketplace_id('ATVPDKIKX0DER')

      expect { config.set_endpoint_by_marketplace_id('BOGUS') }
        .to raise_error(KeyError)

      expect(config.marketplace_id).to eq('ATVPDKIKX0DER')
      expect(config.endpoint).to eq('na')
      expect(config.region).to eq('us-east-1')
    end
  end

  describe '#endpoint=' do
    it 'keeps the given string' do
      config.endpoint = 'na'

      expect(config.endpoint).to eq('na')
    end

    it 'maps endpoint names to regions' do
      { 'na' => 'us-east-1', 'eu' => 'eu-west-1', 'fe' => 'us-west-2' }
        .each do |endpoint, region|
          config.endpoint = endpoint
          expect(config.region).to eq(region)
        end
    end

    it 'maps NA country codes to us-east-1' do
      %w[br ca mx us].each do |code|
        config.endpoint = code
        expect(config.region).to eq('us-east-1')
      end
    end

    it 'maps FE country codes to us-west-2' do
      %w[sg au jp].each do |code|
        config.endpoint = code
        expect(config.region).to eq('us-west-2')
      end
    end

    it 'maps EU country codes to eu-west-1' do
      %w[ae de eg es fr gb in it nl tr pl se].each do |code|
        config.endpoint = code
        expect(config.region).to eq('eu-west-1')
      end
    end

    it 'raises a clear error for an unknown endpoint' do
      expect { config.endpoint = 'zz' }
        .to raise_error(ArgumentError, 'unknown endpoint "zz"')
    end

    it 'keeps region and endpoint on an unknown endpoint' do
      config.endpoint = 'na'

      expect { config.endpoint = 'zz' }.to raise_error(ArgumentError)

      expect(config.region).to eq('us-east-1')
      expect(config.endpoint).to eq('na')
    end
  end

  # Consumers still set these at boot. They must stay writable (and
  # inert) until 2.0, or every cart raises NoMethodError on upgrade.
  describe 'deprecated AWS attrs' do
    it 'accepts writes without any effect' do
      config.access_key = 'AK'
      config.secret_key = 'SK'
      config.role_arn = 'arn:aws:iam::1:role/x'
      config.credentials_provider = Object.new

      expect(config.access_key).to eq('AK')
      expect(config.region).to eq('us-east-1')
      expect(config.host).to eq('sellingpartnerapi-na.amazon.com')
    end
  end

  describe '#scheme=' do
    it 'strips "://"' do
      config.scheme = 'http://'

      expect(config.scheme).to eq('http')
    end
  end

  describe '#base_path=' do
    it 'adds a leading slash' do
      config.base_path = 'v1'

      expect(config.base_path).to eq('/v1')
    end

    it 'collapses repeated slashes' do
      config.base_path = '//foo//bar'

      expect(config.base_path).to eq('/foo/bar')
    end

    it 'keeps a trailing slash' do
      config.base_path = 'v1/'

      expect(config.base_path).to eq('/v1/')
    end

    it 'becomes empty for "/"' do
      config.base_path = '/'

      expect(config.base_path).to eq('')
    end

    it 'becomes empty for ""' do
      config.base_path = ''

      expect(config.base_path).to eq('')
    end
  end

  describe '#base_url' do
    it 'has no trailing slash by default' do
      expect(config.base_url).to eq('https://sellingpartnerapi-na.amazon.com')
    end

    it 'joins scheme, host and base path' do
      config.base_path = 'v1'

      expect(config.base_url)
        .to eq('https://sellingpartnerapi-na.amazon.com/v1')
    end

    it 'drops the trailing slash of the base path' do
      config.base_path = 'v1/'

      expect(config.base_url)
        .to eq('https://sellingpartnerapi-na.amazon.com/v1')
    end

    it 'follows the region' do
      config.region = 'us-west-2'

      expect(config.base_url).to eq('https://sellingpartnerapi-fe.amazon.com')
    end
  end

  describe '.default' do
    after { Thread.current[:amazon_sp_configuration] = nil }

    it 'returns the same object in one thread' do
      expect(described_class.default).to be(described_class.default)
    end

    it 'gives each thread its own object' do
      main = described_class.default
      other = Thread.new { described_class.default }.value

      expect(other).to be_a(described_class)
      expect(other).not_to be(main)
    end
  end

  describe 'constants' do
    it 'maps each region to its API host' do
      expect(AmazonSpClients::REGIONS).to eq(
        'us-east-1' => 'sellingpartnerapi-na.amazon.com',
        'eu-west-1' => 'sellingpartnerapi-eu.amazon.com',
        'us-west-2' => 'sellingpartnerapi-fe.amazon.com'
      )
    end

    it 'lists marketplace ids by country' do
      expect(AmazonSpClients::MARKETPLACE_IDS[:us]).to eq('ATVPDKIKX0DER')
      expect(AmazonSpClients::MARKETPLACE_IDS[:de]).to eq('A1PA6795UKMFR9')
      expect(AmazonSpClients::MARKETPLACE_IDS[:jp]).to eq('A1VC38T7YXB528')
    end

    it 'keeps both marketplace constants in sync' do
      expect(AmazonSpClients::MARKETPLACE_IDS.values.sort)
        .to eq(AmazonSpClients::MARKETPLACE_ENDPOINT_MAP.keys.sort)
    end
  end
end
