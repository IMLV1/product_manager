import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductApiService {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL');
  final http.Client _client;
  final String _baseUrl;

  ProductApiService({http.Client? client, String? apiBaseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = apiBaseUrl ?? baseUrl;

  Uri _uri([String? id]) {
    final base = Uri.tryParse(_baseUrl);
    if (base == null ||
        !base.hasAuthority ||
        !['http', 'https'].contains(base.scheme)) {
      throw StateError(
        'Set the instructor API URL with --dart-define=API_BASE_URL=https://your-api.example',
      );
    }
    final path = base.path.replaceFirst(RegExp(r'/+$'), '');
    return base.replace(
      path: '$path/products${id == null ? '' : '/${Uri.encodeComponent(id)}'}',
    );
  }

  void close() => _client.close();
  Future<List<Product>> getProducts() async {
    try {
      final res = await _client.get(_uri());

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
      final res = await _client.post(
        _uri(),
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
      final res = await _client.put(
        _uri(product.id),
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
      final res = await _client.delete(_uri(id));

      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      rethrow;
    }
  }
}
