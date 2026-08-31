require 'spec_helper'

# Phase 1 replaces the generator and rewrites vendor/ and every
# sp_*.rb shim. Consumers depend on these exact require paths and
# API class names; each API class takes a session and builds an
# ApiClient. Pin all of it before anything regenerates.
RSpec.describe 'sp_* module contract' do
  used_modules = {
    'amazon_sp_clients/sp_orders_v0' => %w[
      SpOrdersV0::OrdersV0Api
      SpOrdersV0::ShipmentApi
    ],
    'amazon_sp_clients/sp_tokens_2021' => %w[SpTokens2021::TokensApi],
    'amazon_sp_clients/sp_feeds_2021' => %w[SpFeeds2021::FeedsApi],
    'amazon_sp_clients/sp_reports_2021' => %w[SpReports2021::ReportsApi],
    'amazon_sp_clients/sp_listings_items_2021' => %w[SpListingsItems2021::ListingsApi],
    'amazon_sp_clients/sp_vdf_orders_v1' => %w[SpVdfOrdersV1::VendorOrdersApi],
    'amazon_sp_clients/sp_vdf_inventory_v1' => %w[SpVdfInventoryV1::UpdateInventoryApi],
    'amazon_sp_clients/sp_vdf_shipping_v1' => %w[
      SpVdfShippingV1::CustomerInvoicesApi
      SpVdfShippingV1::VendorShippingApi
      SpVdfShippingV1::VendorShippingLabelsApi
    ],
    'amazon_sp_clients/sp_vendor_orders' => %w[SpVendorOrders::VendorOrdersApi],
    'amazon_sp_clients/sp_vendor_invoices' => %w[SpVendorInvoices::VendorPaymentsApi],
    'amazon_sp_clients/sp_vendor_transaction_status' => %w[
      SpVendorTransactionStatus::VendorTransactionApi
    ],
    'amazon_sp_clients/sp_vendors_shipments' => %w[SpVendorsShipments::VendorShippingApi],
    'amazon_sp_clients/sp_fba_inventory' => %w[SpFbaInventory::FbaInventoryApi],
    'amazon_sp_clients/sp_fulfillment_outbound_2020' => %w[
      SpFulfillmentOutbound2020::FbaOutboundApi
    ]
  }

  # ApiClient.new reads the thread-local default config.
  after { Thread.current[:amazon_sp_configuration] = nil }

  used_modules.each do |path, api_classes|
    describe path do
      it 'loads and exposes its API classes' do
        require path

        api_classes.each do |name|
          klass = AmazonSpClients.const_get(name)
          api = klass.new(Object.new)

          expect(api.api_client).to be_a(AmazonSpClients::ApiClient)
        end
      end
    end
  end
end
