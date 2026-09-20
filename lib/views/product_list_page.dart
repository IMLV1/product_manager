import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_api_service.dart';
import '../services/preference_service.dart';
import '../services/file_service.dart';
import 'product_form_page.dart';
import 'product_detail_page.dart';
import 'settings_page.dart';

class ProductListPage extends StatefulWidget {
  final ProductApiService? apiService;
  const ProductListPage({super.key, this.apiService});
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final ProductApiService _apiService;
  final _preferences = PreferenceService();
  final _files = FileService();
  late Future<List<Product>> _productFuture;
  String? _username;
  bool _backupBusy = false;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ProductApiService();
    _productFuture = _apiService.getProducts();
    _loadUsername();
  }

  @override
  void dispose() {
    if (widget.apiService == null) _apiService.close();
    super.dispose();
  }

  void _message(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _loadUsername() async {
    try {
      final name = await _preferences.getUsername();
      if (!mounted) return;
      setState(() => _username = name);
    } catch (_) {
      _message('Could not read username.');
    }
  }

  void _reloadProducts() {
    if (!mounted) return;
    setState(() => _productFuture = _apiService.getProducts());
  }

  Future<void> _open(Widget page) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (!mounted) return;
    if (changed == true) _reloadProducts();
  }

  Future<void> _settings() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
    if (!mounted) return;
    await _loadUsername();
  }

  Future<void> _backup(bool export) async {
    setState(() => _backupBusy = true);
    try {
      if (export) {
        final products = await _productFuture;
        await _files.exportProducts(products);
        _message(
          'Exported ${products.length} products to products_backup.json',
        );
      } else {
        final products = await _files.importProducts();
        _message('Backup contains ${products.length} products.');
      }
    } catch (e) {
      _message('Backup failed: $e');
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<bool> _delete(Product product) async {
    if (!await confirmProductDelete(context, product) || !mounted) return false;
    try {
      await _apiService.deleteProduct(product.id);
      return mounted;
    } catch (e) {
      _message('Delete failed: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Product Manager'),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: _reloadProducts,
        ),
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings),
          onPressed: _settings,
        ),
      ],
    ),
    body: Column(
      children: [
        if (_username != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('สวัสดี, $_username'),
          ),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: _backupBusy ? null : () => _backup(true),
              child: const Text('Export Backup'),
            ),
            TextButton(
              onPressed: _backupBusy ? null : () => _backup(false),
              child: const Text('Read Backup'),
            ),
          ],
        ),
        if (_backupBusy) const LinearProgressIndicator(),
        Expanded(
          child: FutureBuilder<List<Product>>(
            future: _productFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                        ElevatedButton(
                          onPressed: _reloadProducts,
                          child: const Text('ลองใหม่'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Center(child: Text('ยังไม่มีสินค้า'));
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = items[index];
                  return Dismissible(
                    key: ValueKey(product.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) => _delete(product),
                    onDismissed: (_) {
                      setState(
                        () =>
                            items.removeWhere((item) => item.id == product.id),
                      );
                      _message('Product deleted.');
                    },
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        '${product.category} • ${product.price.toStringAsFixed(2)} บาท',
                      ),
                      trailing: Icon(
                        product.isAvailable ? Icons.check_circle : Icons.cancel,
                      ),
                      onTap: () => _open(ProductDetailPage(product: product)),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _open(const ProductFormPage()),
      child: const Icon(Icons.add),
    ),
  );
}
