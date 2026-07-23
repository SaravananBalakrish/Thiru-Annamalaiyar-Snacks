import 'package:flutter/foundation.dart';
import '../models/address.dart';
import '../repositories/address_repository.dart';
import '../utils/error_handler_mixin.dart';

class AddressController extends ChangeNotifier with ErrorHandlerMixin {
  final IAddressRepository _repository;
  
  List<Address> _addresses = [];
  Address? _selectedAddress;

  List<Address> get addresses => _addresses;
  Address? get selectedAddress => _selectedAddress;

  AddressController({IAddressRepository? repository}) 
      : _repository = repository ?? AddressRepository() {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    final result = await runSafeResult(() async {
      final r = await _repository.getAddresses();
      return r.fold((value) => value, (exception) => throw exception);
    });
    
    if (result.isSuccess) {
      _addresses = result.valueOrNull!;
      await _initSelectedAddress();
    }
  }

  Future<void> _initSelectedAddress() async {
    final selectedResult = await _repository.getSelectedAddress();
    final selected = selectedResult.getOrDefault(null);
    
    if (selected != null && _addresses.any((a) => a.id == selected.id)) {
      _selectedAddress = _addresses.firstWhere((a) => a.id == selected.id);
    } else if (_addresses.isNotEmpty) {
      try {
        _selectedAddress = _addresses.firstWhere((a) => a.isDefault);
      } catch (_) {
        _selectedAddress = _addresses.first;
      }
    } else {
      _selectedAddress = null;
    }
    notifyListeners();
  }

  Future<void> setSelectedAddress(Address address) async {
    _selectedAddress = address;
    notifyListeners();
    await _repository.setSelectedAddress(address.id);
  }

  Future<void> addAddress(String label, String street, String city,
      {String? fullName, String? phoneNumber, String? landmark, String? state, String? zipCode, double? latitude, double? longitude}) async {
    final newAddress = Address(
      id: '',
      label: label,
      fullName: fullName ?? 'User',
      phoneNumber: phoneNumber ?? '',
      street: street,
      landmark: landmark,
      city: city,
      state: state ?? 'Tamil Nadu',
      zipCode: zipCode ?? '',
      isDefault: _addresses.isEmpty,
      latitude: latitude,
      longitude: longitude,
    );
    
    final result = await runSafeResult(() async {
      final r = await _repository.addAddress(newAddress);
      return r.fold((value) => value, (exception) => throw exception);
    });
    
    if (result.isSuccess) {
      final saved = result.valueOrNull!;
      _addresses.add(saved);
      if (_selectedAddress == null) {
        await setSelectedAddress(saved);
      } else {
        notifyListeners();
      }
    }
  }

  Future<void> updateAddress(Address address) async {
    final result = await runSafeResult(() async {
      final r = await _repository.updateAddress(address);
      return r.fold((value) => value, (exception) => throw exception);
    });
    
    if (result.isSuccess) {
      final updated = result.valueOrNull!;
      final index = _addresses.indexWhere((a) => a.id == updated.id);
      if (index != -1) {
        _addresses[index] = updated;
        if (_selectedAddress?.id == updated.id) {
          _selectedAddress = updated;
        }
        notifyListeners();
      }
    }
  }

  Future<void> deleteAddress(String id) async {
    final result = await runSafeResult(() async {
      final r = await _repository.deleteAddress(id);
      return r.fold((value) => value, (exception) => throw exception);
    });
    
    if (result.isSuccess) {
      _addresses.removeWhere((element) => element.id == id);
      if (_selectedAddress?.id == id) {
        _selectedAddress = null;
        await _initSelectedAddress();
      } else {
        notifyListeners();
      }
    }
  }

  Future<void> setDefault(String id) async {
    final result = await runSafeResult(() async {
      final r = await _repository.setDefaultAddress(id);
      return r.fold((value) => value, (exception) => throw exception);
    });
    
    if (result.isSuccess) {
      _addresses = _addresses.map((addr) {
        return addr.copyWith(isDefault: addr.id == id);
      }).toList();
      notifyListeners();
      // Optionally update selected address to the new default if preferred
      try {
        final newDefault = _addresses.firstWhere((a) => a.id == id);
        await setSelectedAddress(newDefault);
      } catch (_) {}
    }
  }
}
