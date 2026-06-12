# e_shop_api.api.OrdersApi

## Load the API package
```dart
import 'package:e_shop_api/api.dart';
```

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**v1OrdersGet**](OrdersApi.md#v1ordersget) | **GET** /v1/orders | List all orders (optionally filter by userId)
[**v1OrdersIdGet**](OrdersApi.md#v1ordersidget) | **GET** /v1/orders/{id} | Get order details by ID
[**v1OrdersIdPayPost**](OrdersApi.md#v1ordersidpaypost) | **POST** /v1/orders/{id}/pay | Confirm UPI/digital payment for an order using transaction reference
[**v1OrdersPost**](OrdersApi.md#v1orderspost) | **POST** /v1/orders | Place an order (checkout the current cart)


# **v1OrdersGet**
> BuiltList<Order> v1OrdersGet(userId)

List all orders (optionally filter by userId)

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getOrdersApi();
final int userId = 56; // int | 

try {
    final response = api.v1OrdersGet(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OrdersApi->v1OrdersGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **int**|  | [optional] 

### Return type

[**BuiltList&lt;Order&gt;**](Order.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1OrdersIdGet**
> Order v1OrdersIdGet(id)

Get order details by ID

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getOrdersApi();
final int id = 56; // int | 

try {
    final response = api.v1OrdersIdGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OrdersApi->v1OrdersIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Order**](Order.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1OrdersIdPayPost**
> Order v1OrdersIdPayPost(id, payOrderInput)

Confirm UPI/digital payment for an order using transaction reference

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getOrdersApi();
final int id = 56; // int | 
final PayOrderInput payOrderInput = ; // PayOrderInput | 

try {
    final response = api.v1OrdersIdPayPost(id, payOrderInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OrdersApi->v1OrdersIdPayPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **payOrderInput** | [**PayOrderInput**](PayOrderInput.md)|  | 

### Return type

[**Order**](Order.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1OrdersPost**
> Order v1OrdersPost(orderInput)

Place an order (checkout the current cart)

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getOrdersApi();
final OrderInput orderInput = ; // OrderInput | 

try {
    final response = api.v1OrdersPost(orderInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OrdersApi->v1OrdersPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **orderInput** | [**OrderInput**](OrderInput.md)|  | 

### Return type

[**Order**](Order.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

