import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../authentification_screens/login_screen.dart';
import '../inner_screens/order_screen.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData =
          await _firestore.collection('buyers').doc(user.uid).get();

      if (userData.exists) {
        setState(() {
          _fullName = userData.data()?['fullname'];
          _email = userData.data()?['email'];
          _profileImageUrl = userData.data()?['profilImage'];
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
              await supabase.storage.from('photoProfile').upload(
                    'profile_images/${user.uid}/$fileName',
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
              .from('photoProfile')
              .getPublicUrl('profile_images/${user.uid}/$fileName');

          // Update Firestore
          await _firestore
              .collection('buyers')
              .doc(user.uid)
              .update({'profilImage': imageUrl});

          setState(() {
            _profileImageUrl = imageUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile image updated successfully')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile image: $e')),
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
