import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bottomNavigatorBar/edit_product_screen.dart';
import 'bottomNavigatorBar/erning_screen.dart';
import 'bottomNavigatorBar/vendor_orders_screen.dart';
import 'bottomNavigatorBar/upload_product_screen.dart';
import 'bottomNavigatorBar/vendor_profile_screen.dart';

class MainVendorScreen extends StatefulWidget {
  const MainVendorScreen({super.key});

  @override
  State<MainVendorScreen> createState() => _MainVendorScreenState();
}

class _MainVendorScreenState extends State<MainVendorScreen> {
  int pageIndex = 0;
  final List<Widget> _pages = [
    ErningScreen(),
    VendorOrdersScreen(),
    UploadProductScreen(),
    EditProductScreen(),
    VendorProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: pageIndex,
        onTap: (value) {
          setState(() {
            pageIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.money_dollar), label: 'Earning'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.cart), label: 'Orders'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.upload_circle), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Edit'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
