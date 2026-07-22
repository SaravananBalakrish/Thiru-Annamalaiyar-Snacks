import 'dart:convert';
import '../models/address.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/result.dart';
import '../utils/exceptions.dart';

abstract class IAddressRepository {
  Future<Result<List<Address>>> getAddresses();
  Future<Result<Address>> addAddress(Address address);
  Future<Result<void>> deleteAddress(String id);
  Future<Result<void>> updateAddress(Address address);
  Future<Result<void>> setDefaultAddress(String id);
}

class AddressRepository implements IAddressRepository {
  @override
  Future<Result<List<Address>>> getAddresses() async {
    try {
      final remoteAddresses = await ApiService.fetchAddresses();
      
      // Update local storage for offline use
      final encoded = remoteAddresses.map((e) => jsonEncode(e.toJson())).toList();
      await StorageService.saveAddresses(encoded);
      
      return Result.success(remoteAddresses);
    } catch (e) {
      // Fallback to local storage on network error
      try {
        final localData = await StorageService.getAddresses();
        final localAddresses = localData.map((e) => Address.fromJson(jsonDecode(e))).toList();
        return Result.success(localAddresses);
      } catch (_) {
        return Result.failure(FetchDataException('Unable to load addresses offline.'));
      }
    }
  }

  @override
  Future<Result<Address>> addAddress(Address address) async {
    try {
      final savedAddress = await ApiService.saveAddress(address);
      if (savedAddress != null) {
        await _refreshLocalCache();
        return Result.success(savedAddress);
      }
      return Result.failure(AppException('Server refused to save the address.'));
    } catch (e) {
      return Result.failure(FetchDataException('Network error while saving address.'));
    }
  }

  @override
  Future<Result<void>> deleteAddress(String id) async {
    try {
      await ApiService.deleteAddress(id);
      await _refreshLocalCache();
      return Result.success(null);
    } catch (e) {
      return Result.failure(FetchDataException('Failed to delete address.'));
    }
  }

  @override
  Future<Result<void>> updateAddress(Address address) async {
    // Backend uses POST for create/update in this implementation
    return addAddress(address).then((value) => value.isSuccess 
      ? Result.success(null)
      : Result.failure(value.exceptionOrNull!));
  }

  @override
  Future<Result<void>> setDefaultAddress(String id) async {
    try {
      await ApiService.setDefaultAddress(id);
      await _refreshLocalCache();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AppException('Failed to set default address.'));
    }
  }

  Future<void> _refreshLocalCache() async {
    try {
      final remoteAddresses = await ApiService.fetchAddresses();
      final encoded = remoteAddresses.map((e) => jsonEncode(e.toJson())).toList();
      await StorageService.saveAddresses(encoded);
    } catch (_) {
      // Ignore cache refresh errors if the main operation succeeded
    }
  }
}
