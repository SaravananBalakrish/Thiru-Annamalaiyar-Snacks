# e_shop_api.api.CartApi

## Load the API package
```dart
import 'package:e_shop_api/api.dart';
```

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**v1CartGet**](CartApi.md#v1cartget) | **GET** /v1/cart | List cart items (with product details)
[**v1CartIdDelete**](CartApi.md#v1cartiddelete) | **DELETE** /v1/cart/{id} | Remove item from cart
[**v1CartIdPatch**](CartApi.md#v1cartidpatch) | **PATCH** /v1/cart/{id} | Update cart item quantity
[**v1CartPost**](CartApi.md#v1cartpost) | **POST** /v1/cart | Add item to cart (upserts quantity if already present)


# **v1CartGet**
> BuiltList<CartItem> v1CartGet()

List cart items (with product details)

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getCartApi();

try {
    final response = api.v1CartGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling CartApi->v1CartGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;CartItem&gt;**](CartItem.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1CartIdDelete**
> v1CartIdDelete(id)

Remove item from cart

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getCartApi();
final int id = 56; // int | 

try {
    api.v1CartIdDelete(id);
} on DioException catch (e) {
    print('Exception when calling CartApi->v1CartIdDelete: $e\n');
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

# **v1CartIdPatch**
> v1CartIdPatch(id, cartPatch)

Update cart item quantity

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getCartApi();
final int id = 56; // int | 
final CartPatch cartPatch = ; // CartPatch | 

try {
    api.v1CartIdPatch(id, cartPatch);
} on DioException catch (e) {
    print('Exception when calling CartApi->v1CartIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **cartPatch** | [**CartPatch**](CartPatch.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1CartPost**
> v1CartPost(cartAdd)

Add item to cart (upserts quantity if already present)

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getCartApi();
final CartAdd cartAdd = ; // CartAdd | 

try {
    api.v1CartPost(cartAdd);
} on DioException catch (e) {
    print('Exception when calling CartApi->v1CartPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cartAdd** | [**CartAdd**](CartAdd.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

