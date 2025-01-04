import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> get _ordersStream {
    return _firestore
        .collection('orders')
        .where('vendorId', isEqualTo: _auth.currentUser?.uid)
        .snapshots();
  }

  Future<String> _getBuyerName(String? buyerId) async {
    if (buyerId == null) return 'Unknown Buyer';

    try {
      DocumentSnapshot buyerDoc =
          await _firestore.collection('buyers').doc(buyerId).get();

      if (buyerDoc.exists) {
        return (buyerDoc.data() as Map<String, dynamic>)['fullname'] ??
            'Unknown Buyer';
      }
      return 'Unknown Buyer';
    } catch (e) {
      print('Error fetching buyer name: $e');
      return 'Unknown Buyer';
    }
  }

  String _getOrderStatus(Map<String, dynamic> orderData) {
    if (orderData['cancelled'] == true) return 'Cancelled';
    if (orderData['delivered'] == true) return 'Delivered';
    if (orderData['processing'] == true) return 'Processing';
    return 'Pending';
  }

  Color _getStatusColor(Map<String, dynamic> orderData) {
    if (orderData['cancelled'] == true) return Colors.red;
    if (orderData['delivered'] == true) return Color(0xFF3C55EF);
    if (orderData['processing'] == true) return Colors.purple;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Orders',
          style: GoogleFonts.poppins(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;
              final orderId = orders[index].id;

              return FutureBuilder<String>(
                future: _getBuyerName(orderData['buyerId'] as String?),
                builder: (context, buyerSnapshot) {
                  final buyerName = buyerSnapshot.data ?? 'Loading...';

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              orderData['productImage'] ?? '',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orderData['productName'] ?? 'Unknown Product',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Size: ${orderData['productSize'] ?? 'N/A'}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Buyer: $buyerName',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Price: \$${orderData['productPrice']?.toString() ?? '0.00'}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (orderData['state'] != null &&
                                    orderData['city'] != null &&
                                    orderData['locality'] != null)
                                  Text(
                                    'Address: ${orderData['state']}, ${orderData['city']}, ${orderData['locality']}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                const Text('Status:'),
                                const SizedBox(height: 8),
                                Container(
                                  width: 77,
                                  height: 25,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(orderData),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getOrderStatus(orderData),
                                      style: GoogleFonts.lato(
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (orderData['cancelled'] != true)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (orderData['delivered'] != true)
                                          ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                Color(0xFF3C55EF),
                                              ),
                                            ),
                                            onPressed: () async {
                                              try {
                                                await _firestore
                                                    .collection('orders')
                                                    .doc(orderId)
                                                    .update({
                                                  'delivered': true,
                                                  'processing': false,
                                                  'cancelled': false,
                                                  'deliveredCount':
                                                      FieldValue.increment(1),
                                                });
                                              } catch (e) {
                                                print(
                                                    'Error updating order: $e');
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Failed to update order status'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text(
                                              'Mark Delivered',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        if (orderData['delivered'] != true)
                                          ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                Colors.red,
                                              ),
                                            ),
                                            onPressed: () async {
                                              try {
                                                await _firestore
                                                    .collection('orders')
                                                    .doc(orderId)
                                                    .update({
                                                  'delivered': false,
                                                  'processing': false,
                                                  'cancelled': true,
                                                });
                                              } catch (e) {
                                                print(
                                                    'Error cancelling order: $e');
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Failed to cancel order'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
