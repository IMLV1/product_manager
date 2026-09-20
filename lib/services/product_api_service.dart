import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductApiService {
  static const String baseUrl = '';
  Future<List<Product>> getProducts() async {
    try {
      // TODO:
      // 1. สร้าง URL สำหรับ GET /products
      // 2. เรียก http.get()
      // 3. ตรวจสอบ statusCode
      // 4. ใช้ jsonDecode() แปลง response.body
      // 5. แปลง JSON List เป็น List<Product>
      
      // throw UnimplementedError();
      final res = await http.get(Uri.parse('$baseUrl/products'));

      if (res.statusCode == 200) {
        return jsonDecode(res.body).map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      // TODO: ส่งต่อข้อผิดพลาดให้หน้าจอนำไปแสดงผล
      rethrow;
    }
  }

  Future<Product> addProduct(Product product) async {
    try {
      // TODO:
      // 1. เรียก http.post()
      // 2. กำหนด Content-Type เป็น application/json
      // 3. ส่งข้อมูล product.toJson() ด้วย jsonEncode()
      // 4. ตรวจสอบ Status Code
      // 5. แปลง Response กลับเป็น Product
      //throw UnimplementedError();

      final res = await http.post(Uri.parse('$baseUrl/products'),
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: jsonEncode(product.toJson())
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
}
