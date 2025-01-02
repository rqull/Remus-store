import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class VendorOrdersScreen extends StatefulWidget {
  @override
  _VendorOrdersScreenState createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      Map<String, dynamic> updateData = {
        'processing': false,
        'delivered': false,
        'cancelled': false,
        'lastUpdated': DateTime.now(),
      };

      if (newStatus == 'Delivered') {
        updateData['delivered'] = true;
        updateData['deliveredCount'] = FieldValue.increment(1);
      } else if (newStatus == 'Cancelled') {
        updateData['cancelled'] = true;
      }

      await _firestore.collection('orders').doc(orderId).update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status: $e')),
      );
    }
  }

  Widget _buildOrderCard(DocumentSnapshot order) {
    final data = order.data() as Map<String, dynamic>;
    final orderDate = (data['orderDate'] as Timestamp).toDate();
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(orderDate);

    String status = 'Processing';
    if (data['delivered'] == true) {
      status = 'Delivered';
    } else if (data['cancelled'] == true) {
      status = 'Cancelled';
    }

    final productName = data['productName'] ?? 'Unknown Product';
    final buyerName = data['fullname'] ?? 'Unknown Buyer';
    final quantity = data['quantity']?.toString() ?? '0';
    final totalPrice = data['productPrice'] ?? 0.0;

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.id.substring(0, 8)}',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.nunitoSans(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              productName,
              style: GoogleFonts.nunitoSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity: $quantity',
                  style: GoogleFonts.nunitoSans(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF103DE5),
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buyer',
                      style: GoogleFonts.nunitoSans(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      buyerName,
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Order Date',
                      style: GoogleFonts.nunitoSans(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (status.toLowerCase() == 'processing')
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _updateOrderStatus(order.id, 'Delivered'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Mark as Delivered'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _updateOrderStatus(order.id, 'Cancelled'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Cancel Order'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('orders')
          .where('vendorId', isEqualTo: _auth.currentUser?.uid)
          .where('processing', isEqualTo: status == 'Processing')
          .orderBy('orderDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final orders = snapshot.data?.docs ?? [];

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No $status orders',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) => _buildOrderCard(orders[index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
          style: GoogleFonts.nunitoSans(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF103DE5),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF103DE5),
          tabs: [
            Tab(text: 'Processing'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList('Processing'),
          _buildOrdersList('Delivered'),
          _buildOrdersList('Cancelled'),
        ],
      ),
    );
  }
}
