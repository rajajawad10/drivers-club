class CartItem {
  final String id;
  final String title;
  final String type;
  final String image;
  final String subtitle;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.type,
    required this.image,
    required this.subtitle,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'image': image,
      'subtitle': subtitle,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
