import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../authentification_screens/login_screen.dart';
import '../inner_screens/order_screen.dart';
import '../inner_screens/top_up_screen.dart';

class AccountScreen extends StatefulWidget {
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final supabase = Supabase.instance.client;

  String? _fullName;
  String? _email;
  String? _profileImageUrl;
  String? _city;
  String? _locality;
  String? _state;
  double _balance = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userData =
            await _firestore.collection('buyers').doc(user.uid).get();

        if (userData.exists) {
          setState(() {
            _fullName = userData.data()?['fullname'];
            _email = userData.data()?['email'];
            _profileImageUrl = userData.data()?['profileImage'];
            _city = userData.data()?['city'];
            _locality = userData.data()?['locality'];
            _state = userData.data()?['state'];
            _balance = (userData.data()?['balance'] ?? 0).toDouble();
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      final fileName = 'buyer_${_auth.currentUser!.uid}_$timestamp$extension';

      // Upload to Supabase
      final response =
          await supabase.storage.from('buyers').upload(fileName, file);

      if (response.isEmpty) {
        throw Exception('Failed to upload image');
      }

      // Get the public URL
      final imageUrl = supabase.storage.from('buyers').getPublicUrl(fileName);

      // Update Firestore
      await _firestore
          .collection('buyers')
          .doc(_auth.currentUser!.uid)
          .update({'profileImage': imageUrl});

      setState(() {
        _profileImageUrl = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile image updated successfully')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile image')),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Account',
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
                          child: _profileImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: _profileImageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey),
                                )
                              : Icon(Icons.person,
                                  size: 60, color: Colors.grey),
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
              _fullName ?? 'Loading...',
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
            SizedBox(height: 32),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_US',
                        symbol: '\$',
                        decimalDigits: 2,
                      ).format(_balance),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3C55EF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading:
                  Icon(Icons.shopping_bag_outlined, color: Color(0xFF103DE5)),
              title: Text(
                'My Orders',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderScreen()),
                );
              },
            ),
            Divider(),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.payment, color: Color(0xFF103DE5)),
              title: Text(
                'Top up',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TopUpScreen()),
                );
              },
            ),
            Divider(),
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
