class CartItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  int quantity;
  CartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Product',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] as double?) ?? 0.0,
      quantity: json['quantity']?.toInt() ?? 1,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  double get totalPrice => price * quantity;
  CartItem copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
