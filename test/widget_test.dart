import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_manager/views/product_form_page.dart';

void main() {
  testWidgets('Product form requires name, category and a valid price', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProductFormPage()));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('กรุณากรอกชื่อสินค้า'), findsOneWidget);
    expect(find.text('กรุณากรอกหมวดหมู่'), findsOneWidget);
    expect(find.text('กรุณากรอกราคาเป็นตัวเลข'), findsOneWidget);
  });
}
