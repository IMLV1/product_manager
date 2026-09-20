class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final bool isAvailable;
  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.isAvailable,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      price: ((json['price'] ?? 0) as num).toDouble(),
      isAvailable: (json['isAvailable'] as bool?) ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'isAvailable': isAvailable,
    };
  }
}
