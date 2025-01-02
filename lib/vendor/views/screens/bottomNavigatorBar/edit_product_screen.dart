import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../.env/product_key.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final SupabaseClient _productSupabase;
  final String _vendorId = FirebaseAuth.instance.currentUser!.uid;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initSupabase();
  }

  void _initSupabase() {
    _productSupabase = SupabaseClient(ProductKey.url, ProductKey.productKey);
  }

  @override
  void dispose() {
    _productSupabase.dispose();
    super.dispose();
  }

  Future<void> _updateProduct(
      String productId, Map<String, dynamic> data) async {
    try {
      EasyLoading.show(status: 'Updating Product...');

      // Add isVendorProduct field
      data['isVendorProduct'] = true;

      await _firestore.collection('products').doc(productId).update(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> _deleteProduct(
      String productId, List<String> productImages) async {
    try {
      // Delete images from Supabase
      for (String imageUrl in productImages) {
        final Uri uri = Uri.parse(imageUrl);
        final String fileName = uri.pathSegments.last;
        await _productSupabase.storage
            .from('products')
            .remove(['products/$fileName']);
      }

      // Delete from Firestore
      await _firestore.collection('products').doc(productId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  Future<void> _editProduct(
      String productId, Map<String, dynamic> currentData) async {
    final TextEditingController nameController =
        TextEditingController(text: currentData['productName']);
    final TextEditingController priceController =
        TextEditingController(text: currentData['productPrice'].toString());
    final TextEditingController discountController =
        TextEditingController(text: currentData['discount'].toString());
    final TextEditingController descriptionController =
        TextEditingController(text: currentData['description'] ?? '');
    final List<String> currentImages =
        List<String>.from(currentData['productImages']);
    final List<File> newImages = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Edit Product',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),

                // Current Images
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...currentImages.asMap().entries.map((entry) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Image.network(entry.value,
                                  height: 100, width: 100, fit: BoxFit.cover),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    currentImages.removeAt(entry.key);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                      // Add new images
                      ...newImages.map((file) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Image.file(file,
                                  height: 100, width: 100, fit: BoxFit.cover),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    newImages.remove(file);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                      // Add button
                      IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final List<XFile> pickedFiles =
                              await picker.pickMultiImage();
                          if (pickedFiles.isNotEmpty) {
                            setState(() {
                              newImages.addAll(
                                  pickedFiles.map((file) => File(file.path)));
                            });
                          }
                        },
                        icon: const Icon(Icons.add_photo_alternate),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Discount',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () async {
                    // Upload new images if any
                    List<String> allImages = [...currentImages];
                    if (newImages.isNotEmpty) {
                      EasyLoading.show(status: 'Uploading new images...');
                      for (var file in newImages) {
                        final bytes = await file.readAsBytes();
                        final String timestamp =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        final String path =
                            'products/${timestamp}_${file.path.split('/').last}';

                        await _productSupabase.storage
                            .from('products')
                            .uploadBinary(
                              path,
                              bytes,
                              fileOptions: const FileOptions(
                                  contentType: 'image/png', upsert: true),
                            );

                        final String imageUrl = _productSupabase.storage
                            .from('products')
                            .getPublicUrl(path);
                        allImages.add(imageUrl);
                      }
                      EasyLoading.dismiss();
                    }

                    // Update product data
                    await _updateProduct(productId, {
                      'productName': nameController.text,
                      'productPrice': double.parse(priceController.text),
                      'discount': double.parse(discountController.text),
                      'description': descriptionController.text,
                      'productImages': allImages,
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Save Changes'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateAllVendorProducts() async {
    try {
      EasyLoading.show(status: 'Updating All Products...');

      // Get current vendor's ID
      final vendorId = FirebaseAuth.instance.currentUser?.uid;
      if (vendorId == null) return;

      // Get all products from this vendor
      final querySnapshot = await _firestore
          .collection('products')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      // Update each product
      for (var doc in querySnapshot.docs) {
        await _firestore.collection('products').doc(doc.id).update({
          'isVendorProduct': true,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All products updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating products: $e')),
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.update),
            onPressed: _updateAllVendorProducts,
            tooltip: 'Update All Products',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('products')
                  .where('vendorId', isEqualTo: _vendorId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name =
                      data['productName']?.toString().toLowerCase() ?? '';
                  final searchLower = _searchQuery.toLowerCase();
                  return name.contains(searchLower);
                }).toList();

                if (products.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final doc = products[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final List<String> images =
                        List<String>.from(data['productImages'] ?? []);

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: images.isNotEmpty
                            ? Image.network(images[0],
                                width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported),
                        title: Text(data['productName'] ?? 'No name'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '\$${data['productPrice']} - \$${data['discount']} off'),
                            if (data['description'] != null)
                              Text(
                                data['description'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editProduct(doc.id, data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(doc.id, images),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
