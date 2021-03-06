# sp_fba_small_and_light

SpFbaSmallAndLight - the Ruby gem for the Selling Partner API for FBA Small And Light

The Selling Partner API for FBA Small and Light lets you help sellers manage their listings in the Small and Light program. The program reduces the cost of fulfilling orders for small and lightweight FBA inventory. You can enroll or remove items from the program and check item eligibility and enrollment status. You can also preview the estimated program fees charged to a seller for items sold while enrolled in the program.

This SDK is automatically generated by the [Swagger Codegen](https://github.com/swagger-api/swagger-codegen) project:

- API version: v1
- Package version: 1.0.0
- Build package: io.swagger.codegen.v3.generators.ruby.RubyClientCodegen
For more information, please visit [https://sellercentral.amazon.com/gp/mws/contactus.html](https://sellercentral.amazon.com/gp/mws/contactus.html)

## Installation

### Build a gem

To build the Ruby code into a gem:

```shell
gem build sp_fba_small_and_light.gemspec
```

Then either install the gem locally:

```shell
gem install ./sp_fba_small_and_light-1.0.0.gem
```
(for development, run `gem install --dev ./sp_fba_small_and_light-1.0.0.gem` to install the development dependencies)

or publish the gem to a gem hosting service, e.g. [RubyGems](https://rubygems.org/).

Finally add this to the Gemfile:

    gem 'sp_fba_small_and_light', '~> 1.0.0'

### Install from Git

If the Ruby gem is hosted at a git repository: https://github.com/GIT_USER_ID/GIT_REPO_ID, then add the following in the Gemfile:

    gem 'sp_fba_small_and_light', :git => 'https://github.com/GIT_USER_ID/GIT_REPO_ID.git'

### Include the Ruby code directly

Include the Ruby code directly using `-I` as follows:

```shell
ruby -Ilib script.rb
```

## Getting Started

Please follow the [installation](#installation) procedure and then run the following code:
```ruby
# Load the gem
require 'sp_fba_small_and_light'

api_instance = SpFbaSmallAndLight::SmallAndLightApi.new
seller_sku = 'seller_sku_example' # String | The seller SKU that identifies the item.
marketplace_ids = ['marketplace_ids_example'] # Array<String> | The marketplace in which to remove the item from the Small and Light program. Note: Accepts a single marketplace only.


begin
  api_instance.delete_small_and_light_enrollment_by_seller_sku(seller_sku, marketplace_ids)
rescue SpFbaSmallAndLight::ApiError => e
  puts "Exception when calling SmallAndLightApi->delete_small_and_light_enrollment_by_seller_sku: #{e}"
end

api_instance = SpFbaSmallAndLight::SmallAndLightApi.new
seller_sku = 'seller_sku_example' # String | The seller SKU that identifies the item.
marketplace_ids = ['marketplace_ids_example'] # Array<String> | The marketplace for which the eligibility status is retrieved. NOTE: Accepts a single marketplace only.


begin
  result = api_instance.get_small_and_light_eligibility_by_seller_sku(seller_sku, marketplace_ids)
  p result
rescue SpFbaSmallAndLight::ApiError => e
  puts "Exception when calling SmallAndLightApi->get_small_and_light_eligibility_by_seller_sku: #{e}"
end

api_instance = SpFbaSmallAndLight::SmallAndLightApi.new
seller_sku = 'seller_sku_example' # String | The seller SKU that identifies the item.
marketplace_ids = ['marketplace_ids_example'] # Array<String> | The marketplace for which the enrollment status is retrieved. Note: Accepts a single marketplace only.


begin
  result = api_instance.get_small_and_light_enrollment_by_seller_sku(seller_sku, marketplace_ids)
  p result
rescue SpFbaSmallAndLight::ApiError => e
  puts "Exception when calling SmallAndLightApi->get_small_and_light_enrollment_by_seller_sku: #{e}"
end

api_instance = SpFbaSmallAndLight::SmallAndLightApi.new
body = SpFbaSmallAndLight::SmallAndLightFeePreviewRequest.new # SmallAndLightFeePreviewRequest | 


begin
  result = api_instance.get_small_and_light_fee_preview(body)
  p result
rescue SpFbaSmallAndLight::ApiError => e
  puts "Exception when calling SmallAndLightApi->get_small_and_light_fee_preview: #{e}"
end

api_instance = SpFbaSmallAndLight::SmallAndLightApi.new
seller_sku = 'seller_sku_example' # String | The seller SKU that identifies the item.
marketplace_ids = ['marketplace_ids_example'] # Array<String> | The marketplace in which to enroll the item. Note: Accepts a single marketplace only.


begin
  result = api_instance.put_small_and_light_enrollment_by_seller_sku(seller_sku, marketplace_ids)
  p result
rescue SpFbaSmallAndLight::ApiError => e
  puts "Exception when calling SmallAndLightApi->put_small_and_light_enrollment_by_seller_sku: #{e}"
end
```

## Documentation for API Endpoints

All URIs are relative to *https://sellingpartnerapi-na.amazon.com/*

Class | Method | HTTP request | Description
------------ | ------------- | ------------- | -------------
*SpFbaSmallAndLight::SmallAndLightApi* | [**delete_small_and_light_enrollment_by_seller_sku**](docs/SmallAndLightApi.md#delete_small_and_light_enrollment_by_seller_sku) | **DELETE** /fba/smallAndLight/v1/enrollments/{sellerSKU} | 
*SpFbaSmallAndLight::SmallAndLightApi* | [**get_small_and_light_eligibility_by_seller_sku**](docs/SmallAndLightApi.md#get_small_and_light_eligibility_by_seller_sku) | **GET** /fba/smallAndLight/v1/eligibilities/{sellerSKU} | 
*SpFbaSmallAndLight::SmallAndLightApi* | [**get_small_and_light_enrollment_by_seller_sku**](docs/SmallAndLightApi.md#get_small_and_light_enrollment_by_seller_sku) | **GET** /fba/smallAndLight/v1/enrollments/{sellerSKU} | 
*SpFbaSmallAndLight::SmallAndLightApi* | [**get_small_and_light_fee_preview**](docs/SmallAndLightApi.md#get_small_and_light_fee_preview) | **POST** /fba/smallAndLight/v1/feePreviews | 
*SpFbaSmallAndLight::SmallAndLightApi* | [**put_small_and_light_enrollment_by_seller_sku**](docs/SmallAndLightApi.md#put_small_and_light_enrollment_by_seller_sku) | **PUT** /fba/smallAndLight/v1/enrollments/{sellerSKU} | 

## Documentation for Models

 - [SpFbaSmallAndLight::Error](docs/Error.md)
 - [SpFbaSmallAndLight::ErrorList](docs/ErrorList.md)
 - [SpFbaSmallAndLight::FeeLineItem](docs/FeeLineItem.md)
 - [SpFbaSmallAndLight::FeePreview](docs/FeePreview.md)
 - [SpFbaSmallAndLight::Item](docs/Item.md)
 - [SpFbaSmallAndLight::MarketplaceId](docs/MarketplaceId.md)
 - [SpFbaSmallAndLight::MoneyType](docs/MoneyType.md)
 - [SpFbaSmallAndLight::SellerSKU](docs/SellerSKU.md)
 - [SpFbaSmallAndLight::SmallAndLightEligibility](docs/SmallAndLightEligibility.md)
 - [SpFbaSmallAndLight::SmallAndLightEligibilityStatus](docs/SmallAndLightEligibilityStatus.md)
 - [SpFbaSmallAndLight::SmallAndLightEnrollment](docs/SmallAndLightEnrollment.md)
 - [SpFbaSmallAndLight::SmallAndLightEnrollmentStatus](docs/SmallAndLightEnrollmentStatus.md)
 - [SpFbaSmallAndLight::SmallAndLightFeePreviewRequest](docs/SmallAndLightFeePreviewRequest.md)
 - [SpFbaSmallAndLight::SmallAndLightFeePreviews](docs/SmallAndLightFeePreviews.md)

## Documentation for Authorization

 All endpoints do not require authorization.

