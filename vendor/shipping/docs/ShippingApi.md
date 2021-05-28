# AmazonSpClients::SpShipping::ShippingApi

All URIs are relative to *https://sellingpartnerapi-na.amazon.com/*

Method | HTTP request | Description
------------- | ------------- | -------------
[**cancel_shipment**](ShippingApi.md#cancel_shipment) | **POST** /shipping/v1/shipments/{shipmentId}/cancel | 
[**create_shipment**](ShippingApi.md#create_shipment) | **POST** /shipping/v1/shipments | 
[**get_account**](ShippingApi.md#get_account) | **GET** /shipping/v1/account | 
[**get_rates**](ShippingApi.md#get_rates) | **POST** /shipping/v1/rates | 
[**get_shipment**](ShippingApi.md#get_shipment) | **GET** /shipping/v1/shipments/{shipmentId} | 
[**get_tracking_information**](ShippingApi.md#get_tracking_information) | **GET** /shipping/v1/tracking/{trackingId} | 
[**purchase_labels**](ShippingApi.md#purchase_labels) | **POST** /shipping/v1/shipments/{shipmentId}/purchaseLabels | 
[**purchase_shipment**](ShippingApi.md#purchase_shipment) | **POST** /shipping/v1/purchaseShipment | 
[**retrieve_shipping_label**](ShippingApi.md#retrieve_shipping_label) | **POST** /shipping/v1/shipments/{shipmentId}/containers/{trackingId}/label | 

# **cancel_shipment**
> CancelShipmentResponse cancel_shipment(shipment_id)



Cancel a shipment by the given shipmentId.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 5 | 15 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.

### Example
```ruby
# load the gem
require 'sp_shipping'

api_instance = AmazonSpClients::SpShipping::ShippingApi.new
shipment_id = 'shipment_id_example' # String | 


begin
  result = api_instance.cancel_shipment(shipment_id)
  p result
rescue AmazonSpClients::SpShipping::ApiError => e
  puts "Exception when calling ShippingApi->cancel_shipment: #{e}"
end
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **shipment_id** | **String**|  | 

### Return type

[**CancelShipmentResponse**](CancelShipmentResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json



# **create_shipment**
> CreateShipmentResponse create_shipment(body)



Create a new shipment.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 5 | 15 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.

### Example
```ruby
# load the gem
require 'sp_shipping'

api_instance = AmazonSpClients::SpShipping::ShippingApi.new
body = SpShipping::CreateShipmentRequest.new # CreateShipmentRequest | 


begin
  result = api_instance.create_shipment(body)
  p result
rescue AmazonSpClients::SpShipping::ApiError => e
  puts "Exception when calling ShippingApi->create_shipment: #{e}"
end
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**CreateShipmentRequest**](CreateShipmentRequest.md)|  | 

### Return type

[**CreateShipmentResponse**](CreateShipmentResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json



# **get_account**
> GetAccountResponse get_account



Verify if the current account is valid.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 5 | 15 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.

### Example
```ruby
# load the gem
require 'sp_shipping'

api_instance = AmazonSpClients::SpShipping::ShippingApi.new

begin
  result = api_instance.get_account
  p result
rescue AmazonSpClients::SpShipping::ApiError => e
  puts "Exception when calling ShippingApi->get_account: #{e}"
end
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetAccountResponse**](GetAccountResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json



# **get_rates**
> GetRatesResponse get_rates(body)



Get service rates.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 5 | 15 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.

### Example
```ruby
# load the gem
require 'sp_shipping'

api_instance = AmazonSpClients::SpShipping::ShippingApi.new
body = SpShipping::GetRatesRequest.new # GetRatesRequest | 


begin
  result = api_instance.get_rates(body)
  p result
rescue AmazonSpClients::SpShipping::ApiError => e
  puts "Exception when calling ShippingApi->get_rates: #{e}"
end
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**GetRatesRequest**](GetRatesRequest.md)|  | 

### Return type

[**GetRatesResponse**](GetRatesResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json



# **get_shipment**
> GetShipmentResponse get_shipment(shipment_id)



Return the entire shipment object for the shipmentId.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 5 | 15 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.

### Example
```ruby
# load the gem
require 'sp_shipping'

api_instance = AmazonSpClients::SpShipping::ShippingApi.new
shipment_id = 'shipment_id_example' # String | 


begin
  result = api_instance.get_shipment(shipment_id)
  p result
rescue AmazonSpClients::SpShipping::ApiError => e
  puts "Exception when calling ShippingApi->get_shipment: #{e}"
end
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **shipment_id** | **String**|  | 

### Return type

[**GetShipmentResponse**](GetShipmentResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json



# **get_tracking_information**
> GetTrackingInformationResponse get_tracking_information(tracking_id)



Return the tracking information of a shipment.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 1 | 1 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.

### Example
```ruby
# load the gem
require 'sp_shipping'

api_instance = AmazonSpClients::SpShipping::ShippingApi.new
tracking_id = 'tracking_id_example' # String | 


begin
  result = api_instance.get_tracking_information(tracking_id)
  p result
rescue AmazonSpClients::SpShipping::ApiError => e
  puts "Exception when calling ShippingApi->get_tracking_information: #{e}"
end
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tracking_id** | **String**|  | 

### Return type

[**GetTrackingInformationResponse**](GetTrackingInformationResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json



# **purchase_labels**
> PurchaseLabelsResponse purchase_labels(bodyshipment_id)



Purchase shipping labels based on a given rate.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 5 | 15 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.

### Example
```ruby
# load the gem
require 'sp_shipping'

api_instance = AmazonSpClients::SpShipping::ShippingApi.new
body = SpShipping::PurchaseLabelsRequest.new # PurchaseLabelsRequest | 
shipment_id = 'shipment_id_example' # String | 


begin
  result = api_instance.purchase_labels(bodyshipment_id)
  p result
rescue AmazonSpClients::SpShipping::ApiError => e
  puts "Exception when calling ShippingApi->purchase_labels: #{e}"
end
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**PurchaseLabelsRequest**](PurchaseLabelsRequest.md)|  | 
 **shipment_id** | **String**|  | 

### Return type

[**PurchaseLabelsResponse**](PurchaseLabelsResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json



# **purchase_shipment**
> PurchaseShipmentResponse purchase_shipment(body)



Purchase shipping labels.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 5 | 15 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.

### Example
```ruby
# load the gem
require 'sp_shipping'

api_instance = AmazonSpClients::SpShipping::ShippingApi.new
body = SpShipping::PurchaseShipmentRequest.new # PurchaseShipmentRequest | 


begin
  result = api_instance.purchase_shipment(body)
  p result
rescue AmazonSpClients::SpShipping::ApiError => e
  puts "Exception when calling ShippingApi->purchase_shipment: #{e}"
end
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**PurchaseShipmentRequest**](PurchaseShipmentRequest.md)|  | 

### Return type

[**PurchaseShipmentResponse**](PurchaseShipmentResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json



# **retrieve_shipping_label**
> RetrieveShippingLabelResponse retrieve_shipping_label(bodyshipment_idtracking_id)



Retrieve shipping label based on the shipment id and tracking id.  **Usage Plan:**  | Rate (requests per second) | Burst | | ---- | ---- | | 5 | 15 |  For more information, see \"Usage Plans and Rate Limits\" in the Selling Partner API documentation.

### Example
```ruby
# load the gem
require 'sp_shipping'

api_instance = AmazonSpClients::SpShipping::ShippingApi.new
body = SpShipping::RetrieveShippingLabelRequest.new # RetrieveShippingLabelRequest | 
shipment_id = 'shipment_id_example' # String | 
tracking_id = 'tracking_id_example' # String | 


begin
  result = api_instance.retrieve_shipping_label(bodyshipment_idtracking_id)
  p result
rescue AmazonSpClients::SpShipping::ApiError => e
  puts "Exception when calling ShippingApi->retrieve_shipping_label: #{e}"
end
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | [**RetrieveShippingLabelRequest**](RetrieveShippingLabelRequest.md)|  | 
 **shipment_id** | **String**|  | 
 **tracking_id** | **String**|  | 

### Return type

[**RetrieveShippingLabelResponse**](RetrieveShippingLabelResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json



