class Coupon {
  int id = 0;
  int vendorID = 0;
  DateTime expiryDate = DateTime(0);
  String title = "null";
  String description = "null";
  bool isMultiuse = false;
  int quantity = 0;

  Coupon();

  Coupon.create({
    required this.id,
    required this.vendorID,
    required this.expiryDate,
    required this.title,
    required this.description,
    required this.isMultiuse,
    required this.quantity
  });

  @override
  String toString() {
    return "{id: $id, vendorID: $vendorID, expiryDate: $expiryDate, title: $title, description: $description, isMultiuse: $isMultiuse, quantity: $quantity}";
  }
}
