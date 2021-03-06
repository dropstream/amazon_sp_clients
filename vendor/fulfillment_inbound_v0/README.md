# sp_fulfillment_inbound_v0

SpFulfillmentInboundV0 - the Ruby gem for the Selling Partner API for Fulfillment Inbound

The Selling Partner API for Fulfillment Inbound lets you create applications that create and update inbound shipments of inventory to Amazon's fulfillment network.

This SDK is automatically generated by the [Swagger Codegen](https://github.com/swagger-api/swagger-codegen) project:

- API version: v0
- Package version: 1.0.0
- Build package: io.swagger.codegen.v3.generators.ruby.RubyClientCodegen
For more information, please visit [https://sellercentral.amazon.com/gp/mws/contactus.html](https://sellercentral.amazon.com/gp/mws/contactus.html)

## Installation

### Build a gem

To build the Ruby code into a gem:

```shell
gem build sp_fulfillment_inbound_v0.gemspec
```

Then either install the gem locally:

```shell
gem install ./sp_fulfillment_inbound_v0-1.0.0.gem
```
(for development, run `gem install --dev ./sp_fulfillment_inbound_v0-1.0.0.gem` to install the development dependencies)

or publish the gem to a gem hosting service, e.g. [RubyGems](https://rubygems.org/).

Finally add this to the Gemfile:

    gem 'sp_fulfillment_inbound_v0', '~> 1.0.0'

### Install from Git

If the Ruby gem is hosted at a git repository: https://github.com/GIT_USER_ID/GIT_REPO_ID, then add the following in the Gemfile:

    gem 'sp_fulfillment_inbound_v0', :git => 'https://github.com/GIT_USER_ID/GIT_REPO_ID.git'

### Include the Ruby code directly

Include the Ruby code directly using `-I` as follows:

```shell
ruby -Ilib script.rb
```

## Getting Started

Please follow the [installation](#installation) procedure and then run the following code:
```ruby
# Load the gem
require 'sp_fulfillment_inbound_v0'

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
shipment_id = 'shipment_id_example' # String | A shipment identifier originally returned by the createInboundShipmentPlan operation.
need_by_date = Date.parse('2013-10-20') # Date | Date that the shipment must arrive at the Amazon fulfillment center to avoid delivery promise breaks for pre-ordered items. Must be in YYYY-MM-DD format. The response to the getPreorderInfo operation returns this value.
marketplace_id = 'marketplace_id_example' # String | A marketplace identifier. Specifies the marketplace the shipment is tied to.


begin
  result = api_instance.confirm_preorder(shipment_id, need_by_date, marketplace_id)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->confirm_preorder: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
shipment_id = 'shipment_id_example' # String | A shipment identifier originally returned by the createInboundShipmentPlan operation.


begin
  result = api_instance.confirm_transport(shipment_id)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->confirm_transport: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
body = SpFulfillmentInboundV0::InboundShipmentRequest.new # InboundShipmentRequest | 
shipment_id = 'shipment_id_example' # String | A shipment identifier originally returned by the createInboundShipmentPlan operation.


begin
  result = api_instance.create_inbound_shipment(body, shipment_id)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->create_inbound_shipment: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
body = SpFulfillmentInboundV0::CreateInboundShipmentPlanRequest.new # CreateInboundShipmentPlanRequest | 


begin
  result = api_instance.create_inbound_shipment_plan(body)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->create_inbound_shipment_plan: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
shipment_id = 'shipment_id_example' # String | A shipment identifier originally returned by the createInboundShipmentPlan operation.


begin
  result = api_instance.estimate_transport(shipment_id)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->estimate_transport: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
shipment_id = 'shipment_id_example' # String | A shipment identifier originally returned by the createInboundShipmentPlan operation.


begin
  result = api_instance.get_bill_of_lading(shipment_id)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->get_bill_of_lading: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
marketplace_id = 'marketplace_id_example' # String | A marketplace identifier. Specifies the marketplace where the product would be stored.
opts = { 
  seller_sku_list: ['seller_sku_list_example'], # Array<String> | A list of SellerSKU values. Used to identify items for which you want inbound guidance for shipment to Amazon's fulfillment network. Note: SellerSKU is qualified by the SellerId, which is included with every Selling Partner API operation that you submit. If you specify a SellerSKU that identifies a variation parent ASIN, this operation returns an error. A variation parent ASIN represents a generic product that cannot be sold. Variation child ASINs represent products that have specific characteristics (such as size and color) and can be sold. 
  asin_list: ['asin_list_example'] # Array<String> | A list of ASIN values. Used to identify items for which you want inbound guidance for shipment to Amazon's fulfillment network. Note: If you specify a ASIN that identifies a variation parent ASIN, this operation returns an error. A variation parent ASIN represents a generic product that cannot be sold. Variation child ASINs represent products that have specific characteristics (such as size and color) and can be sold.
}

begin
  result = api_instance.get_inbound_guidance(marketplace_id, opts)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->get_inbound_guidance: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
shipment_id = 'shipment_id_example' # String | A shipment identifier originally returned by the createInboundShipmentPlan operation.
page_type = 'page_type_example' # String | The page type to use to print the labels. Submitting a PageType value that is not supported in your marketplace returns an error.
label_type = 'label_type_example' # String | The type of labels requested. 
opts = { 
  number_of_packages: 56, # Integer | The number of packages in the shipment.
  package_labels_to_print: ['package_labels_to_print_example'], # Array<String> | A list of identifiers that specify packages for which you want package labels printed.  Must match CartonId values previously passed using the FBA Inbound Shipment Carton Information Feed. If not, the operation returns the IncorrectPackageIdentifier error code.
  number_of_pallets: 56, # Integer | The number of pallets in the shipment. This returns four identical labels for each pallet.
  page_size: 56, # Integer | The page size for paginating through the total packages' labels. This is a required parameter for Non-Partnered LTL Shipments. Max value:1000.
  page_start_index: 56 # Integer | The page start index for paginating through the total packages' labels. This is a required parameter for Non-Partnered LTL Shipments.
}

begin
  result = api_instance.get_labels(shipment_id, page_type, label_type, opts)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->get_labels: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
shipment_id = 'shipment_id_example' # String | A shipment identifier originally returned by the createInboundShipmentPlan operation.
marketplace_id = 'marketplace_id_example' # String | A marketplace identifier. Specifies the marketplace the shipment is tied to.


begin
  result = api_instance.get_preorder_info(shipment_id, marketplace_id)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->get_preorder_info: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
ship_to_country_code = 'ship_to_country_code_example' # String | The country code of the country to which the items will be shipped. Note that labeling requirements and item preparation instructions can vary by country.
opts = { 
  seller_sku_list: ['seller_sku_list_example'], # Array<String> | A list of SellerSKU values. Used to identify items for which you want labeling requirements and item preparation instructions for shipment to Amazon's fulfillment network. The SellerSKU is qualified by the Seller ID, which is included with every call to the Seller Partner API.  Note: Include seller SKUs that you have used to list items on Amazon's retail website. If you include a seller SKU that you have never used to list an item on Amazon's retail website, the seller SKU is returned in the InvalidSKUList property in the response.
  asin_list: ['asin_list_example'] # Array<String> | A list of ASIN values. Used to identify items for which you want item preparation instructions to help with item sourcing decisions.  Note: ASINs must be included in the product catalog for at least one of the marketplaces that the seller  participates in. Any ASIN that is not included in the product catalog for at least one of the marketplaces that the seller participates in is returned in the InvalidASINList property in the response. You can find out which marketplaces a seller participates in by calling the getMarketplaceParticipations operation in the Selling Partner API for Sellers.
}

begin
  result = api_instance.get_prep_instructions(ship_to_country_code, opts)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->get_prep_instructions: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
query_type = 'query_type_example' # String | Indicates whether items are returned using a date range (by providing the LastUpdatedAfter and LastUpdatedBefore parameters), or using NextToken, which continues returning items specified in a previous request.
marketplace_id = 'marketplace_id_example' # String | A marketplace identifier. Specifies the marketplace where the product would be stored.
opts = { 
  last_updated_after: DateTime.parse('2013-10-20T19:20:30+01:00'), # DateTime | A date used for selecting inbound shipment items that were last updated after (or at) a specified time. The selection includes updates made by Amazon and by the seller.
  last_updated_before: DateTime.parse('2013-10-20T19:20:30+01:00'), # DateTime | A date used for selecting inbound shipment items that were last updated before (or at) a specified time. The selection includes updates made by Amazon and by the seller.
  next_token: 'next_token_example' # String | A string token returned in the response to your previous request.
}

begin
  result = api_instance.get_shipment_items(query_type, marketplace_id, opts)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->get_shipment_items: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
shipment_id = 'shipment_id_example' # String | A shipment identifier used for selecting items in a specific inbound shipment.
marketplace_id = 'marketplace_id_example' # String | A marketplace identifier. Specifies the marketplace where the product would be stored.


begin
  result = api_instance.get_shipment_items_by_shipment_id(shipment_id, marketplace_id)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->get_shipment_items_by_shipment_id: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
query_type = 'query_type_example' # String | Indicates whether shipments are returned using shipment information (by providing the ShipmentStatusList or ShipmentIdList parameters), using a date range (by providing the LastUpdatedAfter and LastUpdatedBefore parameters), or by using NextToken to continue returning items specified in a previous request.
marketplace_id = 'marketplace_id_example' # String | A marketplace identifier. Specifies the marketplace where the product would be stored.
opts = { 
  shipment_status_list: ['shipment_status_list_example'], # Array<String> | A list of ShipmentStatus values. Used to select shipments with a current status that matches the status values that you specify.
  shipment_id_list: ['shipment_id_list_example'], # Array<String> | A list of shipment IDs used to select the shipments that you want. If both ShipmentStatusList and ShipmentIdList are specified, only shipments that match both parameters are returned.
  last_updated_after: DateTime.parse('2013-10-20T19:20:30+01:00'), # DateTime | A date used for selecting inbound shipments that were last updated after (or at) a specified time. The selection includes updates made by Amazon and by the seller.
  last_updated_before: DateTime.parse('2013-10-20T19:20:30+01:00'), # DateTime | A date used for selecting inbound shipments that were last updated before (or at) a specified time. The selection includes updates made by Amazon and by the seller.
  next_token: 'next_token_example' # String | A string token returned in the response to your previous request.
}

begin
  result = api_instance.get_shipments(query_type, marketplace_id, opts)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->get_shipments: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
shipment_id = 'shipment_id_example' # String | A shipment identifier originally returned by the createInboundShipmentPlan operation.


begin
  result = api_instance.get_transport_details(shipment_id)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->get_transport_details: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
body = SpFulfillmentInboundV0::PutTransportDetailsRequest.new # PutTransportDetailsRequest | 
shipment_id = 'shipment_id_example' # String | A shipment identifier originally returned by the createInboundShipmentPlan operation.


begin
  result = api_instance.put_transport_details(body, shipment_id)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->put_transport_details: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
body = SpFulfillmentInboundV0::InboundShipmentRequest.new # InboundShipmentRequest | 
shipment_id = 'shipment_id_example' # String | A shipment identifier originally returned by the createInboundShipmentPlan operation.


begin
  result = api_instance.update_inbound_shipment(body, shipment_id)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->update_inbound_shipment: #{e}"
end

api_instance = SpFulfillmentInboundV0::FbaInboundApi.new
shipment_id = 'shipment_id_example' # String | A shipment identifier originally returned by the createInboundShipmentPlan operation.


begin
  result = api_instance.void_transport(shipment_id)
  p result
rescue SpFulfillmentInboundV0::ApiError => e
  puts "Exception when calling FbaInboundApi->void_transport: #{e}"
end
```

## Documentation for API Endpoints

All URIs are relative to *https://sellingpartnerapi-na.amazon.com/*

Class | Method | HTTP request | Description
------------ | ------------- | ------------- | -------------
*SpFulfillmentInboundV0::FbaInboundApi* | [**confirm_preorder**](docs/FbaInboundApi.md#confirm_preorder) | **PUT** /fba/inbound/v0/shipments/{shipmentId}/preorder/confirm | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**confirm_transport**](docs/FbaInboundApi.md#confirm_transport) | **POST** /fba/inbound/v0/shipments/{shipmentId}/transport/confirm | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**create_inbound_shipment**](docs/FbaInboundApi.md#create_inbound_shipment) | **POST** /fba/inbound/v0/shipments/{shipmentId} | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**create_inbound_shipment_plan**](docs/FbaInboundApi.md#create_inbound_shipment_plan) | **POST** /fba/inbound/v0/plans | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**estimate_transport**](docs/FbaInboundApi.md#estimate_transport) | **POST** /fba/inbound/v0/shipments/{shipmentId}/transport/estimate | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**get_bill_of_lading**](docs/FbaInboundApi.md#get_bill_of_lading) | **GET** /fba/inbound/v0/shipments/{shipmentId}/billOfLading | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**get_inbound_guidance**](docs/FbaInboundApi.md#get_inbound_guidance) | **GET** /fba/inbound/v0/itemsGuidance | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**get_labels**](docs/FbaInboundApi.md#get_labels) | **GET** /fba/inbound/v0/shipments/{shipmentId}/labels | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**get_preorder_info**](docs/FbaInboundApi.md#get_preorder_info) | **GET** /fba/inbound/v0/shipments/{shipmentId}/preorder | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**get_prep_instructions**](docs/FbaInboundApi.md#get_prep_instructions) | **GET** /fba/inbound/v0/prepInstructions | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**get_shipment_items**](docs/FbaInboundApi.md#get_shipment_items) | **GET** /fba/inbound/v0/shipmentItems | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**get_shipment_items_by_shipment_id**](docs/FbaInboundApi.md#get_shipment_items_by_shipment_id) | **GET** /fba/inbound/v0/shipments/{shipmentId}/items | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**get_shipments**](docs/FbaInboundApi.md#get_shipments) | **GET** /fba/inbound/v0/shipments | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**get_transport_details**](docs/FbaInboundApi.md#get_transport_details) | **GET** /fba/inbound/v0/shipments/{shipmentId}/transport | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**put_transport_details**](docs/FbaInboundApi.md#put_transport_details) | **PUT** /fba/inbound/v0/shipments/{shipmentId}/transport | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**update_inbound_shipment**](docs/FbaInboundApi.md#update_inbound_shipment) | **PUT** /fba/inbound/v0/shipments/{shipmentId} | 
*SpFulfillmentInboundV0::FbaInboundApi* | [**void_transport**](docs/FbaInboundApi.md#void_transport) | **POST** /fba/inbound/v0/shipments/{shipmentId}/transport/void | 

## Documentation for Models

 - [SpFulfillmentInboundV0::ASINInboundGuidance](docs/ASINInboundGuidance.md)
 - [SpFulfillmentInboundV0::ASINInboundGuidanceList](docs/ASINInboundGuidanceList.md)
 - [SpFulfillmentInboundV0::ASINPrepInstructions](docs/ASINPrepInstructions.md)
 - [SpFulfillmentInboundV0::ASINPrepInstructionsList](docs/ASINPrepInstructionsList.md)
 - [SpFulfillmentInboundV0::Address](docs/Address.md)
 - [SpFulfillmentInboundV0::AmazonPrepFeesDetails](docs/AmazonPrepFeesDetails.md)
 - [SpFulfillmentInboundV0::AmazonPrepFeesDetailsList](docs/AmazonPrepFeesDetailsList.md)
 - [SpFulfillmentInboundV0::Amount](docs/Amount.md)
 - [SpFulfillmentInboundV0::BarcodeInstruction](docs/BarcodeInstruction.md)
 - [SpFulfillmentInboundV0::BigDecimalType](docs/BigDecimalType.md)
 - [SpFulfillmentInboundV0::BillOfLadingDownloadURL](docs/BillOfLadingDownloadURL.md)
 - [SpFulfillmentInboundV0::BoxContentsFeeDetails](docs/BoxContentsFeeDetails.md)
 - [SpFulfillmentInboundV0::BoxContentsSource](docs/BoxContentsSource.md)
 - [SpFulfillmentInboundV0::CommonTransportResult](docs/CommonTransportResult.md)
 - [SpFulfillmentInboundV0::Condition](docs/Condition.md)
 - [SpFulfillmentInboundV0::ConfirmPreorderResponse](docs/ConfirmPreorderResponse.md)
 - [SpFulfillmentInboundV0::ConfirmPreorderResult](docs/ConfirmPreorderResult.md)
 - [SpFulfillmentInboundV0::ConfirmTransportResponse](docs/ConfirmTransportResponse.md)
 - [SpFulfillmentInboundV0::Contact](docs/Contact.md)
 - [SpFulfillmentInboundV0::CreateInboundShipmentPlanRequest](docs/CreateInboundShipmentPlanRequest.md)
 - [SpFulfillmentInboundV0::CreateInboundShipmentPlanResponse](docs/CreateInboundShipmentPlanResponse.md)
 - [SpFulfillmentInboundV0::CreateInboundShipmentPlanResult](docs/CreateInboundShipmentPlanResult.md)
 - [SpFulfillmentInboundV0::CurrencyCode](docs/CurrencyCode.md)
 - [SpFulfillmentInboundV0::DateStringType](docs/DateStringType.md)
 - [SpFulfillmentInboundV0::Dimensions](docs/Dimensions.md)
 - [SpFulfillmentInboundV0::Error](docs/Error.md)
 - [SpFulfillmentInboundV0::ErrorList](docs/ErrorList.md)
 - [SpFulfillmentInboundV0::ErrorReason](docs/ErrorReason.md)
 - [SpFulfillmentInboundV0::EstimateTransportResponse](docs/EstimateTransportResponse.md)
 - [SpFulfillmentInboundV0::GetBillOfLadingResponse](docs/GetBillOfLadingResponse.md)
 - [SpFulfillmentInboundV0::GetInboundGuidanceResponse](docs/GetInboundGuidanceResponse.md)
 - [SpFulfillmentInboundV0::GetInboundGuidanceResult](docs/GetInboundGuidanceResult.md)
 - [SpFulfillmentInboundV0::GetLabelsResponse](docs/GetLabelsResponse.md)
 - [SpFulfillmentInboundV0::GetPreorderInfoResponse](docs/GetPreorderInfoResponse.md)
 - [SpFulfillmentInboundV0::GetPreorderInfoResult](docs/GetPreorderInfoResult.md)
 - [SpFulfillmentInboundV0::GetPrepInstructionsResponse](docs/GetPrepInstructionsResponse.md)
 - [SpFulfillmentInboundV0::GetPrepInstructionsResult](docs/GetPrepInstructionsResult.md)
 - [SpFulfillmentInboundV0::GetShipmentItemsResponse](docs/GetShipmentItemsResponse.md)
 - [SpFulfillmentInboundV0::GetShipmentItemsResult](docs/GetShipmentItemsResult.md)
 - [SpFulfillmentInboundV0::GetShipmentsResponse](docs/GetShipmentsResponse.md)
 - [SpFulfillmentInboundV0::GetShipmentsResult](docs/GetShipmentsResult.md)
 - [SpFulfillmentInboundV0::GetTransportDetailsResponse](docs/GetTransportDetailsResponse.md)
 - [SpFulfillmentInboundV0::GetTransportDetailsResult](docs/GetTransportDetailsResult.md)
 - [SpFulfillmentInboundV0::GuidanceReason](docs/GuidanceReason.md)
 - [SpFulfillmentInboundV0::GuidanceReasonList](docs/GuidanceReasonList.md)
 - [SpFulfillmentInboundV0::InboundGuidance](docs/InboundGuidance.md)
 - [SpFulfillmentInboundV0::InboundShipmentHeader](docs/InboundShipmentHeader.md)
 - [SpFulfillmentInboundV0::InboundShipmentInfo](docs/InboundShipmentInfo.md)
 - [SpFulfillmentInboundV0::InboundShipmentItem](docs/InboundShipmentItem.md)
 - [SpFulfillmentInboundV0::InboundShipmentItemList](docs/InboundShipmentItemList.md)
 - [SpFulfillmentInboundV0::InboundShipmentList](docs/InboundShipmentList.md)
 - [SpFulfillmentInboundV0::InboundShipmentPlan](docs/InboundShipmentPlan.md)
 - [SpFulfillmentInboundV0::InboundShipmentPlanItem](docs/InboundShipmentPlanItem.md)
 - [SpFulfillmentInboundV0::InboundShipmentPlanItemList](docs/InboundShipmentPlanItemList.md)
 - [SpFulfillmentInboundV0::InboundShipmentPlanList](docs/InboundShipmentPlanList.md)
 - [SpFulfillmentInboundV0::InboundShipmentPlanRequestItem](docs/InboundShipmentPlanRequestItem.md)
 - [SpFulfillmentInboundV0::InboundShipmentPlanRequestItemList](docs/InboundShipmentPlanRequestItemList.md)
 - [SpFulfillmentInboundV0::InboundShipmentRequest](docs/InboundShipmentRequest.md)
 - [SpFulfillmentInboundV0::InboundShipmentResponse](docs/InboundShipmentResponse.md)
 - [SpFulfillmentInboundV0::InboundShipmentResult](docs/InboundShipmentResult.md)
 - [SpFulfillmentInboundV0::IntendedBoxContentsSource](docs/IntendedBoxContentsSource.md)
 - [SpFulfillmentInboundV0::InvalidASIN](docs/InvalidASIN.md)
 - [SpFulfillmentInboundV0::InvalidASINList](docs/InvalidASINList.md)
 - [SpFulfillmentInboundV0::InvalidSKU](docs/InvalidSKU.md)
 - [SpFulfillmentInboundV0::InvalidSKUList](docs/InvalidSKUList.md)
 - [SpFulfillmentInboundV0::LabelDownloadURL](docs/LabelDownloadURL.md)
 - [SpFulfillmentInboundV0::LabelPrepPreference](docs/LabelPrepPreference.md)
 - [SpFulfillmentInboundV0::LabelPrepType](docs/LabelPrepType.md)
 - [SpFulfillmentInboundV0::NonPartneredLtlDataInput](docs/NonPartneredLtlDataInput.md)
 - [SpFulfillmentInboundV0::NonPartneredLtlDataOutput](docs/NonPartneredLtlDataOutput.md)
 - [SpFulfillmentInboundV0::NonPartneredSmallParcelDataInput](docs/NonPartneredSmallParcelDataInput.md)
 - [SpFulfillmentInboundV0::NonPartneredSmallParcelDataOutput](docs/NonPartneredSmallParcelDataOutput.md)
 - [SpFulfillmentInboundV0::NonPartneredSmallParcelPackageInput](docs/NonPartneredSmallParcelPackageInput.md)
 - [SpFulfillmentInboundV0::NonPartneredSmallParcelPackageInputList](docs/NonPartneredSmallParcelPackageInputList.md)
 - [SpFulfillmentInboundV0::NonPartneredSmallParcelPackageOutput](docs/NonPartneredSmallParcelPackageOutput.md)
 - [SpFulfillmentInboundV0::NonPartneredSmallParcelPackageOutputList](docs/NonPartneredSmallParcelPackageOutputList.md)
 - [SpFulfillmentInboundV0::PackageStatus](docs/PackageStatus.md)
 - [SpFulfillmentInboundV0::Pallet](docs/Pallet.md)
 - [SpFulfillmentInboundV0::PalletList](docs/PalletList.md)
 - [SpFulfillmentInboundV0::PartneredEstimate](docs/PartneredEstimate.md)
 - [SpFulfillmentInboundV0::PartneredLtlDataInput](docs/PartneredLtlDataInput.md)
 - [SpFulfillmentInboundV0::PartneredLtlDataOutput](docs/PartneredLtlDataOutput.md)
 - [SpFulfillmentInboundV0::PartneredSmallParcelDataInput](docs/PartneredSmallParcelDataInput.md)
 - [SpFulfillmentInboundV0::PartneredSmallParcelDataOutput](docs/PartneredSmallParcelDataOutput.md)
 - [SpFulfillmentInboundV0::PartneredSmallParcelPackageInput](docs/PartneredSmallParcelPackageInput.md)
 - [SpFulfillmentInboundV0::PartneredSmallParcelPackageInputList](docs/PartneredSmallParcelPackageInputList.md)
 - [SpFulfillmentInboundV0::PartneredSmallParcelPackageOutput](docs/PartneredSmallParcelPackageOutput.md)
 - [SpFulfillmentInboundV0::PartneredSmallParcelPackageOutputList](docs/PartneredSmallParcelPackageOutputList.md)
 - [SpFulfillmentInboundV0::PrepDetails](docs/PrepDetails.md)
 - [SpFulfillmentInboundV0::PrepDetailsList](docs/PrepDetailsList.md)
 - [SpFulfillmentInboundV0::PrepGuidance](docs/PrepGuidance.md)
 - [SpFulfillmentInboundV0::PrepInstruction](docs/PrepInstruction.md)
 - [SpFulfillmentInboundV0::PrepInstructionList](docs/PrepInstructionList.md)
 - [SpFulfillmentInboundV0::PrepOwner](docs/PrepOwner.md)
 - [SpFulfillmentInboundV0::ProNumber](docs/ProNumber.md)
 - [SpFulfillmentInboundV0::PutTransportDetailsRequest](docs/PutTransportDetailsRequest.md)
 - [SpFulfillmentInboundV0::PutTransportDetailsResponse](docs/PutTransportDetailsResponse.md)
 - [SpFulfillmentInboundV0::Quantity](docs/Quantity.md)
 - [SpFulfillmentInboundV0::SKUInboundGuidance](docs/SKUInboundGuidance.md)
 - [SpFulfillmentInboundV0::SKUInboundGuidanceList](docs/SKUInboundGuidanceList.md)
 - [SpFulfillmentInboundV0::SKUPrepInstructions](docs/SKUPrepInstructions.md)
 - [SpFulfillmentInboundV0::SKUPrepInstructionsList](docs/SKUPrepInstructionsList.md)
 - [SpFulfillmentInboundV0::SellerFreightClass](docs/SellerFreightClass.md)
 - [SpFulfillmentInboundV0::ShipmentStatus](docs/ShipmentStatus.md)
 - [SpFulfillmentInboundV0::ShipmentType](docs/ShipmentType.md)
 - [SpFulfillmentInboundV0::TimeStampStringType](docs/TimeStampStringType.md)
 - [SpFulfillmentInboundV0::TrackingId](docs/TrackingId.md)
 - [SpFulfillmentInboundV0::TransportContent](docs/TransportContent.md)
 - [SpFulfillmentInboundV0::TransportDetailInput](docs/TransportDetailInput.md)
 - [SpFulfillmentInboundV0::TransportDetailOutput](docs/TransportDetailOutput.md)
 - [SpFulfillmentInboundV0::TransportHeader](docs/TransportHeader.md)
 - [SpFulfillmentInboundV0::TransportResult](docs/TransportResult.md)
 - [SpFulfillmentInboundV0::TransportStatus](docs/TransportStatus.md)
 - [SpFulfillmentInboundV0::UnitOfMeasurement](docs/UnitOfMeasurement.md)
 - [SpFulfillmentInboundV0::UnitOfWeight](docs/UnitOfWeight.md)
 - [SpFulfillmentInboundV0::UnsignedIntType](docs/UnsignedIntType.md)
 - [SpFulfillmentInboundV0::VoidTransportResponse](docs/VoidTransportResponse.md)
 - [SpFulfillmentInboundV0::Weight](docs/Weight.md)

## Documentation for Authorization

 All endpoints do not require authorization.

