import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';

class FileService {
  Future<File> _getBackupFile() async {
    // TODO:
    // 1. เรียก getApplicationDocumentsDirectory()
    // 2. สร้าง File ชืFอ products_backup.json
    // throw UnimplementedError();
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/products_backup.json');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> exportProducts(List<Product> products) async {
    // TODO:
    // 1. แปลง List<Product> เป็น List<Map<String, dynamic>>
    // 2. ใช้ jsonEncode()
    // 3. เขยี นข้อมลู ลงไฟล์
    try {
      final json = jsonEncode(products.map((e) => e.toJson()).toList());

      final file = await _getBackupFile();
      await file.writeAsString(json);
    } catch (e) {
      rethrow;
    }
  }
  Future<List<Product>> importProducts() async {
    // TODO:
    // 1. อ่านข้อมูลจากไฟล์
    // 2. ใช้ jsonDecode()
    // 3. แปลงกลับเป็น List<Product>
    // throw UnimplementedError();
    try {
      final file = await _getBackupFile();

      if (!await file.exists()) return [];

      final json = await file.readAsString();
      return jsonDecode(json).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
