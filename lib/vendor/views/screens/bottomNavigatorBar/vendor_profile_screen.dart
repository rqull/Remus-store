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
  Map<String, dynamic> _orderStats = {
    'totalOrders': 0,
    'delivered': 0,
    'processing': 0,
    'cancelled': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadVendorData();
    _loadOrderStats();
  }

  Future<void> _loadOrderStats() async {
    final user = _auth.currentUser;
    if (user != null) {
      final QuerySnapshot orders = await _firestore
          .collection('orders')
          .where('vendorId', isEqualTo: user.uid)
          .get();

      int totalOrders = orders.docs.length;
      int delivered = 0;
      int processing = 0;
      int cancelled = 0;

      for (var doc in orders.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print(
            'Order ${doc.id}: delivered=${data['delivered']}, processing=${data['processing']}, cancelled=${data['cancelled']}');

        if (data['delivered'] == true) {
          delivered++;
        } else if (data['processing'] == true) {
          processing++;
        } else if (data['cancelled'] == true) {
          cancelled++;
        }
      }

      print('Total Orders: $totalOrders');
      print('Delivered: $delivered');
      print('Processing: $processing');
      print('Cancelled: $cancelled');

      setState(() {
        _orderStats = {
          'totalOrders': totalOrders,
          'delivered': delivered,
          'processing': processing,
          'cancelled': cancelled,
        };
      });
    }
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
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: null, // Don't compress PNG images
      );

      if (image == null) return;

      // Check if image is PNG
      bool isPNG = image.path.toLowerCase().endsWith('.png');

      // Create file reference
      final file = File(image.path);

      // Generate unique file name with correct extension
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = isPNG ? '.png' : '.jpg';
      final fileName = 'vendor_${_auth.currentUser!.uid}_$timestamp$extension';

      // Upload to Supabase
      final response =
          await supabase.storage.from('vendors').upload(fileName, file);

      if (response.isEmpty) {
        throw Exception('Failed to upload image');
      }

      // Get the public URL
      final imageUrl = supabase.storage.from('vendors').getPublicUrl(fileName);

      // Update Firestore
      await _firestore
          .collection('vendors')
          .doc(_auth.currentUser!.uid)
          .update({'storeImage': imageUrl});

      setState(() {
        _storeImage = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Store image updated successfully')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update store image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Store Profile',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _storeImage != null &&
                            _storeImage!.isNotEmpty &&
                            _storeImage!.startsWith('http')
                        ? CachedNetworkImageProvider(_storeImage!)
                        : null,
                    child: _storeImage == null ||
                            _storeImage!.isEmpty ||
                            !_storeImage!.startsWith('http')
                        ? Icon(Icons.store, size: 60, color: Colors.grey[400])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 20,
                      child: IconButton(
                        icon: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _isLoading ? null : _pickAndUploadImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard('Store Name', _storeName ?? 'Not set'),
            const SizedBox(height: 12),
            _buildInfoCard('Email', _email ?? 'Not set'),
            const SizedBox(height: 12),
            _buildInfoCard('Location',
                '${_locality ?? ''}, ${_city ?? ''}, ${_state ?? 'Not set'}'),
            const SizedBox(height: 24),
            Text(
              'Order Statistics',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Orders',
                    _orderStats['totalOrders'].toString(),
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Delivered',
                    _orderStats['delivered'].toString(),
                    Icons.check_circle,
                    Color(0xFF3C55EF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Processing',
                    _orderStats['processing'].toString(),
                    Icons.pending,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Cancelled',
                    _orderStats['cancelled'].toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
