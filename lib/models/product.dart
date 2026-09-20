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
    // TODO:
    // 1. รับค่าจาก JSON
    // 2. แปลงข้อมูลให้ตรงกับชนิดข้อมูลของ Product
    // 3. คืนค่า Product object
    // throw UnimplementedError();
    return Product(
        id: json['id'].toString(),
        name: json['name'].toString(),
        category: json['category'].toString(),
        price: (json['price'] as num).toDouble(),
        isAvailable: json['isAvailable'] as bool
    );
  }
  Map<String, dynamic> toJson() {
    // TODO:
    // แปลง Product object เป็น Map<String, dynamic>
    // throw UnimplementedError();
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'isAvailable': isAvailable
    };
  }
}