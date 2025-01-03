import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ErningScreen extends StatefulWidget {
  const ErningScreen({super.key});

  @override
  State<ErningScreen> createState() => _ErningScreenState();
}

class _ErningScreenState extends State<ErningScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _vendorId = FirebaseAuth.instance.currentUser!.uid;
  String _selectedPeriod = 'Daily';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
  DateTime _selectedDate = DateTime.now();

  Future<Map<String, dynamic>> _getEarnings() async {
    try {
      final QuerySnapshot orders = await _firestore
          .collection('orders')
          .where('vendorId', isEqualTo: _vendorId)
          .get();

      double totalEarnings = 0;
      int totalOrders = orders.docs.length;
      int delivered = 0;
      int processing = 0;
      int cancelled = 0;

      for (var doc in orders.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print(
            'Order ${doc.id}: delivered=${data['delivered']}, processing=${data['processing']}, cancelled=${data['cancelled']}, price=${data['productPrice']}');

        if (data['delivered'] == true) {
          totalEarnings += (data['productPrice'] ?? 0).toDouble();
          delivered++;
        } else if (data['processing'] == true) {
          processing++;
        } else if (data['cancelled'] == true) {
          cancelled++;
        }
      }

      print('Total Orders: $totalOrders');
      print('Total Earnings: $totalEarnings');
      print('Delivered: $delivered');
      print('Processing: $processing');
      print('Cancelled: $cancelled');

      return {
        'totalEarnings': totalEarnings,
        'totalOrders': totalOrders,
        'delivered': delivered,
        'processing': processing,
        'cancelled': cancelled,
      };
    } catch (e) {
      print('Error getting earnings: $e');
      return {
        'totalEarnings': 0,
        'totalOrders': 0,
        'delivered': 0,
        'processing': 0,
        'cancelled': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Earnings',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return _periods.map((String period) {
                return PopupMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getEarnings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Period: $_selectedPeriod',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                _buildEarningsCard(
                  'Total Earnings',
                  NumberFormat.currency(symbol: '\$')
                      .format(data['totalEarnings']),
                  Icons.attach_money,
                  Colors.green,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Orders',
                        data['totalOrders'].toString(),
                        Icons.shopping_cart,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Delivered',
                        data['delivered'].toString(),
                        Icons.check_circle,
                        Color(0xFF3C55EF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Processing',
                        data['processing'].toString(),
                        Icons.pending,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Cancelled',
                        data['cancelled'].toString(),
                        Icons.cancel,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEarningsCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
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
      elevation: 4,
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
