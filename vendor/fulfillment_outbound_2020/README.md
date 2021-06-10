# sp_fulfillment_outbound_2020

SpFulfillmentOutbound2020 - the Ruby gem for the Selling Partner APIs for Fulfillment Outbound

The Selling Partner API for Fulfillment Outbound lets you create applications that help a seller fulfill Multi-Channel Fulfillment orders using their inventory in Amazon's fulfillment network. You can get information on both potential and existing fulfillment orders.

This SDK is automatically generated by the [Swagger Codegen](https://github.com/swagger-api/swagger-codegen) project:

- API version: 2020-07-01
- Package version: 1.0.0
- Build package: io.swagger.codegen.v3.generators.ruby.RubyClientCodegen
For more information, please visit [https://sellercentral.amazon.com/gp/mws/contactus.html](https://sellercentral.amazon.com/gp/mws/contactus.html)

## Installation

### Build a gem

To build the Ruby code into a gem:

```shell
gem build sp_fulfillment_outbound_2020.gemspec
```

Then either install the gem locally:

```shell
gem install ./sp_fulfillment_outbound_2020-1.0.0.gem
```
(for development, run `gem install --dev ./sp_fulfillment_outbound_2020-1.0.0.gem` to install the development dependencies)

or publish the gem to a gem hosting service, e.g. [RubyGems](https://rubygems.org/).

Finally add this to the Gemfile:

    gem 'sp_fulfillment_outbound_2020', '~> 1.0.0'

### Install from Git

If the Ruby gem is hosted at a git repository: https://github.com/GIT_USER_ID/GIT_REPO_ID, then add the following in the Gemfile:

    gem 'sp_fulfillment_outbound_2020', :git => 'https://github.com/GIT_USER_ID/GIT_REPO_ID.git'

### Include the Ruby code directly

Include the Ruby code directly using `-I` as follows:

```shell
ruby -Ilib script.rb
```

## Getting Started

Please follow the [installation](#installation) procedure and then run the following code:
```ruby
# Load the gem
require 'sp_fulfillment_outbound_2020'

api_instance = SpFulfillmentOutbound2020::FbaOutboundApi.new
seller_fulfillment_order_id = 'seller_fulfillment_order_id_example' # String | The identifier assigned to the item by the seller when the fulfillment order was created.


begin
  result = api_instance.cancel_fulfillment_order(seller_fulfillment_order_id)
  p result
rescue SpFulfillmentOutbound2020::ApiError => e
  puts "Exception when calling FbaOutboundApi->cancel_fulfillment_order: #{e}"
end

api_instance = SpFulfillmentOutbound2020::FbaOutboundApi.new
body = SpFulfillmentOutbound2020::CreateFulfillmentOrderRequest.new # CreateFulfillmentOrderRequest | 


begin
  result = api_instance.create_fulfillment_order(body)
  p result
rescue SpFulfillmentOutbound2020::ApiError => e
  puts "Exception when calling FbaOutboundApi->create_fulfillment_order: #{e}"
end

api_instance = SpFulfillmentOutbound2020::FbaOutboundApi.new
body = SpFulfillmentOutbound2020::CreateFulfillmentReturnRequest.new # CreateFulfillmentReturnRequest | 
seller_fulfillment_order_id = 'seller_fulfillment_order_id_example' # String | An identifier assigned by the seller to the fulfillment order at the time it was created. The seller uses their own records to find the correct SellerFulfillmentOrderId value based on the buyer's request to return items.


begin
  result = api_instance.create_fulfillment_return(body, seller_fulfillment_order_id)
  p result
rescue SpFulfillmentOutbound2020::ApiError => e
  puts "Exception when calling FbaOutboundApi->create_fulfillment_return: #{e}"
end

api_instance = SpFulfillmentOutbound2020::FbaOutboundApi.new
marketplace_id = 'marketplace_id_example' # String | The marketplace for which to return a list of the inventory that is eligible for the specified feature.
feature_name = 'feature_name_example' # String | The name of the feature for which to return a list of eligible inventory.
opts = { 
  next_token: 'next_token_example' # String | A string token returned in the response to your previous request that is used to return the next response page. A value of null will return the first page.
}

begin
  result = api_instance.get_feature_inventory(marketplace_id, feature_name, opts)
  p result
rescue SpFulfillmentOutbound2020::ApiError => e
  puts "Exception when calling FbaOutboundApi->get_feature_inventory: #{e}"
end

api_instance = SpFulfillmentOutbound2020::FbaOutboundApi.new
marketplace_id = 'marketplace_id_example' # String | The marketplace for which to return the count.
feature_name = 'feature_name_example' # String | The name of the feature.
seller_sku = 'seller_sku_example' # String | Used to identify an item in the given marketplace. SellerSKU is qualified by the seller's SellerId, which is included with every operation that you submit.


begin
  result = api_instance.get_feature_sku(marketplace_id, feature_name, seller_sku)
  p result
rescue SpFulfillmentOutbound2020::ApiError => e
  puts "Exception when calling FbaOutboundApi->get_feature_sku: #{e}"
end

api_instance = SpFulfillmentOutbound2020::FbaOutboundApi.new
marketplace_id = 'marketplace_id_example' # String | The marketplace for which to return the list of features.


begin
  result = api_instance.get_features(marketplace_id)
  p result
rescue SpFulfillmentOutbound2020::ApiError => e
  puts "Exception when calling FbaOutboundApi->get_features: #{e}"
end

api_instance = SpFulfillmentOutbound2020::FbaOutboundApi.new
seller_fulfillment_order_id = 'seller_fulfillment_order_id_example' # String | The identifier assigned to the item by the seller when the fulfillment order was created.


begin
  result = api_instance.get_fulfillment_order(seller_fulfillment_order_id)
  p result
rescue SpFulfillmentOutbound2020::ApiError => e
  puts "Exception when calling FbaOutboundApi->get_fulfillment_order: #{e}"
end

api_instance = SpFulfillmentOutbound2020::FbaOutboundApi.new
body = SpFulfillmentOutbound2020::GetFulfillmentPreviewRequest.new # GetFulfillmentPreviewRequest | 


begin
  result = api_instance.get_fulfillment_preview(body)
  p result
rescue SpFulfillmentOutbound2020::ApiError => e
  puts "Exception when calling FbaOutboundApi->get_fulfillment_preview: #{e}"
end

api_instance = SpFulfillmentOutbound2020::FbaOutboundApi.new
package_number = 56 # Integer | The unencrypted package identifier returned by the getFulfillmentOrder operation.


begin
  result = api_instance.get_package_tracking_details(package_number)
  p result
rescue SpFulfillmentOutbound2020::ApiError => e
  puts "Exception when calling FbaOutboundApi->get_package_tracking_details: #{e}"
end

api_instance = SpFulfillmentOutbound2020::FbaOutboundApi.new
opts = { 
  query_start_date: DateTime.parse('2013-10-20T19:20:30+01:00'), # DateTime | A date used to select fulfillment orders that were last updated after (or at) a specified time. An update is defined as any change in fulfillment order status, including the creation of a new fulfillment order.
  next_token: 'next_token_example' # String | A string token returned in the response to your previous request.
}

begin
  result = api_instance.list_all_fulfillment_orders(opts)
  p result
rescue SpFulfillmentOutbound2020::ApiError => e
  puts "Exception when calling FbaOutboundApi->list_all_fulfillment_orders: #{e}"
end

api_instance = SpFulfillmentOutbound2020::FbaOutboundApi.new
seller_sku = 'seller_sku_example' # String | The seller SKU for which return reason codes are required.
language = 'language_example' # String | The language that the TranslatedDescription property of the ReasonCodeDetails response object should be translated into.
opts = { 
  marketplace_id: 'marketplace_id_example', # String | The marketplace for which the seller wants return reason codes.
  seller_fulfillment_order_id: 'seller_fulfillment_order_id_example' # String | The identifier assigned to the item by the seller when the fulfillment order was created. The service uses this value to determine the marketplace for which the seller wants return reason codes.
}

begin
  result = api_instance.list_return_reason_codes(seller_sku, language, opts)
  p result
rescue SpFulfillmentOutbound2020::ApiError => e
  puts "Exception when calling FbaOutboundApi->list_return_reason_codes: #{e}"
end

api_instance = SpFulfillmentOutbound2020::FbaOutboundApi.new
body = SpFulfillmentOutbound2020::UpdateFulfillmentOrderRequest.new # UpdateFulfillmentOrderRequest | 
seller_fulfillment_order_id = 'seller_fulfillment_order_id_example' # String | The identifier assigned to the item by the seller when the fulfillment order was created.


begin
  result = api_instance.update_fulfillment_order(body, seller_fulfillment_order_id)
  p result
rescue SpFulfillmentOutbound2020::ApiError => e
  puts "Exception when calling FbaOutboundApi->update_fulfillment_order: #{e}"
end
```

## Documentation for API Endpoints

All URIs are relative to *https://sellingpartnerapi-na.amazon.com/*

Class | Method | HTTP request | Description
------------ | ------------- | ------------- | -------------
*SpFulfillmentOutbound2020::FbaOutboundApi* | [**cancel_fulfillment_order**](docs/FbaOutboundApi.md#cancel_fulfillment_order) | **PUT** /fba/outbound/2020-07-01/fulfillmentOrders/{sellerFulfillmentOrderId}/cancel | 
*SpFulfillmentOutbound2020::FbaOutboundApi* | [**create_fulfillment_order**](docs/FbaOutboundApi.md#create_fulfillment_order) | **POST** /fba/outbound/2020-07-01/fulfillmentOrders | 
*SpFulfillmentOutbound2020::FbaOutboundApi* | [**create_fulfillment_return**](docs/FbaOutboundApi.md#create_fulfillment_return) | **PUT** /fba/outbound/2020-07-01/fulfillmentOrders/{sellerFulfillmentOrderId}/return | 
*SpFulfillmentOutbound2020::FbaOutboundApi* | [**get_feature_inventory**](docs/FbaOutboundApi.md#get_feature_inventory) | **GET** /fba/outbound/2020-07-01/features/inventory/{featureName} | 
*SpFulfillmentOutbound2020::FbaOutboundApi* | [**get_feature_sku**](docs/FbaOutboundApi.md#get_feature_sku) | **GET** /fba/outbound/2020-07-01/features/inventory/{featureName}/{sellerSku} | 
*SpFulfillmentOutbound2020::FbaOutboundApi* | [**get_features**](docs/FbaOutboundApi.md#get_features) | **GET** /fba/outbound/2020-07-01/features | 
*SpFulfillmentOutbound2020::FbaOutboundApi* | [**get_fulfillment_order**](docs/FbaOutboundApi.md#get_fulfillment_order) | **GET** /fba/outbound/2020-07-01/fulfillmentOrders/{sellerFulfillmentOrderId} | 
*SpFulfillmentOutbound2020::FbaOutboundApi* | [**get_fulfillment_preview**](docs/FbaOutboundApi.md#get_fulfillment_preview) | **POST** /fba/outbound/2020-07-01/fulfillmentOrders/preview | 
*SpFulfillmentOutbound2020::FbaOutboundApi* | [**get_package_tracking_details**](docs/FbaOutboundApi.md#get_package_tracking_details) | **GET** /fba/outbound/2020-07-01/tracking | 
*SpFulfillmentOutbound2020::FbaOutboundApi* | [**list_all_fulfillment_orders**](docs/FbaOutboundApi.md#list_all_fulfillment_orders) | **GET** /fba/outbound/2020-07-01/fulfillmentOrders | 
*SpFulfillmentOutbound2020::FbaOutboundApi* | [**list_return_reason_codes**](docs/FbaOutboundApi.md#list_return_reason_codes) | **GET** /fba/outbound/2020-07-01/returnReasonCodes | 
*SpFulfillmentOutbound2020::FbaOutboundApi* | [**update_fulfillment_order**](docs/FbaOutboundApi.md#update_fulfillment_order) | **PUT** /fba/outbound/2020-07-01/fulfillmentOrders/{sellerFulfillmentOrderId} | 

## Documentation for Models

 - [SpFulfillmentOutbound2020::AdditionalLocationInfo](docs/AdditionalLocationInfo.md)
 - [SpFulfillmentOutbound2020::Address](docs/Address.md)
 - [SpFulfillmentOutbound2020::CODSettings](docs/CODSettings.md)
 - [SpFulfillmentOutbound2020::CancelFulfillmentOrderResponse](docs/CancelFulfillmentOrderResponse.md)
 - [SpFulfillmentOutbound2020::CreateFulfillmentOrderItem](docs/CreateFulfillmentOrderItem.md)
 - [SpFulfillmentOutbound2020::CreateFulfillmentOrderItemList](docs/CreateFulfillmentOrderItemList.md)
 - [SpFulfillmentOutbound2020::CreateFulfillmentOrderRequest](docs/CreateFulfillmentOrderRequest.md)
 - [SpFulfillmentOutbound2020::CreateFulfillmentOrderResponse](docs/CreateFulfillmentOrderResponse.md)
 - [SpFulfillmentOutbound2020::CreateFulfillmentReturnRequest](docs/CreateFulfillmentReturnRequest.md)
 - [SpFulfillmentOutbound2020::CreateFulfillmentReturnResponse](docs/CreateFulfillmentReturnResponse.md)
 - [SpFulfillmentOutbound2020::CreateFulfillmentReturnResult](docs/CreateFulfillmentReturnResult.md)
 - [SpFulfillmentOutbound2020::CreateReturnItem](docs/CreateReturnItem.md)
 - [SpFulfillmentOutbound2020::CreateReturnItemList](docs/CreateReturnItemList.md)
 - [SpFulfillmentOutbound2020::CurrentStatus](docs/CurrentStatus.md)
 - [SpFulfillmentOutbound2020::Decimal](docs/Decimal.md)
 - [SpFulfillmentOutbound2020::DeliveryWindow](docs/DeliveryWindow.md)
 - [SpFulfillmentOutbound2020::DeliveryWindowList](docs/DeliveryWindowList.md)
 - [SpFulfillmentOutbound2020::Error](docs/Error.md)
 - [SpFulfillmentOutbound2020::ErrorList](docs/ErrorList.md)
 - [SpFulfillmentOutbound2020::EventCode](docs/EventCode.md)
 - [SpFulfillmentOutbound2020::Feature](docs/Feature.md)
 - [SpFulfillmentOutbound2020::FeatureSettings](docs/FeatureSettings.md)
 - [SpFulfillmentOutbound2020::FeatureSku](docs/FeatureSku.md)
 - [SpFulfillmentOutbound2020::Features](docs/Features.md)
 - [SpFulfillmentOutbound2020::Fee](docs/Fee.md)
 - [SpFulfillmentOutbound2020::FeeList](docs/FeeList.md)
 - [SpFulfillmentOutbound2020::FulfillmentAction](docs/FulfillmentAction.md)
 - [SpFulfillmentOutbound2020::FulfillmentOrder](docs/FulfillmentOrder.md)
 - [SpFulfillmentOutbound2020::FulfillmentOrderItem](docs/FulfillmentOrderItem.md)
 - [SpFulfillmentOutbound2020::FulfillmentOrderItemList](docs/FulfillmentOrderItemList.md)
 - [SpFulfillmentOutbound2020::FulfillmentOrderStatus](docs/FulfillmentOrderStatus.md)
 - [SpFulfillmentOutbound2020::FulfillmentPolicy](docs/FulfillmentPolicy.md)
 - [SpFulfillmentOutbound2020::FulfillmentPreview](docs/FulfillmentPreview.md)
 - [SpFulfillmentOutbound2020::FulfillmentPreviewItem](docs/FulfillmentPreviewItem.md)
 - [SpFulfillmentOutbound2020::FulfillmentPreviewItemList](docs/FulfillmentPreviewItemList.md)
 - [SpFulfillmentOutbound2020::FulfillmentPreviewList](docs/FulfillmentPreviewList.md)
 - [SpFulfillmentOutbound2020::FulfillmentPreviewShipment](docs/FulfillmentPreviewShipment.md)
 - [SpFulfillmentOutbound2020::FulfillmentPreviewShipmentList](docs/FulfillmentPreviewShipmentList.md)
 - [SpFulfillmentOutbound2020::FulfillmentReturnItemStatus](docs/FulfillmentReturnItemStatus.md)
 - [SpFulfillmentOutbound2020::FulfillmentShipment](docs/FulfillmentShipment.md)
 - [SpFulfillmentOutbound2020::FulfillmentShipmentItem](docs/FulfillmentShipmentItem.md)
 - [SpFulfillmentOutbound2020::FulfillmentShipmentItemList](docs/FulfillmentShipmentItemList.md)
 - [SpFulfillmentOutbound2020::FulfillmentShipmentList](docs/FulfillmentShipmentList.md)
 - [SpFulfillmentOutbound2020::FulfillmentShipmentPackage](docs/FulfillmentShipmentPackage.md)
 - [SpFulfillmentOutbound2020::FulfillmentShipmentPackageList](docs/FulfillmentShipmentPackageList.md)
 - [SpFulfillmentOutbound2020::GetFeatureInventoryResponse](docs/GetFeatureInventoryResponse.md)
 - [SpFulfillmentOutbound2020::GetFeatureInventoryResult](docs/GetFeatureInventoryResult.md)
 - [SpFulfillmentOutbound2020::GetFeatureSkuResponse](docs/GetFeatureSkuResponse.md)
 - [SpFulfillmentOutbound2020::GetFeatureSkuResult](docs/GetFeatureSkuResult.md)
 - [SpFulfillmentOutbound2020::GetFeaturesResponse](docs/GetFeaturesResponse.md)
 - [SpFulfillmentOutbound2020::GetFeaturesResult](docs/GetFeaturesResult.md)
 - [SpFulfillmentOutbound2020::GetFulfillmentOrderResponse](docs/GetFulfillmentOrderResponse.md)
 - [SpFulfillmentOutbound2020::GetFulfillmentOrderResult](docs/GetFulfillmentOrderResult.md)
 - [SpFulfillmentOutbound2020::GetFulfillmentPreviewItem](docs/GetFulfillmentPreviewItem.md)
 - [SpFulfillmentOutbound2020::GetFulfillmentPreviewItemList](docs/GetFulfillmentPreviewItemList.md)
 - [SpFulfillmentOutbound2020::GetFulfillmentPreviewRequest](docs/GetFulfillmentPreviewRequest.md)
 - [SpFulfillmentOutbound2020::GetFulfillmentPreviewResponse](docs/GetFulfillmentPreviewResponse.md)
 - [SpFulfillmentOutbound2020::GetFulfillmentPreviewResult](docs/GetFulfillmentPreviewResult.md)
 - [SpFulfillmentOutbound2020::GetPackageTrackingDetailsResponse](docs/GetPackageTrackingDetailsResponse.md)
 - [SpFulfillmentOutbound2020::InvalidItemReason](docs/InvalidItemReason.md)
 - [SpFulfillmentOutbound2020::InvalidItemReasonCode](docs/InvalidItemReasonCode.md)
 - [SpFulfillmentOutbound2020::InvalidReturnItem](docs/InvalidReturnItem.md)
 - [SpFulfillmentOutbound2020::InvalidReturnItemList](docs/InvalidReturnItemList.md)
 - [SpFulfillmentOutbound2020::ListAllFulfillmentOrdersResponse](docs/ListAllFulfillmentOrdersResponse.md)
 - [SpFulfillmentOutbound2020::ListAllFulfillmentOrdersResult](docs/ListAllFulfillmentOrdersResult.md)
 - [SpFulfillmentOutbound2020::ListReturnReasonCodesResponse](docs/ListReturnReasonCodesResponse.md)
 - [SpFulfillmentOutbound2020::ListReturnReasonCodesResult](docs/ListReturnReasonCodesResult.md)
 - [SpFulfillmentOutbound2020::Money](docs/Money.md)
 - [SpFulfillmentOutbound2020::NotificationEmailList](docs/NotificationEmailList.md)
 - [SpFulfillmentOutbound2020::PackageTrackingDetails](docs/PackageTrackingDetails.md)
 - [SpFulfillmentOutbound2020::Quantity](docs/Quantity.md)
 - [SpFulfillmentOutbound2020::ReasonCodeDetails](docs/ReasonCodeDetails.md)
 - [SpFulfillmentOutbound2020::ReasonCodeDetailsList](docs/ReasonCodeDetailsList.md)
 - [SpFulfillmentOutbound2020::ReturnAuthorization](docs/ReturnAuthorization.md)
 - [SpFulfillmentOutbound2020::ReturnAuthorizationList](docs/ReturnAuthorizationList.md)
 - [SpFulfillmentOutbound2020::ReturnItem](docs/ReturnItem.md)
 - [SpFulfillmentOutbound2020::ReturnItemDisposition](docs/ReturnItemDisposition.md)
 - [SpFulfillmentOutbound2020::ReturnItemList](docs/ReturnItemList.md)
 - [SpFulfillmentOutbound2020::ScheduledDeliveryInfo](docs/ScheduledDeliveryInfo.md)
 - [SpFulfillmentOutbound2020::ShippingSpeedCategory](docs/ShippingSpeedCategory.md)
 - [SpFulfillmentOutbound2020::ShippingSpeedCategoryList](docs/ShippingSpeedCategoryList.md)
 - [SpFulfillmentOutbound2020::StringList](docs/StringList.md)
 - [SpFulfillmentOutbound2020::Timestamp](docs/Timestamp.md)
 - [SpFulfillmentOutbound2020::TrackingAddress](docs/TrackingAddress.md)
 - [SpFulfillmentOutbound2020::TrackingEvent](docs/TrackingEvent.md)
 - [SpFulfillmentOutbound2020::TrackingEventList](docs/TrackingEventList.md)
 - [SpFulfillmentOutbound2020::UnfulfillablePreviewItem](docs/UnfulfillablePreviewItem.md)
 - [SpFulfillmentOutbound2020::UnfulfillablePreviewItemList](docs/UnfulfillablePreviewItemList.md)
 - [SpFulfillmentOutbound2020::UpdateFulfillmentOrderItem](docs/UpdateFulfillmentOrderItem.md)
 - [SpFulfillmentOutbound2020::UpdateFulfillmentOrderItemList](docs/UpdateFulfillmentOrderItemList.md)
 - [SpFulfillmentOutbound2020::UpdateFulfillmentOrderRequest](docs/UpdateFulfillmentOrderRequest.md)
 - [SpFulfillmentOutbound2020::UpdateFulfillmentOrderResponse](docs/UpdateFulfillmentOrderResponse.md)
 - [SpFulfillmentOutbound2020::Weight](docs/Weight.md)

## Documentation for Authorization

 All endpoints do not require authorization.
