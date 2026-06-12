# e_shop_api.api.AuthApi

## Load the API package
```dart
import 'package:e_shop_api/api.dart';
```

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**v1AuthRequestOtpPost**](AuthApi.md#v1authrequestotppost) | **POST** /v1/auth/request-otp | Request OTP via phone
[**v1AuthVerifyOtpPost**](AuthApi.md#v1authverifyotppost) | **POST** /v1/auth/verify-otp | Verify OTP and receive JWT


# **v1AuthRequestOtpPost**
> v1AuthRequestOtpPost(v1AuthRequestOtpPostRequest)

Request OTP via phone

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getAuthApi();
final V1AuthRequestOtpPostRequest v1AuthRequestOtpPostRequest = ; // V1AuthRequestOtpPostRequest | 

try {
    api.v1AuthRequestOtpPost(v1AuthRequestOtpPostRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->v1AuthRequestOtpPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **v1AuthRequestOtpPostRequest** | [**V1AuthRequestOtpPostRequest**](V1AuthRequestOtpPostRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1AuthVerifyOtpPost**
> v1AuthVerifyOtpPost(v1AuthVerifyOtpPostRequest)

Verify OTP and receive JWT

### Example
```dart
import 'package:e_shop_api/api.dart';

final api = EShopApi().getAuthApi();
final V1AuthVerifyOtpPostRequest v1AuthVerifyOtpPostRequest = ; // V1AuthVerifyOtpPostRequest | 

try {
    api.v1AuthVerifyOtpPost(v1AuthVerifyOtpPostRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->v1AuthVerifyOtpPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **v1AuthVerifyOtpPostRequest** | [**V1AuthVerifyOtpPostRequest**](V1AuthVerifyOtpPostRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

