# e_shop_api.api.ProductsApi

## Load the API package
```dart
import 'package:e_shop_api/api.dart';
```

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**v1ProductsGet**](ProductsApi.md#v1productsget) | **GET** /v1/products | List all products
[**v1ProductsIdDelete**](ProductsApi.md#v1productsiddelete) | **DELETE** /v1/products/{id} | Delete a product
[**v1ProductsIdGet**](ProductsApi.md#v1productsidget) | **GET** /v1/products/{id} | Get a product by ID
[**v1ProductsIdPut**](ProductsApi.md#v1productsidput) | **PUT** /v1/products/{id} | Update a product
[**v1ProductsPost**](ProductsApi.md#v1productspost) | **POST** /v1/products | Create a new product


# **v1ProductsGet**
> BuiltList<Product> v1ProductsGet()

List all products

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getProductsApi();

try {
    final response = api.v1ProductsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProductsApi->v1ProductsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Product&gt;**](Product.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1ProductsIdDelete**
> v1ProductsIdDelete(id)

Delete a product

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getProductsApi();
final int id = 56; // int | 

try {
    api.v1ProductsIdDelete(id);
} on DioException catch (e) {
    print('Exception when calling ProductsApi->v1ProductsIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1ProductsIdGet**
> Product v1ProductsIdGet(id)

Get a product by ID

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getProductsApi();
final int id = 56; // int | 

try {
    final response = api.v1ProductsIdGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProductsApi->v1ProductsIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Product**](Product.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1ProductsIdPut**
> Product v1ProductsIdPut(id, productInput)

Update a product

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getProductsApi();
final int id = 56; // int | 
final ProductInput productInput = ; // ProductInput | 

try {
    final response = api.v1ProductsIdPut(id, productInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProductsApi->v1ProductsIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **productInput** | [**ProductInput**](ProductInput.md)|  | 

### Return type

[**Product**](Product.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1ProductsPost**
> Product v1ProductsPost(productInput)

Create a new product

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getProductsApi();
final ProductInput productInput = ; // ProductInput | 

try {
    final response = api.v1ProductsPost(productInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProductsApi->v1ProductsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **productInput** | [**ProductInput**](ProductInput.md)|  | 

### Return type

[**Product**](Product.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

