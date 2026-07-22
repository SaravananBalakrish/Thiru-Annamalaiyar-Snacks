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
    
    result.ifSuccess((data) {
      _addresses = data;
      _updateSelectedAddress();
    });
  }

  void _updateSelectedAddress() {
    if (_addresses.isNotEmpty) {
      try {
        _selectedAddress = _addresses.firstWhere((a) => a.isDefault);
      } catch (_) {
        _selectedAddress = _addresses.first;
      }
    } else {
      _selectedAddress = null;
    }
  }

  void setSelectedAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<void> addAddress(String label, String street, String city,
      {String? fullName, String? phoneNumber, String? landmark, String? state, String? zipCode, double? latitude, double? longitude}) async {
    final newAddress = Address(
      id: '', // Backend will generate ID
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
    
    result.ifSuccess((saved) {
      _addresses.add(saved);
      _selectedAddress ??= saved;
    });
  }

  Future<void> deleteAddress(String id) async {
    final result = await runSafeResult(() async {
      final r = await _repository.deleteAddress(id);
      return r.fold((value) => value, (exception) => throw exception);
    });
    
    result.ifSuccess((_) {
      _addresses.removeWhere((element) => element.id == id);
      if (_addresses.isNotEmpty && !_addresses.any((element) => element.isDefault)) {
        setDefault(addresses[0].id);
      } else {
         _updateSelectedAddress();
      }
    });
  }

  Future<void> setDefault(String id) async {
    final result = await runSafeResult(() async {
      final r = await _repository.setDefaultAddress(id);
      return r.fold((value) => value, (exception) => throw exception);
    });
    
    result.ifSuccess((_) {
      _addresses = _addresses.map((addr) {
        return addr.copyWith(isDefault: addr.id == id);
      }).toList();
      _updateSelectedAddress();
    });
  }
}
