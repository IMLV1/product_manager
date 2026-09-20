import 'package:flutter/material.dart';
import 'package:product_manager/models/product.dart';

import '../services/product_api_service.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});
  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isAvailable = true;
  bool _isSaving = false;
  final ProductApiService _apiService = ProductApiService();
  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _categoryController.text = widget.product!.category;
      _priceController.text = widget.product!.price.toString();
      _isAvailable = widget.product!.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final item = Product(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      price: double.parse(_priceController.text),
      isAvailable: _isAvailable,
    );

    try {
      if (widget.product == null) {
        await _apiService.addProduct(item);
      } else {
        await _apiService.updateProduct(item);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));

      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'แก้ไขสินค้า' : 'เพิ่มสินค้า')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'ชื่อสินค้า'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่อสินค้า';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'หมวดหมู่'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกหมวดหมู่';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'ราคา'),
                validator: (value) {
                  final price = double.tryParse(value ?? '');

                  if (price == null) {
                    return 'กรุณากรอกราคาเป็นตัวเลข';
                  }

                  if (!price.isFinite || price <= 0) {
                    return 'ราคาต้องมากกว่า 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('พร้อมจำหน่าย'),
                value: _isAvailable,
                onChanged: (value) {
                  setState(() {
                    _isAvailable = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _isSaving ? null : _saveProduct,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : Text(isEdit ? 'บันทึกการแก้ไข' : 'เพิ่มสินค้า'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
