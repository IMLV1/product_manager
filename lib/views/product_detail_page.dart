import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_api_service.dart';
import 'product_form_page.dart';

Future<bool> confirmProductDelete(
  BuildContext context,
  Product product,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบสินค้า'),
        content: Text('ต้องการลบ ${product.name} หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    ) ??
    false;

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});
  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _api = ProductApiService();
  bool _busy = false;
  Future<void> _edit() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormPage(product: widget.product),
      ),
    );
    if (!mounted) return;
    if (changed == true) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    if (!await confirmProductDelete(context, widget.product) || !mounted) {
      return;
    }
    setState(() => _busy = true);
    try {
      await _api.deleteProduct(widget.product.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ลบสินค้าไม่สำเร็จ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดสินค้า')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
          ListTile(
            title: const Text('หมวดหมู่'),
            subtitle: Text(product.category),
          ),
          ListTile(
            title: const Text('ราคา'),
            subtitle: Text('${product.price.toStringAsFixed(2)} บาท'),
          ),
          ListTile(
            title: const Text('สถานะพร้อมจำหน่าย'),
            subtitle: Text(
              product.isAvailable ? 'พร้อมจำหน่าย' : 'ไม่พร้อมจำหน่าย',
            ),
          ),
          ElevatedButton(
            onPressed: _busy ? null : _edit,
            child: const Text('แก้ไข'),
          ),
          TextButton(
            onPressed: _busy ? null : _delete,
            child: const Text('ลบ'),
          ),
          if (_busy) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
