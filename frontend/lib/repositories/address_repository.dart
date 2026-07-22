import '../models/address.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/result.dart';
import '../utils/exceptions.dart';
import 'dart:convert';

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
      // 1. Try to fetch from API
      final remoteAddresses = await ApiService.fetchAddresses();
      
      // 2. If successful, update local storage and return
      if (remoteAddresses.isNotEmpty) {
        final encoded = remoteAddresses.map((e) => jsonEncode(e.toJson())).toList();
        await StorageService.saveAddresses(encoded);
        return Result.success(remoteAddresses);
      }

      // 3. Fallback to local storage if remote is empty or fails
      final localData = await StorageService.getAddresses();
      final localAddresses = localData.map((e) => Address.fromJson(jsonDecode(e))).toList();
      return Result.success(localAddresses);
    } catch (e) {
      // 4. On error, try local storage as a last resort
      try {
        final localData = await StorageService.getAddresses();
        final localAddresses = localData.map((e) => Address.fromJson(jsonDecode(e))).toList();
        return Result.success(localAddresses);
      } catch (localError) {
        return Result.failure(FetchDataException('Failed to load addresses'));
      }
    }
  }

  @override
  Future<Result<Address>> addAddress(Address address) async {
    try {
      final savedAddress = await ApiService.saveAddress(address);
      if (savedAddress != null) {
        // Update local storage after remote success
        final currentLocal = await getAddresses();
        if (currentLocal.isSuccess) {
          final list = currentLocal.valueOrNull ?? [];
          list.add(savedAddress);
          await StorageService.saveAddresses(list.map((e) => jsonEncode(e.toJson())).toList());
        }
        return Result.success(savedAddress);
      }
      return Result.failure(AppException('Failed to save address to server'));
    } catch (e) {
      return Result.failure(FetchDataException('Network error while saving address'));
    }
  }

  @override
  Future<Result<void>> deleteAddress(String id) async {
    try {
      await ApiService.deleteAddress(id);
      
      // Update local
      final currentLocal = await getAddresses();
      if (currentLocal.isSuccess) {
        final list = currentLocal.valueOrNull ?? [];
        list.removeWhere((element) => element.id == id);
        await StorageService.saveAddresses(list.map((e) => jsonEncode(e.toJson())).toList());
      }
      return const Result.success(null);
    } catch (e) {
      return Result.failure(FetchDataException('Failed to delete address'));
    }
  }

  @override
  Future<Result<void>> updateAddress(Address address) async {
    // Similar to addAddress
    return addAddress(address).then((value) => value.isSuccess 
      ? const Result.success(null) 
      : Result.failure(value.exceptionOrNull!));
  }

  @override
  Future<Result<void>> setDefaultAddress(String id) async {
    try {
      // In a real app, this might be an API call PATCH /addresses/{id}/default
      // For now, we update local and could potentially sync
      final currentLocal = await getAddresses();
      if (currentLocal.isSuccess) {
        final list = currentLocal.valueOrNull ?? [];
        final updatedList = list.map((addr) {
          return addr.copyWith(isDefault: addr.id == id);
        }).toList();
        await StorageService.saveAddresses(updatedList.map((e) => jsonEncode(e.toJson())).toList());
        // TODO: Sync with API
      }
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppException('Failed to set default address'));
    }
  }
}
