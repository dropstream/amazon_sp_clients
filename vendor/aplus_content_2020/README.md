# sp_aplus_content_2020

SpAplusContent2020 - the Ruby gem for the Selling Partner API for A+ Content Management

With the A+ Content API, you can build applications that help selling partners add rich marketing content to their Amazon product detail pages. A+ content helps selling partners share their brand and product story, which helps buyers make informed purchasing decisions. Selling partners assemble content by choosing from content modules and adding images and text.

This SDK is automatically generated by the [Swagger Codegen](https://github.com/swagger-api/swagger-codegen) project:

- API version: 2020-11-01
- Package version: 1.0.0
- Build package: io.swagger.codegen.v3.generators.ruby.RubyClientCodegen
For more information, please visit [https://sellercentral.amazon.com/gp/mws/contactus.html](https://sellercentral.amazon.com/gp/mws/contactus.html)

## Installation

### Build a gem

To build the Ruby code into a gem:

```shell
gem build sp_aplus_content_2020.gemspec
```

Then either install the gem locally:

```shell
gem install ./sp_aplus_content_2020-1.0.0.gem
```
(for development, run `gem install --dev ./sp_aplus_content_2020-1.0.0.gem` to install the development dependencies)

or publish the gem to a gem hosting service, e.g. [RubyGems](https://rubygems.org/).

Finally add this to the Gemfile:

    gem 'sp_aplus_content_2020', '~> 1.0.0'

### Install from Git

If the Ruby gem is hosted at a git repository: https://github.com/GIT_USER_ID/GIT_REPO_ID, then add the following in the Gemfile:

    gem 'sp_aplus_content_2020', :git => 'https://github.com/GIT_USER_ID/GIT_REPO_ID.git'

### Include the Ruby code directly

Include the Ruby code directly using `-I` as follows:

```shell
ruby -Ilib script.rb
```

## Getting Started

Please follow the [installation](#installation) procedure and then run the following code:
```ruby
# Load the gem
require 'sp_aplus_content_2020'

api_instance = SpAplusContent2020::AplusContentApi.new
body = SpAplusContent2020::PostContentDocumentRequest.new # PostContentDocumentRequest | The content document request details.
marketplace_id = 'marketplace_id_example' # String | The identifier for the marketplace where the A+ Content is published.


begin
  result = api_instance.create_content_document(body, marketplace_id)
  p result
rescue SpAplusContent2020::ApiError => e
  puts "Exception when calling AplusContentApi->create_content_document: #{e}"
end

api_instance = SpAplusContent2020::AplusContentApi.new
content_reference_key = 'content_reference_key_example' # String | The unique reference key for the A+ Content document. A content reference key cannot form a permalink and may change in the future. A content reference key is not guaranteed to match any A+ Content identifier.
marketplace_id = 'marketplace_id_example' # String | The identifier for the marketplace where the A+ Content is published.
included_data_set = ['included_data_set_example'] # Array<String> | The set of A+ Content data types to include in the response.


begin
  result = api_instance.get_content_document(content_reference_key, marketplace_id, included_data_set)
  p result
rescue SpAplusContent2020::ApiError => e
  puts "Exception when calling AplusContentApi->get_content_document: #{e}"
end

api_instance = SpAplusContent2020::AplusContentApi.new
content_reference_key = 'content_reference_key_example' # String | The unique reference key for the A+ Content document. A content reference key cannot form a permalink and may change in the future. A content reference key is not guaranteed to match any A+ Content identifier.
marketplace_id = 'marketplace_id_example' # String | The identifier for the marketplace where the A+ Content is published.
opts = { 
  included_data_set: ['included_data_set_example'], # Array<String> | The set of A+ Content data types to include in the response. If you do not include this parameter, the operation returns the related ASINs without metadata.
  asin_set: ['asin_set_example'], # Array<String> | The set of ASINs.
  page_token: 'page_token_example' # String | A page token from the nextPageToken response element returned by your previous call to this operation. nextPageToken is returned when the results of a call exceed the page size. To get the next page of results, call the operation and include pageToken as the only parameter. Specifying pageToken with any other parameter will cause the request to fail. When no nextPageToken value is returned there are no more pages to return. A pageToken value is not usable across different operations.
}

begin
  result = api_instance.list_content_document_asin_relations(content_reference_key, marketplace_id, opts)
  p result
rescue SpAplusContent2020::ApiError => e
  puts "Exception when calling AplusContentApi->list_content_document_asin_relations: #{e}"
end

api_instance = SpAplusContent2020::AplusContentApi.new
content_reference_key = 'content_reference_key_example' # String | The unique reference key for the A+ Content document. A content reference key cannot form a permalink and may change in the future. A content reference key is not guaranteed to match any A+ content identifier.
marketplace_id = 'marketplace_id_example' # String | The identifier for the marketplace where the A+ Content is published.


begin
  result = api_instance.post_content_document_approval_submission(content_reference_key, marketplace_id)
  p result
rescue SpAplusContent2020::ApiError => e
  puts "Exception when calling AplusContentApi->post_content_document_approval_submission: #{e}"
end

api_instance = SpAplusContent2020::AplusContentApi.new
body = SpAplusContent2020::PostContentDocumentAsinRelationsRequest.new # PostContentDocumentAsinRelationsRequest | The content document ASIN relations request details.
content_reference_key = 'content_reference_key_example' # String | The unique reference key for the A+ Content document. A content reference key cannot form a permalink and may change in the future. A content reference key is not guaranteed to match any A+ content identifier.
marketplace_id = 'marketplace_id_example' # String | The identifier for the marketplace where the A+ Content is published.


begin
  result = api_instance.post_content_document_asin_relations(body, content_reference_key, marketplace_id)
  p result
rescue SpAplusContent2020::ApiError => e
  puts "Exception when calling AplusContentApi->post_content_document_asin_relations: #{e}"
end

api_instance = SpAplusContent2020::AplusContentApi.new
content_reference_key = 'content_reference_key_example' # String | The unique reference key for the A+ Content document. A content reference key cannot form a permalink and may change in the future. A content reference key is not guaranteed to match any A+ content identifier.
marketplace_id = 'marketplace_id_example' # String | The identifier for the marketplace where the A+ Content is published.


begin
  result = api_instance.post_content_document_suspend_submission(content_reference_key, marketplace_id)
  p result
rescue SpAplusContent2020::ApiError => e
  puts "Exception when calling AplusContentApi->post_content_document_suspend_submission: #{e}"
end

api_instance = SpAplusContent2020::AplusContentApi.new
marketplace_id = 'marketplace_id_example' # String | The identifier for the marketplace where the A+ Content is published.
opts = { 
  page_token: 'page_token_example' # String | A page token from the nextPageToken response element returned by your previous call to this operation. nextPageToken is returned when the results of a call exceed the page size. To get the next page of results, call the operation and include pageToken as the only parameter. Specifying pageToken with any other parameter will cause the request to fail. When no nextPageToken value is returned there are no more pages to return. A pageToken value is not usable across different operations.
}

begin
  result = api_instance.search_content_documents(marketplace_id, opts)
  p result
rescue SpAplusContent2020::ApiError => e
  puts "Exception when calling AplusContentApi->search_content_documents: #{e}"
end

api_instance = SpAplusContent2020::AplusContentApi.new
marketplace_id = 'marketplace_id_example' # String | The identifier for the marketplace where the A+ Content is published.
asin = 'asin_example' # String | The Amazon Standard Identification Number (ASIN).
opts = { 
  page_token: 'page_token_example' # String | A page token from the nextPageToken response element returned by your previous call to this operation. nextPageToken is returned when the results of a call exceed the page size. To get the next page of results, call the operation and include pageToken as the only parameter. Specifying pageToken with any other parameter will cause the request to fail. When no nextPageToken value is returned there are no more pages to return. A pageToken value is not usable across different operations.
}

begin
  result = api_instance.search_content_publish_records(marketplace_id, asin, opts)
  p result
rescue SpAplusContent2020::ApiError => e
  puts "Exception when calling AplusContentApi->search_content_publish_records: #{e}"
end

api_instance = SpAplusContent2020::AplusContentApi.new
body = SpAplusContent2020::PostContentDocumentRequest.new # PostContentDocumentRequest | The content document request details.
content_reference_key = 'content_reference_key_example' # String | The unique reference key for the A+ Content document. A content reference key cannot form a permalink and may change in the future. A content reference key is not guaranteed to match any A+ Content identifier.
marketplace_id = 'marketplace_id_example' # String | The identifier for the marketplace where the A+ Content is published.


begin
  result = api_instance.update_content_document(body, content_reference_key, marketplace_id)
  p result
rescue SpAplusContent2020::ApiError => e
  puts "Exception when calling AplusContentApi->update_content_document: #{e}"
end

api_instance = SpAplusContent2020::AplusContentApi.new
body = SpAplusContent2020::PostContentDocumentRequest.new # PostContentDocumentRequest | The content document request details.
marketplace_id = 'marketplace_id_example' # String | The identifier for the marketplace where the A+ Content is published.
opts = { 
  asin_set: ['asin_set_example'] # Array<String> | The set of ASINs.
}

begin
  result = api_instance.validate_content_document_asin_relations(body, marketplace_id, opts)
  p result
rescue SpAplusContent2020::ApiError => e
  puts "Exception when calling AplusContentApi->validate_content_document_asin_relations: #{e}"
end
```

## Documentation for API Endpoints

All URIs are relative to *https://sellingpartnerapi-na.amazon.com/*

Class | Method | HTTP request | Description
------------ | ------------- | ------------- | -------------
*SpAplusContent2020::AplusContentApi* | [**create_content_document**](docs/AplusContentApi.md#create_content_document) | **POST** /aplus/2020-11-01/contentDocuments | 
*SpAplusContent2020::AplusContentApi* | [**get_content_document**](docs/AplusContentApi.md#get_content_document) | **GET** /aplus/2020-11-01/contentDocuments/{contentReferenceKey} | 
*SpAplusContent2020::AplusContentApi* | [**list_content_document_asin_relations**](docs/AplusContentApi.md#list_content_document_asin_relations) | **GET** /aplus/2020-11-01/contentDocuments/{contentReferenceKey}/asins | 
*SpAplusContent2020::AplusContentApi* | [**post_content_document_approval_submission**](docs/AplusContentApi.md#post_content_document_approval_submission) | **POST** /aplus/2020-11-01/contentDocuments/{contentReferenceKey}/approvalSubmissions | 
*SpAplusContent2020::AplusContentApi* | [**post_content_document_asin_relations**](docs/AplusContentApi.md#post_content_document_asin_relations) | **POST** /aplus/2020-11-01/contentDocuments/{contentReferenceKey}/asins | 
*SpAplusContent2020::AplusContentApi* | [**post_content_document_suspend_submission**](docs/AplusContentApi.md#post_content_document_suspend_submission) | **POST** /aplus/2020-11-01/contentDocuments/{contentReferenceKey}/suspendSubmissions | 
*SpAplusContent2020::AplusContentApi* | [**search_content_documents**](docs/AplusContentApi.md#search_content_documents) | **GET** /aplus/2020-11-01/contentDocuments | 
*SpAplusContent2020::AplusContentApi* | [**search_content_publish_records**](docs/AplusContentApi.md#search_content_publish_records) | **GET** /aplus/2020-11-01/contentPublishRecords | 
*SpAplusContent2020::AplusContentApi* | [**update_content_document**](docs/AplusContentApi.md#update_content_document) | **POST** /aplus/2020-11-01/contentDocuments/{contentReferenceKey} | 
*SpAplusContent2020::AplusContentApi* | [**validate_content_document_asin_relations**](docs/AplusContentApi.md#validate_content_document_asin_relations) | **POST** /aplus/2020-11-01/contentAsinValidations | 

## Documentation for Models

 - [SpAplusContent2020::AplusPaginatedResponse](docs/AplusPaginatedResponse.md)
 - [SpAplusContent2020::AplusResponse](docs/AplusResponse.md)
 - [SpAplusContent2020::Asin](docs/Asin.md)
 - [SpAplusContent2020::AsinBadge](docs/AsinBadge.md)
 - [SpAplusContent2020::AsinBadgeSet](docs/AsinBadgeSet.md)
 - [SpAplusContent2020::AsinMetadata](docs/AsinMetadata.md)
 - [SpAplusContent2020::AsinMetadataSet](docs/AsinMetadataSet.md)
 - [SpAplusContent2020::AsinSet](docs/AsinSet.md)
 - [SpAplusContent2020::ColorType](docs/ColorType.md)
 - [SpAplusContent2020::ContentBadge](docs/ContentBadge.md)
 - [SpAplusContent2020::ContentBadgeSet](docs/ContentBadgeSet.md)
 - [SpAplusContent2020::ContentDocument](docs/ContentDocument.md)
 - [SpAplusContent2020::ContentMetadata](docs/ContentMetadata.md)
 - [SpAplusContent2020::ContentMetadataRecord](docs/ContentMetadataRecord.md)
 - [SpAplusContent2020::ContentMetadataRecordList](docs/ContentMetadataRecordList.md)
 - [SpAplusContent2020::ContentModule](docs/ContentModule.md)
 - [SpAplusContent2020::ContentModuleList](docs/ContentModuleList.md)
 - [SpAplusContent2020::ContentModuleType](docs/ContentModuleType.md)
 - [SpAplusContent2020::ContentRecord](docs/ContentRecord.md)
 - [SpAplusContent2020::ContentRecordList](docs/ContentRecordList.md)
 - [SpAplusContent2020::ContentReferenceKey](docs/ContentReferenceKey.md)
 - [SpAplusContent2020::ContentReferenceKeySet](docs/ContentReferenceKeySet.md)
 - [SpAplusContent2020::ContentStatus](docs/ContentStatus.md)
 - [SpAplusContent2020::ContentSubType](docs/ContentSubType.md)
 - [SpAplusContent2020::ContentType](docs/ContentType.md)
 - [SpAplusContent2020::Decorator](docs/Decorator.md)
 - [SpAplusContent2020::DecoratorSet](docs/DecoratorSet.md)
 - [SpAplusContent2020::DecoratorType](docs/DecoratorType.md)
 - [SpAplusContent2020::Error](docs/Error.md)
 - [SpAplusContent2020::ErrorList](docs/ErrorList.md)
 - [SpAplusContent2020::GetContentDocumentIncludedDataType](docs/GetContentDocumentIncludedDataType.md)
 - [SpAplusContent2020::GetContentDocumentResponse](docs/GetContentDocumentResponse.md)
 - [SpAplusContent2020::ImageComponent](docs/ImageComponent.md)
 - [SpAplusContent2020::ImageCropSpecification](docs/ImageCropSpecification.md)
 - [SpAplusContent2020::ImageDimensions](docs/ImageDimensions.md)
 - [SpAplusContent2020::ImageOffsets](docs/ImageOffsets.md)
 - [SpAplusContent2020::IntegerWithUnits](docs/IntegerWithUnits.md)
 - [SpAplusContent2020::LanguageTag](docs/LanguageTag.md)
 - [SpAplusContent2020::ListContentDocumentAsinRelationsIncludedDataType](docs/ListContentDocumentAsinRelationsIncludedDataType.md)
 - [SpAplusContent2020::ListContentDocumentAsinRelationsResponse](docs/ListContentDocumentAsinRelationsResponse.md)
 - [SpAplusContent2020::MarketplaceId](docs/MarketplaceId.md)
 - [SpAplusContent2020::MessageSet](docs/MessageSet.md)
 - [SpAplusContent2020::PageToken](docs/PageToken.md)
 - [SpAplusContent2020::ParagraphComponent](docs/ParagraphComponent.md)
 - [SpAplusContent2020::PlainTextItem](docs/PlainTextItem.md)
 - [SpAplusContent2020::PositionType](docs/PositionType.md)
 - [SpAplusContent2020::PostContentDocumentApprovalSubmissionResponse](docs/PostContentDocumentApprovalSubmissionResponse.md)
 - [SpAplusContent2020::PostContentDocumentAsinRelationsRequest](docs/PostContentDocumentAsinRelationsRequest.md)
 - [SpAplusContent2020::PostContentDocumentAsinRelationsResponse](docs/PostContentDocumentAsinRelationsResponse.md)
 - [SpAplusContent2020::PostContentDocumentRequest](docs/PostContentDocumentRequest.md)
 - [SpAplusContent2020::PostContentDocumentResponse](docs/PostContentDocumentResponse.md)
 - [SpAplusContent2020::PostContentDocumentSuspendSubmissionResponse](docs/PostContentDocumentSuspendSubmissionResponse.md)
 - [SpAplusContent2020::PublishRecord](docs/PublishRecord.md)
 - [SpAplusContent2020::PublishRecordList](docs/PublishRecordList.md)
 - [SpAplusContent2020::SearchContentDocumentsResponse](docs/SearchContentDocumentsResponse.md)
 - [SpAplusContent2020::SearchContentPublishRecordsResponse](docs/SearchContentPublishRecordsResponse.md)
 - [SpAplusContent2020::StandardCompanyLogoModule](docs/StandardCompanyLogoModule.md)
 - [SpAplusContent2020::StandardComparisonProductBlock](docs/StandardComparisonProductBlock.md)
 - [SpAplusContent2020::StandardComparisonTableModule](docs/StandardComparisonTableModule.md)
 - [SpAplusContent2020::StandardFourImageTextModule](docs/StandardFourImageTextModule.md)
 - [SpAplusContent2020::StandardFourImageTextQuadrantModule](docs/StandardFourImageTextQuadrantModule.md)
 - [SpAplusContent2020::StandardHeaderImageTextModule](docs/StandardHeaderImageTextModule.md)
 - [SpAplusContent2020::StandardHeaderTextListBlock](docs/StandardHeaderTextListBlock.md)
 - [SpAplusContent2020::StandardImageCaptionBlock](docs/StandardImageCaptionBlock.md)
 - [SpAplusContent2020::StandardImageSidebarModule](docs/StandardImageSidebarModule.md)
 - [SpAplusContent2020::StandardImageTextBlock](docs/StandardImageTextBlock.md)
 - [SpAplusContent2020::StandardImageTextCaptionBlock](docs/StandardImageTextCaptionBlock.md)
 - [SpAplusContent2020::StandardImageTextOverlayModule](docs/StandardImageTextOverlayModule.md)
 - [SpAplusContent2020::StandardMultipleImageTextModule](docs/StandardMultipleImageTextModule.md)
 - [SpAplusContent2020::StandardProductDescriptionModule](docs/StandardProductDescriptionModule.md)
 - [SpAplusContent2020::StandardSingleImageHighlightsModule](docs/StandardSingleImageHighlightsModule.md)
 - [SpAplusContent2020::StandardSingleImageSpecsDetailModule](docs/StandardSingleImageSpecsDetailModule.md)
 - [SpAplusContent2020::StandardSingleSideImageModule](docs/StandardSingleSideImageModule.md)
 - [SpAplusContent2020::StandardTechSpecsModule](docs/StandardTechSpecsModule.md)
 - [SpAplusContent2020::StandardTextBlock](docs/StandardTextBlock.md)
 - [SpAplusContent2020::StandardTextListBlock](docs/StandardTextListBlock.md)
 - [SpAplusContent2020::StandardTextModule](docs/StandardTextModule.md)
 - [SpAplusContent2020::StandardTextPairBlock](docs/StandardTextPairBlock.md)
 - [SpAplusContent2020::StandardThreeImageTextModule](docs/StandardThreeImageTextModule.md)
 - [SpAplusContent2020::TextComponent](docs/TextComponent.md)
 - [SpAplusContent2020::TextItem](docs/TextItem.md)
 - [SpAplusContent2020::ValidateContentDocumentAsinRelationsResponse](docs/ValidateContentDocumentAsinRelationsResponse.md)

## Documentation for Authorization

 All endpoints do not require authorization.
