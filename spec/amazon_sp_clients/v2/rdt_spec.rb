require 'spec_helper'
require 'amazon_sp_clients/v2'

RSpec.describe AmazonSpClients::V2::RDT do
  v2 = AmazonSpClients::V2

  let(:now) { Time.utc(2026, 9, 3, 12, 0, 0) }

  before { Timecop.freeze(now) }

  def token(value, expires_in: 3600)
    AmazonSpClients::V2::Token.new(access_token: value, token_type: nil, expires_in: expires_in,
                                   expires_at: Time.now.utc + expires_in, refresh_token: nil)
  end

  describe '.resource' do
    it 'builds a frozen value object' do
      resource = described_class.resource('GET', '/reports/2021-06-30/documents/DOC1')

      expect(resource).to be_frozen
      expect(resource.http_method).to eq('GET')
      expect(resource.path).to eq('/reports/2021-06-30/documents/DOC1')
      expect(resource.data_elements).to be_nil
    end

    it 'compares by value' do
      a = described_class.resource('GET', '/x', %w[buyerInfo])
      b = described_class.resource('GET', '/x', %w[buyerInfo])

      expect(a).to eq(b)
      expect(a.hash).to eq(b.hash)
    end

    it 'renders the Tokens API shape, leaving out empty data elements' do
      expect(described_class.resource('GET', '/x', %w[buyerInfo]).to_request)
        .to eq(method: 'GET', path: '/x', dataElements: %w[buyerInfo])
      expect(described_class.resource('GET', '/x').to_request).to eq(method: 'GET', path: '/x')
    end
  end

  describe 'presets' do
    it 'match the v1 RESTRICTED_OPS' do
      expect(described_class::ORDERS.map(&:to_request)).to eq(
        [{ method: 'GET', path: '/orders/v0/orders', dataElements: %w[buyerInfo shippingAddress] }]
      )
      expect(described_class::ORDERS_AND_ITEMS.map(&:to_request)).to eq(
        [
          { method: 'GET', path: '/orders/v0/orders', dataElements: %w[buyerInfo shippingAddress] },
          { method: 'GET', path: '/orders/v0/orders/{orderId}/orderItems',
            dataElements: %w[buyerInfo] }
        ]
      )
    end

    it 'are frozen' do
      expect(described_class::ORDERS).to be_frozen
      expect(described_class::ORDERS_AND_ITEMS).to be_frozen
    end
  end

  describe described_class::Cache do
    let(:cache) { described_class.new }
    let(:orders) { v2::RDT::ORDERS }

    it 'fetches once and reuses the token while it is fresh' do
      fetches = 0

      first = cache.fetch(orders) do
        fetches += 1
        token('RDT1')
      end
      second = cache.fetch(orders) do
        fetches += 1
        token('RDT2')
      end

      expect([first, second]).to eq(%w[RDT1 RDT1])
      expect(fetches).to eq(1)
    end

    it 'keys by value, so equal resource lists share an entry' do
      cache.fetch([v2::RDT.resource('GET', '/reports/2021-06-30/documents/D1')]) { token('RDT1') }

      value = cache.fetch([v2::RDT.resource('GET', '/reports/2021-06-30/documents/D1')]) do
        token('RDT2')
      end

      expect(value).to eq('RDT1')
    end

    it 'leaves the caller\'s resource array unfrozen' do
      resources = [v2::RDT.resource('GET', '/documents/D1')]

      cache.fetch(resources) { token('RDT1') }

      expect(resources).not_to be_frozen
    end

    it 'keeps separate tokens for different resource lists' do
      cache.fetch(orders) { token('RDT1') }

      value = cache.fetch(v2::RDT::ORDERS_AND_ITEMS) { token('RDT2') }

      expect(value).to eq('RDT2')
    end

    it 'fetches again once the token counts as expired' do
      cache.fetch(orders) { token('RDT1') }
      Timecop.freeze(now + 3600 - 60)

      expect(cache.fetch(orders) { token('RDT2') }).to eq('RDT2')
    end

    it 'drops expired entries on a miss' do
      cache.fetch([v2::RDT.resource('GET', '/documents/D1')]) { token('RDT1', expires_in: 100) }
      Timecop.freeze(now + 200)

      cache.fetch([v2::RDT.resource('GET', '/documents/D2')]) { token('RDT2') }

      expect(cache.size).to eq(1)
    end

    it 'fetches once when many threads miss at the same time' do
      fetches = 0
      lock = Mutex.new

      values = Array.new(6) do
        Thread.new do
          cache.fetch(orders) do
            lock.synchronize { fetches += 1 }
            sleep(0.02)
            token('RDT1')
          end
        end
      end.map(&:value)

      expect(fetches).to eq(1)
      expect(values.uniq).to eq(['RDT1'])
    end
  end
end
