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
    // Print current vendor ID for debugging
    print('Current Vendor ID: ${_auth.currentUser?.uid}');

    return _firestore
        .collection('orders')
        .where('vendorId', isEqualTo: _auth.currentUser?.uid)
        .snapshots();
  }

  Future<String> _getBuyerName(String buyerId) async {
    try {
      DocumentSnapshot buyerDoc =
          await _firestore.collection('buyers').doc(buyerId).get();

      if (buyerDoc.exists) {
        return (buyerDoc.data() as Map<String, dynamic>)['fullname'] ??
            'Unknown Buyer';
      }
      return 'Unknown Buyer';
    } catch (e) {
      return 'Unknown Buyer';
    }
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
          // Print snapshot data for debugging
          print('Connection State: ${snapshot.connectionState}');
          print('Has Error: ${snapshot.hasError}');
          if (snapshot.hasError) print('Error: ${snapshot.error}');
          if (snapshot.hasData) {
            print('Number of documents: ${snapshot.data!.docs.length}');
            snapshot.data!.docs.forEach((doc) {
              print('Order Data: ${doc.data()}');
            });
          }

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
              return FutureBuilder<String>(
                future: _getBuyerName(orderData['buyerId']),
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
                              orderData['productImage'],
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
                                  orderData['productName'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Size: ${orderData['productSize']}',
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
                                  'Price: \$${orderData['productPrice']}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Address: ${orderData['state']}, ${orderData['city']}, ${orderData['locality']}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text('Status :'),
                                const SizedBox(height: 8),
                                Container(
                                  width: 77,
                                  height: 25,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: orderData['delivered'] == true
                                        ? Color(0xFF3C55EF)
                                        : orderData['processing'] == true
                                            ? Colors.purple
                                            : Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        left: 9,
                                        top: 3,
                                        child: Text(
                                          orderData['delivered'] == true
                                              ? 'Delivered'
                                              : orderData['processing'] == true
                                                  ? 'Processing'
                                                  : 'Cancelled',
                                          style: GoogleFonts.lato(
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                          Color(0xFF3C55EF),
                                        )),
                                        onPressed: () async {
                                          await _firestore
                                              .collection('orders')
                                              .doc(orderData['orderId'])
                                              .update({
                                            'delivered': true,
                                            'processing': false,
                                            'deliveredCount':
                                                FieldValue.increment(1),
                                          });
                                        },
                                        child: orderData['delivered'] == true
                                            ? const Text(
                                                'Delivered',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(
                                                'Mark Delivered',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                      ElevatedButton(
                                        style: const ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                          Colors.red,
                                        )),
                                        onPressed: () async {
                                          await _firestore
                                              .collection('orders')
                                              .doc(orderData['orderId'])
                                              .update({
                                            'delivered': false,
                                            'processing': false,
                                            'cancelled': true,
                                          });
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
