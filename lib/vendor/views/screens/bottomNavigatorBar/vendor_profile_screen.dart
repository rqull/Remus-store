import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../views/screens/authentification_screens/login_screen.dart';

class VendorProfileScreen extends StatefulWidget {
  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final supabase = Supabase.instance.client;

  String? _storeName;
  String? _email;
  String? _storeImage;
  String? _city;
  String? _locality;
  String? _state;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  Future<void> _loadVendorData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData =
          await _firestore.collection('vendors').doc(user.uid).get();

      if (userData.exists) {
        setState(() {
          _storeName = userData.data()?['storeName'];
          _email = userData.data()?['email'];
          _storeImage = userData.data()?['storeImage'];
          _city = userData.data()?['city'];
          _locality = userData.data()?['locality'];
          _state = userData.data()?['state'];
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final user = _auth.currentUser;

        if (user != null) {
          // Upload to Supabase
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          final storageResponse =
              await supabase.storage.from('storeImages').upload(
                    'store_images/${user.uid}/$fileName',
                    file,
                    fileOptions: const FileOptions(
                      cacheControl: '3600',
                      upsert: false,
                    ),
                  );

          if (storageResponse.isEmpty) {
            throw Exception('Failed to upload image');
          }

          // Get public URL
          final imageUrl = supabase.storage
              .from('storeImages')
              .getPublicUrl('store_images/${user.uid}/$fileName');

          // Update Firestore
          await _firestore
              .collection('vendors')
              .doc(user.uid)
              .update({'storeImage': imageUrl});

          setState(() {
            _storeImage = imageUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Store image updated successfully')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update store image: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: $e')),
      );
    }
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Color(0xFF103DE5),
          size: 28,
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF103DE5),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Store Profile',
          style: GoogleFonts.nunitoSans(
            color: Color(0xFF103DE5),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xFF103DE5),
                      width: 2,
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : ClipOval(
                          child: _storeImage != null
                              ? CachedNetworkImage(
                                  imageUrl: _storeImage!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(
                                      Icons.store,
                                      size: 60,
                                      color: Colors.grey),
                                )
                              : Icon(Icons.store, size: 60, color: Colors.grey),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Color(0xFF103DE5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon:
                          Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      onPressed: _isLoading ? null : _pickAndUploadImage,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              _storeName ?? 'Loading...',
              style: GoogleFonts.nunitoSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _email ?? 'Loading...',
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Store Location',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    ListTile(
                      leading:
                          Icon(Icons.location_city, color: Color(0xFF103DE5)),
                      title: Text(_city ?? 'Loading...'),
                      subtitle: Text('City'),
                    ),
                    ListTile(
                      leading: Icon(Icons.place, color: Color(0xFF103DE5)),
                      title: Text(_locality ?? 'Loading...'),
                      subtitle: Text('Locality'),
                    ),
                    ListTile(
                      leading: Icon(Icons.map, color: Color(0xFF103DE5)),
                      title: Text(_state ?? 'Loading...'),
                      subtitle: Text('State'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Store Statistics',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('products')
                          .where('vendorId', isEqualTo: _auth.currentUser?.uid)
                          .snapshots(),
                      builder: (context, productSnapshot) {
                        if (productSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (productSnapshot.hasError) {
                          return Text('Error: ${productSnapshot.error}');
                        }

                        return StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('orders')
                              .where('vendorId',
                                  isEqualTo: _auth.currentUser?.uid)
                              .snapshots(),
                          builder: (context, orderSnapshot) {
                            if (orderSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (orderSnapshot.hasError) {
                              return Text('Error: ${orderSnapshot.error}');
                            }

                            final productCount =
                                productSnapshot.data?.docs.length ?? 0;
                            final orders = orderSnapshot.data?.docs ?? [];

                            // Calculate total earnings
                            double totalEarnings = 0;
                            int totalOrders = 0;
                            for (var order in orders) {
                              final data = order.data() as Map<String, dynamic>;
                              if (data['orderStatus'] == 'Delivered') {
                                totalOrders++;
                                final productPrice =
                                    (data['productPrice'] ?? 0).toDouble();
                                final productQuantity =
                                    (data['quantity'] ?? 0).toInt();
                                totalEarnings +=
                                    (productPrice * productQuantity);
                              }
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  icon: Icons.shopping_bag,
                                  label: 'Products',
                                  value: productCount.toString(),
                                ),
                                _buildStatItem(
                                  icon: Icons.shopping_cart,
                                  label: 'Orders',
                                  value: totalOrders.toString(),
                                ),
                                _buildStatItem(
                                  icon: Icons.attach_money,
                                  label: 'Earnings',
                                  value:
                                      '\$${totalEarnings.toStringAsFixed(0)}',
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text(
                'Logout',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }
}
