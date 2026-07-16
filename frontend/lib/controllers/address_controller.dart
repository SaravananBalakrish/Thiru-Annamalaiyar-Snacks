import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/address.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class AddressController extends ChangeNotifier {
  List<Address> _addresses = [];
  Address? _selectedAddress;

  List<Address> get addresses => _addresses;
  Address? get selectedAddress => _selectedAddress;

  AddressController() {
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final data = await StorageService.getAddresses();
    _addresses = data.map((e) => Address.fromJson(jsonDecode(e))).toList();

    // Set default selected address
    if (_addresses.isNotEmpty) {
      try {
        _selectedAddress = _addresses.firstWhere((a) => a.isDefault);
      } catch (_) {
        _selectedAddress = _addresses.first;
      }
    }
    notifyListeners();
  }

  void setSelectedAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<void> addAddress(String label, String fullAddress, String city) async {
    final newAddress = Address(
      id: const Uuid().v4(),
      label: label,
      fullAddress: fullAddress,
      city: city,
      isDefault: _addresses.isEmpty,
    );
    _addresses.add(newAddress);
    if (_selectedAddress == null) {
      _selectedAddress = newAddress;
    }
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> deleteAddress(String id) async {
    _addresses.removeWhere((element) => element.id == id);
    if (_addresses.isNotEmpty && !_addresses.any((element) => element.isDefault)) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> setDefault(String id) async {
    _addresses = _addresses.map((addr) {
      return addr.copyWith(isDefault: addr.id == id);
    }).toList();
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final data = _addresses.map((e) => jsonEncode(e.toJson())).toList();
    await StorageService.saveAddresses(data);
  }
}
