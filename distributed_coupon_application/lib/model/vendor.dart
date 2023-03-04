class Vendor {
  int id = 0;
  String country = "null";
  String city = "null";
  String vendorName = "null";

  Vendor();

  Vendor.create({
    required this.id,
    required this.country,
    required this.city,
    required this.vendorName,
  });

  @override
  String toString() {
    return "{id: $id, country: $country, city: $city, vendorName: $vendorName}";
  }
}
