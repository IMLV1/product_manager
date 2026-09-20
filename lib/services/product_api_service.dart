import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductApiService {
  // ใส่ URL ของ API ที่อาจารย์กำหนด
  static const String baseUrl = '';

  Future<List<Product>> getProducts() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/products'));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        return data
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> addProduct(Product product) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(product.toJson()),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return Product.fromJson(jsonDecode(res.body));
      } else {
        throw Exception('Failed to add product');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> updateProduct(Product product) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(product.toJson()),
      );

      if (res.statusCode == 200) {
        return Product.fromJson(jsonDecode(res.body));
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/products/$id'));

      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      rethrow;
    }
  }
}
