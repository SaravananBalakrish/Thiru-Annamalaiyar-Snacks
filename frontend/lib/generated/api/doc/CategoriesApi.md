# e_shop_api.api.CategoriesApi

## Load the API package
```dart
import 'package:e_shop_api/api.dart';
```

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**v1CategoriesGet**](CategoriesApi.md#v1categoriesget) | **GET** /v1/categories | List all categories
[**v1CategoriesIdDelete**](CategoriesApi.md#v1categoriesiddelete) | **DELETE** /v1/categories/{id} | Delete category
[**v1CategoriesIdGet**](CategoriesApi.md#v1categoriesidget) | **GET** /v1/categories/{id} | Get category by ID
[**v1CategoriesIdPut**](CategoriesApi.md#v1categoriesidput) | **PUT** /v1/categories/{id} | Update category
[**v1CategoriesPost**](CategoriesApi.md#v1categoriespost) | **POST** /v1/categories | Create a category


# **v1CategoriesGet**
> BuiltList<Category> v1CategoriesGet()

List all categories

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getCategoriesApi();

try {
    final response = api.v1CategoriesGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling CategoriesApi->v1CategoriesGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Category&gt;**](Category.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1CategoriesIdDelete**
> v1CategoriesIdDelete(id)

Delete category

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getCategoriesApi();
final int id = 56; // int | 

try {
    api.v1CategoriesIdDelete(id);
} on DioException catch (e) {
    print('Exception when calling CategoriesApi->v1CategoriesIdDelete: $e\n');
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

# **v1CategoriesIdGet**
> Category v1CategoriesIdGet(id)

Get category by ID

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getCategoriesApi();
final int id = 56; // int | 

try {
    final response = api.v1CategoriesIdGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CategoriesApi->v1CategoriesIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Category**](Category.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1CategoriesIdPut**
> Category v1CategoriesIdPut(id, categoryInput)

Update category

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getCategoriesApi();
final int id = 56; // int | 
final CategoryInput categoryInput = ; // CategoryInput | 

try {
    final response = api.v1CategoriesIdPut(id, categoryInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CategoriesApi->v1CategoriesIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **categoryInput** | [**CategoryInput**](CategoryInput.md)|  | 

### Return type

[**Category**](Category.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1CategoriesPost**
> Category v1CategoriesPost(categoryInput)

Create a category

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getCategoriesApi();
final CategoryInput categoryInput = ; // CategoryInput | 

try {
    final response = api.v1CategoriesPost(categoryInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CategoriesApi->v1CategoriesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **categoryInput** | [**CategoryInput**](CategoryInput.md)|  | 

### Return type

[**Category**](Category.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

