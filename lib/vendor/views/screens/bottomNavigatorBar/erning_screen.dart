import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ErningScreen extends StatefulWidget {
  const ErningScreen({super.key});

  @override
  State<ErningScreen> createState() => _ErningScreenState();
}

class _ErningScreenState extends State<ErningScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _vendorId = FirebaseAuth.instance.currentUser!.uid;
  DateTime _selectedDate = DateTime.now();
  String _selectedPeriod = 'Daily';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  Future<Map<String, dynamic>> _getEarnings() async {
    try {
      DateTime startDate;
      DateTime endDate = DateTime.now();

      switch (_selectedPeriod) {
        case 'Daily':
          startDate = DateTime(_selectedDate.year, _selectedDate.month,
              _selectedDate.day, 0, 0, 0);
          endDate = DateTime(_selectedDate.year, _selectedDate.month,
              _selectedDate.day, 23, 59, 59);
          break;
        case 'Weekly':
          startDate =
              _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
          endDate = startDate.add(const Duration(days: 6));
          break;
        case 'Monthly':
          startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
          endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
          break;
        case 'Yearly':
          startDate = DateTime(_selectedDate.year, 1, 1);
          endDate = DateTime(_selectedDate.year, 12, 31);
          break;
        default:
          startDate = _selectedDate;
      }

      final QuerySnapshot orders = await _firestore
          .collection('orders')
          .where('vendorId', isEqualTo: _vendorId)
          .where('orderDate', isGreaterThanOrEqualTo: startDate)
          .where('orderDate', isLessThanOrEqualTo: endDate)
          .get();

      double totalEarnings = 0;
      int totalOrders = orders.docs.length;
      int completedOrders = 0;
      int pendingOrders = 0;
      int cancelledOrders = 0;

      for (var doc in orders.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['status'] == 'Completed') {
          totalEarnings += (data['totalAmount'] ?? 0).toDouble();
          completedOrders++;
        } else if (data['status'] == 'Pending') {
          pendingOrders++;
        } else if (data['status'] == 'Cancelled') {
          cancelledOrders++;
        }
      }

      return {
        'totalEarnings': totalEarnings,
        'totalOrders': totalOrders,
        'completedOrders': completedOrders,
        'pendingOrders': pendingOrders,
        'cancelledOrders': cancelledOrders,
      };
    } catch (e) {
      print('Error getting earnings: $e');
      return {
        'totalEarnings': 0,
        'totalOrders': 0,
        'completedOrders': 0,
        'pendingOrders': 0,
        'cancelledOrders': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector
          CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            onDateChanged: (DateTime value) {
              setState(() {
                _selectedDate = value;
              });
            },
          ),

          // Earnings Stats
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _getEarnings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error.toString()}'));
                }

                final data = snapshot.data!;
                final formatter =
                    NumberFormat.currency(locale: 'en_US', symbol: '\$');

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Total Earnings Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Total Earnings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formatter.format(data['totalEarnings']),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Orders Statistics
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Orders',
                              data['totalOrders'].toString(),
                              Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: _buildStatCard(
                              'Completed',
                              data['completedOrders'].toString(),
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Pending',
                              data['pendingOrders'].toString(),
                              Colors.orange,
                            ),
                          ),
                          Expanded(
                            child: _buildStatCard(
                              'Cancelled',
                              data['cancelledOrders'].toString(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
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
