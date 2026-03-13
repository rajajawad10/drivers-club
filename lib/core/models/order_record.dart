class OrderRecord {
  final String id;
  final String date;
  final String itemSummary;
  final String price;
  final String status;

  OrderRecord({
    required this.id,
    required this.date,
    required this.itemSummary,
    required this.price,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'itemSummary': itemSummary,
      'price': price,
      'status': status,
    };
  }

  factory OrderRecord.fromMap(Map<String, dynamic> map) {
    return OrderRecord(
      id: map['id']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      itemSummary: map['itemSummary']?.toString() ?? '',
      price: map['price']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
    );
  }
}
