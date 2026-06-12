# e_shop_api.model.Order

## Load the model package
```dart
import 'package:e_shop_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | [optional] 
**userId** | **int** |  | [optional] 
**totalPrice** | **String** | Decimal total price (e.g. \"49.95\") | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | [optional] 
**paymentMethod** | **String** | e.g. \"gpay\", \"phonepe\", \"upi\" | [optional] 
**paymentStatus** | **String** | e.g. \"pending\", \"paid\" | [optional] 
**transactionRef** | **String** | UPI transaction reference / UTR number | [optional] 
**upiUri** | **String** | UPI deep link for GPay/PhonePe | [optional] 
**qrCodeUrl** | **String** | URL to the scan-and-pay QR code | [optional] 
**items** | [**BuiltList&lt;OrderItem&gt;**](OrderItem.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


