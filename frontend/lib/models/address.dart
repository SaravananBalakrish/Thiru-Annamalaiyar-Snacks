class Address {
  final String id;
  final String label; // Home, Office, etc.
  final String fullName;
  final String phoneNumber;
  final String street;
  final String? landmark;
  final String city;
  final String state;
  final String zipCode;
  final bool isDefault;
  final num? latitude;
  final num? longitude;

  Address({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phoneNumber,
    required this.street,
    this.landmark,
    required this.city,
    required this.state,
    required this.zipCode,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  String get fullAddress => "$street${landmark != null ? ', $landmark' : ''}, $city, $state - $zipCode";

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'street': street,
      'landmark': landmark,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'].toString(),
      label: json['label'] ?? 'Other',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      street: json['street'] ?? json['fullAddress'] ?? '',
      landmark: json['landmark'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      isDefault: json['isDefault'] ?? false,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Address copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phoneNumber,
    String? street,
    String? landmark,
    String? city,
    String? state,
    String? zipCode,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      street: street ?? this.street,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
