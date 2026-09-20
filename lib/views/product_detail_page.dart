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
        title: const Text('Delete product?'),
        content: Text('Delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
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
  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

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
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      appBar: AppBar(title: const Text('Product details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
          ListTile(
            title: const Text('Category'),
            subtitle: Text(product.category),
          ),
          ListTile(
            title: const Text('Price'),
            subtitle: Text('${product.price.toStringAsFixed(2)} THB'),
          ),
          ListTile(
            title: const Text('Availability'),
            subtitle: Text(product.isAvailable ? 'Available' : 'Unavailable'),
          ),
          ElevatedButton(
            onPressed: _busy ? null : _edit,
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: _busy ? null : _delete,
            child: const Text('Delete'),
          ),
          if (_busy) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
