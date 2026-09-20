import 'package:flutter/material.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});
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
  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    // TODO:
    // 1. ตรวจสอบข้อมูลใน Form
    // 2. เปลีFยน _isSaving เป็น true
    // 3. สร้าง Product object
    // 4. เรียก addProduct()
    // 5. เมืFอสำเร็จ Navigator.pop(context, true)
    // 6. จัดการ Error ด้วย try-catch
    // 7. ตรวจ mounted ก่อน setState หลัง await
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เพิ3มสินค้า')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // TODO: TextFormField สำหรับชืFอสินค้า
              // TODO: TextFormField สาํ หรับหมวดหมู่
              // TODO: TextFormField สำหรับราคา
              // TODO: SwitchListTile สาํ หรับสถานะพร้อมจาํ หน่าย
              // TODO: ElevatedButton สำหรับบันทึก
            ],
          ),
        ),
      ),
    );
  }
}
