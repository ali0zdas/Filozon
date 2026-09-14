class Address {
  Address.empty()
      : id = '',
        title = '',
        province = '',
        district = '',
        neighborhood = '',
        street = '',
        phoneNumber = '';
  String? id;
  String title;
  String province;
  String district;
  String neighborhood;
  String street;
  String phoneNumber;

  Address({
    this.id,
    required this.title,
    required this.province,
    required this.district,
    required this.neighborhood,
    required this.street,
    required this.phoneNumber,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      province: map['province'] ?? '',
      district: map['district'] ?? '',
      neighborhood: map['neighborhood'] ?? '',
      street: map['street'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'province': province,
      'district': district,
      'neighborhood': neighborhood,
      'street': street,
      'phoneNumber': phoneNumber,
    };
  }
}
