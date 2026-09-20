import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';

class FileService {
  Future<File> _getBackupFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/products_backup.json');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> exportProducts(List<Product> products) async {
    try {
      final json = jsonEncode(products.map((e) => e.toJson()).toList());

      final file = await _getBackupFile();
      await file.writeAsString(json);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> importProducts() async {
    try {
      final file = await _getBackupFile();

      if (!await file.exists()) {
        throw const FileSystemException(
          'Backup file not found. Export a backup first.',
        );
      }

      final json = await file.readAsString();
      final data = jsonDecode(json) as List<dynamic>;
      return data
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
