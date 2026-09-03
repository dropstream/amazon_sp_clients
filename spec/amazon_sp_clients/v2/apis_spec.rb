require 'spec_helper'
require 'amazon_sp_clients/v2'

# The generated V2 API classes. Their contract: one class per module,
# reachable from the client, offering exactly the operations the v1
# module offers. Request shapes are checked on real generated methods.
RSpec.describe 'V2 API classes' do
  v2 = AmazonSpClients::V2

  modules = %w[
    fba_inventory feeds_2021 fulfillment_outbound_2020 listings_items_2021 orders_v0
    reports_2021 tokens_2021 vdf_inventory_v1 vdf_orders_v1 vdf_shipping_v1
    vendor_invoices vendor_orders vendor_transaction_status vendors_shipments
  ].freeze

  let(:base_url) { 'https://sellingpartnerapi-na.amazon.com' }
  let(:client) { v2::Client.new(v2::Config.new) { 'ACCESS' } }

  def camelize(name)
    name.split('_').map(&:capitalize).join
  end

  # Operation names of the v1 module: every generated method except the
  # _with_http_info twins and the api_client accessor.
  def v1_operations(name)
    require "amazon_sp_clients/sp_#{name}"
    v1_module = AmazonSpClients.const_get("Sp#{camelize(name)}")

    v1_module.constants.flat_map do |klass_name|
      v1_module.const_get(klass_name).public_instance_methods(false).map(&:to_s)
    end.grep_v(/_with_http_info\z|\Aapi_client/).sort
  end

  modules.each do |name|
    describe name do
      it 'is an Api subclass the client hands out' do
        klass = v2.const_get(camelize(name))

        expect(klass.superclass).to be(v2::Api)
        expect(client.public_send(name)).to be_a(klass)
        expect(client.public_send(name)).to be(client.public_send(name))
      end

      it 'offers the same operations as the v1 module' do
        klass = v2.const_get(camelize(name))

        expect(klass.public_instance_methods(false).map(&:to_s).sort).to eq(v1_operations(name))
      end
    end
  end

  it 'covers all 72 operations' do
    total = modules.sum { |name| v2.const_get(camelize(name)).public_instance_methods(false).size }

    expect(total).to eq(72)
  end

  describe 'request shapes' do
    it 'sends required and given query params, joins arrays, drops nils' do
      stub = stub_request(:get, "#{base_url}/orders/v0/orders")
             .with(query: { 'MarketplaceIds' => 'A,B', 'CreatedAfter' => '2026-09-01T00:00:00Z' })
             .to_return(status: 200, body: '{"payload":{"Orders":[]}}')

      response = client.orders_v0.get_orders(%w[A B], created_after: '2026-09-01T00:00:00Z',
                                                      next_token: nil)

      expect(stub).to have_been_requested
      expect(response.payload).to eq(Orders: [])
    end

    it 'sends false and an empty array as v1 did' do
      stub = stub_request(:get, "#{base_url}/fba/inventory/v1/summaries")
             .with(query: { 'granularityType' => 'Marketplace', 'granularityId' => 'M',
                            'marketplaceIds' => 'M', 'details' => 'false', 'sellerSkus' => '' })
             .to_return(status: 200, body: '{}')

      client.fba_inventory
            .get_inventory_summaries('Marketplace', 'M', ['M'], details: false, seller_skus: [])

      expect(stub).to have_been_requested
    end

    it 'encodes path params' do
      stub = stub_request(:get, "#{base_url}/orders/v0/orders/111-222%2F3")
             .to_return(status: 200, body: '{}')

      client.orders_v0.get_order('111-222/3')

      expect(stub).to have_been_requested
    end

    it 'sends header params and the JSON body' do
      stub = stub_request(:post, "#{base_url}/fba/inventory/v1/items/inventory")
             .with(body: '{"inventoryItems":[]}',
                   headers: { 'x-amzn-idempotency-token' => 'IDEMP' })
             .to_return(status: 200, body: '{}')

      client.fba_inventory.add_inventory({ inventoryItems: [] }, 'IDEMP')

      expect(stub).to have_been_requested
    end

    it 'returns an ApiResponse for an operation without a response body' do
      stub_request(:post, "#{base_url}/orders/v0/orders/1/shipmentConfirmation")
        .to_return(status: 204, body: '', headers: { 'x-amzn-RateLimit-Limit' => '2' })

      response = client.orders_v0.confirm_shipment({ packageDetail: {} }, '1')

      expect(response).to be_a(AmazonSpClients::ApiResponse)
      expect(response.reported_rate_limit).to eq(2.0)
    end

    it 'takes rdt on every operation' do
      tokens = stub_request(:post, "#{base_url}/tokens/2021-03-01/restrictedDataToken")
               .to_return(status: 200, body: '{"restrictedDataToken":"RDT","expiresIn":3600}')
      stub_request(:get, "#{base_url}/reports/2021-06-30/documents/D1")
        .with(headers: { 'x-amz-access-token' => 'RDT' })
        .to_return(status: 200, body: '{"url":"https://s3/doc"}')

      path = '/reports/2021-06-30/documents/D1'
      response = client.reports_2021.get_report_document('D1', rdt: [v2::RDT.resource('GET', path)])

      expect(tokens).to have_been_requested
      expect(response.payload).to eq(url: 'https://s3/doc')
    end

    it 'rejects option keys that are not parameters' do
      expect { client.orders_v0.get_orders(['A'], order_status: 'Shipped') }
        .to raise_error(ArgumentError, /order_status/)
    end
  end
end
