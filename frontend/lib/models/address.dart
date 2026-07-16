class Address {
  final String id;
  final String label; // Home, Office, etc.
  final String fullAddress;
  final String city;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'fullAddress': fullAddress,
      'city': city,
      'isDefault': isDefault,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      label: json['label'],
      fullAddress: json['fullAddress'],
      city: json['city'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Address copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? city,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
