import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class VendorWithdrawalScreen extends StatefulWidget {
  static const String routeName = '/vendor-withdrawal';

  @override
  State<VendorWithdrawalScreen> createState() => _VendorWithdrawalScreenState();
}

class _VendorWithdrawalScreenState extends State<VendorWithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  bool _isLoading = false;
  double _availableBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchAvailableBalance();
  }

  Future<void> _fetchAvailableBalance() async {
    final vendorId = FirebaseAuth.instance.currentUser?.uid;
    if (vendorId != null) {
      try {
        // Get all delivered orders for this vendor
        final QuerySnapshot orders = await FirebaseFirestore.instance
            .collection('orders')
            .where('vendorId', isEqualTo: vendorId)
            .where('delivered', isEqualTo: true)
            .get();

        // Calculate total earnings from delivered orders
        double totalEarnings = 0;
        for (var doc in orders.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalEarnings += (data['productPrice'] ?? 0).toDouble();
        }

        // Get total withdrawals
        final QuerySnapshot withdrawals = await FirebaseFirestore.instance
            .collection('withdrawal')
            .where('vendorId', isEqualTo: vendorId)
            .where('status', isEqualTo: 'approved')
            .get();

        // Calculate total withdrawn amount
        double totalWithdrawn = 0;
        for (var doc in withdrawals.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalWithdrawn += (data['amount'] ?? 0).toDouble();
        }

        // Available balance is total earnings minus total withdrawals
        setState(() {
          _availableBalance = totalEarnings - totalWithdrawn;
        });
      } catch (e) {
        print('Error calculating available balance: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching balance. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitWithdrawalRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    if (amount > _availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient balance')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final vendorId = FirebaseAuth.instance.currentUser?.uid;
      final vendorDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .get();

      await FirebaseFirestore.instance.collection('withdrawal').add({
        'vendorId': vendorId,
        'vendorName': vendorDoc.data()?['businessName'] ?? 'Unknown',
        'amount': amount,
        'bankName': _bankNameController.text,
        'accountNumber': _accountNumberController.text,
        'status': 'pending',
        'requestDate': Timestamp.now(),
      });

      // Update vendor's balance
      await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .update({
        'balance': FieldValue.increment(-amount),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Withdrawal request submitted successfully')),
      );

      // Clear form
      _amountController.clear();
      _bankNameController.clear();
      _accountNumberController.clear();

      // Refresh available balance
      await _fetchAvailableBalance();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting withdrawal request')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _withdrawalStream = FirebaseFirestore.instance
        .collection('withdrawal')
        .where('vendorId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .orderBy('requestDate', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Withdrawal Management'),
        backgroundColor: Colors.yellow.shade900,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_US',
                        symbol: '\$',
                      ).format(_availableBalance),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request Withdrawal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          if (amount > _availableBalance) {
                            return 'Amount exceeds available balance';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _bankNameController,
                        decoration: InputDecoration(
                          labelText: 'Bank Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter bank name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _accountNumberController,
                        decoration: InputDecoration(
                          labelText: 'Account Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter account number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading ? null : _submitWithdrawalRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow.shade900,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Submit Withdrawal Request'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Withdrawal History',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _withdrawalStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No withdrawal history'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(
                          NumberFormat.currency(
                            locale: 'en_US',
                            symbol: '\$',
                          ).format(data['amount'] ?? 0),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bank: ${data['bankName']}'),
                            Text('Account: ${data['accountNumber']}'),
                            Text(
                              'Date: ${DateFormat('MMM d, y').format((data['requestDate'] as Timestamp).toDate())}',
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: data['status'] == 'approved'
                                ? Colors.green.shade100
                                : data['status'] == 'rejected'
                                    ? Colors.red.shade100
                                    : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data['status'] ?? 'pending',
                            style: TextStyle(
                              color: data['status'] == 'approved'
                                  ? Colors.green
                                  : data['status'] == 'rejected'
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }
}
