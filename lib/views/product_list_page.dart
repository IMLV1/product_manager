import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_api_service.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductApiService _apiService = ProductApiService();
  late Future<List<Product>> _productFuture;
  @override
  void initState() {
    super.initState();
    // TODO:
    // กำหนด Future สำหรับโหลดข้อมูลสินค้าเพียงครัEงแรก
    _productFuture = _apiService.getProducts();
  }

  void _reloadProducts() {
    setState(() {
      // TODO: กำหนด Future ใหม่ เพืFอโหลดข้อมูลอีกครัEง
      _productFuture = _apiService.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadProducts,
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productFuture,
        builder: (context, snapshot) {
          // TODO:
          // 1. Loading: แสดง CircularProgressIndicator
          // 2. Error: แสดงข้อความ Error และปุ่มลองใหม่
          // 3. Empty: แสดงข้อความ "ยงั ไม่มีสินค้า"
          // 4. Success: แสดง ListView.builder
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _reloadProducts,
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          } else {
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: Text('ยังไม่มีสินค้า'),
              );
            } else {
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final it = items[index];

                  return ListTile(
                    title: Text(it.name),
                    subtitle: Text('${it.category} • ${it.price.toStringAsFixed(2)} บาท'),
                    trailing: Icon(it.isAvailable ? Icons.check_circle : Icons.cancel),
                  );
                },
              );
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: ไปยังหน้าเพิFมสินค้า
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
