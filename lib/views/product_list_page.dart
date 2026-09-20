import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_api_service.dart';
import '../services/preference_service.dart';
import '../services/file_service.dart';
import '../services/secure_storage_service.dart';
import 'product_form_page.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductApiService _apiService = ProductApiService();
  final _preferences = PreferenceService();
  final _files = FileService();
  late Future<List<Product>> _productFuture;
  String? _username;
  bool _backupBusy = false;

  @override
  void initState() {
    super.initState();
    _productFuture = _apiService.getProducts();
    _loadUsername();
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
    await showDialog<void>(
      context: context,
      builder: (_) => const _UserSettingsDialog(),
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
                    confirmDismiss: (direction) async {
                      return confirmProductDelete(context, product);
                    },
                    onDismissed: (direction) async {
                      setState(
                        () =>
                            items.removeWhere((item) => item.id == product.id),
                      );
                      try {
                        await _apiService.deleteProduct(product.id);
                        if (!mounted) return;
                        _message('ลบสินค้าแล้ว');
                      } catch (e) {
                        if (!mounted) return;
                        _message('ลบสินค้าไม่สำเร็จ: $e');
                        _reloadProducts();
                      }
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

class _UserSettingsDialog extends StatefulWidget {
  const _UserSettingsDialog();

  @override
  State<_UserSettingsDialog> createState() => _UserSettingsDialogState();
}

class _UserSettingsDialogState extends State<_UserSettingsDialog> {
  final _preferences = PreferenceService();
  final _secure = SecureStorageService();
  final _username = TextEditingController();
  final _token = TextEditingController();
  bool _busy = true;
  bool _hasToken = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _username.dispose();
    _token.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final username = await _preferences.getUsername();
      final token = await _secure.getToken();
      if (!mounted) return;
      _username.text = username ?? '';
      setState(() => _hasToken = token != null && token.isNotEmpty);
    } catch (_) {
      if (mounted) setState(() => _message = 'อ่านข้อมูลไม่สำเร็จ');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save(bool token, bool remove) async {
    final value = (token ? _token.text : _username.text).trim();
    if (!remove && value.isEmpty) {
      setState(() => _message = 'กรุณากรอกข้อมูล');
      return;
    }
    setState(() => _busy = true);
    try {
      if (token) {
        if (remove) {
          await _secure.deleteToken();
        } else {
          await _secure.saveToken(value);
        }
      } else {
        if (remove) {
          await _preferences.removeUsername();
        } else {
          await _preferences.saveUsername(value);
        }
      }
      if (!mounted) return;
      setState(() {
        if (token) {
          _hasToken = !remove;
          _token.clear();
        } else if (remove) {
          _username.clear();
        }
        _message = remove ? 'ลบข้อมูลแล้ว' : 'บันทึกข้อมูลแล้ว';
      });
    } catch (_) {
      if (mounted) setState(() => _message = 'ดำเนินการไม่สำเร็จ กรุณาลองใหม่');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('ชื่อผู้ใช้และ Token จำลอง'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _username,
            enabled: !_busy,
            decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้'),
          ),
          TextButton(
            onPressed: _busy ? null : () => _save(false, false),
            child: const Text('บันทึกชื่อผู้ใช้'),
          ),
          TextButton(
            onPressed: _busy ? null : () => _save(false, true),
            child: const Text('ล้างชื่อผู้ใช้'),
          ),
          const Divider(),
          Text(_hasToken ? 'Token ถูกบันทึกแล้ว' : 'ยังไม่มี Token'),
          TextField(
            controller: _token,
            enabled: !_busy,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Token จำลอง'),
          ),
          TextButton(
            onPressed: _busy ? null : () => _save(true, false),
            child: const Text('บันทึก Token'),
          ),
          TextButton(
            onPressed: _busy ? null : () => _save(true, true),
            child: const Text('ลบ Token'),
          ),
          if (_message != null) Text(_message!),
          if (_busy) const CircularProgressIndicator(),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('ปิด'),
      ),
    ],
  );
}
