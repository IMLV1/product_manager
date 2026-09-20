import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_manager/models/product.dart';
import 'package:product_manager/services/product_api_service.dart';
import 'package:product_manager/views/product_list_page.dart';
import 'package:product_manager/views/product_form_page.dart';

void main() {
  final json = {
    'id': 'p1',
    'name': 'Mouse',
    'category': 'Accessories',
    'price': 100,
    'isAvailable': true,
  };
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Product converts integer prices and round trips JSON', () {
    final product = Product.fromJson(json);
    expect(product.price, isA<double>());
    expect(Product.fromJson(product.toJson()).name, 'Mouse');
  });

  test('CRUD uses the expected endpoints and JSON payloads', () async {
    final methods = <String>[];
    final api = ProductApiService(
      apiBaseUrl: 'https://example.test/api/',
      client: MockClient((request) async {
        methods.add(request.method);
        expect(
          request.url.path,
          request.method == 'PUT' || request.method == 'DELETE'
              ? '/api/products/p1'
              : '/api/products',
        );
        if (request.method == 'DELETE') return http.Response('', 204);
        if (request.method == 'GET') {
          return http.Response(jsonEncode([json]), 200);
        }
        expect(jsonDecode(request.body)['name'], 'Mouse');
        expect(request.headers['content-type'], contains('application/json'));
        return http.Response(
          jsonEncode(json),
          request.method == 'POST' ? 201 : 200,
        );
      }),
    );
    addTearDown(api.close);
    expect(await api.getProducts(), hasLength(1));
    await api.addProduct(Product.fromJson(json));
    await api.updateProduct(Product.fromJson(json));
    await api.deleteProduct('p1');
    expect(methods, ['GET', 'POST', 'PUT', 'DELETE']);
  });

  testWidgets('Failed swipe deletion preserves the product', (tester) async {
    final api = ProductApiService(
      apiBaseUrl: 'https://example.test',
      client: MockClient(
        (request) async => request.method == 'DELETE'
            ? http.Response('Failed', 500)
            : http.Response(jsonEncode([json]), 200),
      ),
    );
    addTearDown(api.close);
    await tester.pumpWidget(
      MaterialApp(home: ProductListPage(apiService: api)),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Dismissible), const Offset(-600, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Mouse'), findsOneWidget);
    expect(find.textContaining('Delete failed:'), findsOneWidget);
  });

  testWidgets('Empty products and add navigation work', (tester) async {
    final api = ProductApiService(
      apiBaseUrl: 'https://example.test',
      client: MockClient((_) async => http.Response('[]', 200)),
    );
    addTearDown(api.close);
    await tester.pumpWidget(
      MaterialApp(home: ProductListPage(apiService: api)),
    );
    await tester.pumpAndSettle();
    expect(find.text('ยังไม่มีสินค้า'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byType(ProductFormPage), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('กรุณากรอกชื่อสินค้า'), findsOneWidget);
  });
}
