import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../.env/product_key.dart';

class UploadProductScreen extends StatefulWidget {
  const UploadProductScreen({super.key});

  @override
  State<UploadProductScreen> createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final SupabaseClient _productSupabase;

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final List<File> _images = [];
  String? selectedCategory;
  bool _isLoading = false;
  List<String> categories = [];
  final List<String> _sizesList = [];
  bool _isEntered = false;

  @override
  void initState() {
    super.initState();
    _initSupabase();
    _fetchCategories();
  }

  void _initSupabase() {
    _productSupabase = SupabaseClient(ProductKey.url, ProductKey.productKey);
  }

  @override
  void dispose() {
    _productSupabase.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    _productDescriptionController.dispose();
    _sizeController.dispose();
    _discountController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection('categories').get();
      setState(() {
        categories = querySnapshot.docs
            .map((doc) =>
                (doc.data() as Map<String, dynamic>)['categoryName']
                    ?.toString() ??
                '')
            .where((name) => name.isNotEmpty)
            .toList();
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final List<XFile> pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _images.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<List<String>> _uploadProductImagesToSupabase() async {
    try {
      if (_images.isEmpty) return [];

      List<String> productImages = [];
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String sanitizedName =
          _productNameController.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

      for (int i = 0; i < _images.length; i++) {
        final bytes = await _images[i].readAsBytes();
        final String newFileName = '${timestamp}_${sanitizedName}_$i.png';
        final String path = 'products/$newFileName';

        try {
          await _productSupabase.storage.from('products').uploadBinary(
                path,
                bytes,
                fileOptions:
                    const FileOptions(contentType: 'image/png', upsert: true),
              );

          final String productUrl =
              _productSupabase.storage.from('products').getPublicUrl(path);
          productImages.add(productUrl);
        } catch (uploadError) {
          print('Error uploading to Supabase: $uploadError');
        }
      }
      return productImages;
    } catch (e) {
      print('Error in _uploadProductImagesToSupabase: $e');
      return [];
    }
  }

  Future<void> _uploadProduct() async {
    if (_productNameController.text.isEmpty ||
        _productPriceController.text.isEmpty ||
        _productDescriptionController.text.isEmpty ||
        _discountController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        selectedCategory == null ||
        _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please fill all fields and select at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);
    EasyLoading.show(status: 'Uploading Product...');

    try {
      final List<String> productImages = await _uploadProductImagesToSupabase();
      final docRef = await _firestore.collection('products').add({
        'vendorId': FirebaseAuth.instance.currentUser!.uid,
        'productName': _productNameController.text,
        'productPrice': double.parse(_productPriceController.text),
        'description': _productDescriptionController.text,
        'category': selectedCategory,
        'productImages': productImages,
        'sizes': _sizesList,
        'discount': int.parse(_discountController.text),
        'quantity': int.parse(_quantityController.text),
        'rating': 0,
        'totalReviews': 0,
        'uploadDate': DateTime.now(),
        'isVendorProduct': true,
        'productId': '', // Will be updated below
      });

      await docRef.update({'productId': docRef.id});

      setState(() {
        _productNameController.clear();
        _productPriceController.clear();
        _productDescriptionController.clear();
        _discountController.clear();
        _quantityController.clear();
        selectedCategory = null;
        _images.clear();
        _sizesList.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading product: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _images.isEmpty
                  ? Center(
                      child: TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Images'),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _images.length) {
                          return Center(
                            child: IconButton(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.add_photo_alternate),
                            ),
                          );
                        }
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Image.file(_images[index],
                                  height: 140, width: 140, fit: BoxFit.cover),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () =>
                                    setState(() => _images.removeAt(index)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // Form Fields
            TextField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _productPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Discount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _productDescriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Size Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sizeController,
                    decoration: const InputDecoration(
                      labelText: 'Size',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        setState(() => _isEntered = value.isNotEmpty),
                  ),
                ),
                if (_isEntered) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _sizesList.add(_sizeController.text);
                        _sizeController.clear();
                        _isEntered = false;
                      });
                    },
                    child: const Text('Add'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Size Chips
            if (_sizesList.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _sizesList.map((size) {
                  return Chip(
                    label: Text(size),
                    onDeleted: () => setState(() => _sizesList.remove(size)),
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedCategory = value),
            ),
            const SizedBox(height: 24),

            // Upload Button
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_isLoading ? 'Uploading...' : 'Upload Product'),
            ),
          ],
        ),
      ),
    );
  }
}
