import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../provider/cart_provider.dart';
import 'package:uuid/uuid.dart';

class ChekoutScreen extends ConsumerStatefulWidget {
  const ChekoutScreen({super.key});

  @override
  ConsumerState<ChekoutScreen> createState() => _ChekoutScreenState();
}

class _ChekoutScreenState extends ConsumerState<ChekoutScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedPaymentMethod = 'Stripe';
  @override
  Widget build(BuildContext context) {
    final cartProviderData = ref.read(cartProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chekout',
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Your item',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Flexible(
              child: ListView.builder(
                itemCount: cartProviderData.length,
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemBuilder: (context, index) {
                  final cartItem = cartProviderData.values.toList()[index];

                  return InkWell(
                    onTap: () {},
                    child: Container(
                      width: 336,
                      height: 91,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Color(0xFFEFF0F2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 6,
                            top: 6,
                            child: SizedBox(
                              width: 311,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 78,
                                    height: 78,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFBCC5FF),
                                    ),
                                    child: Image.network(
                                      cartItem.imageUrl[0],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 11,
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 78,
                                      alignment: Alignment(0, -0.51),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: double.infinity,
                                              child: Text(
                                                cartItem.productName,
                                                style: GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 1.3),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional
                                                  .centerStart,
                                              child: Text(
                                                cartItem.categoryName,
                                                style: const TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                    cartItem.productPrice.toStringAsFixed(2),
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        color: Colors.pink,
                                        height: 1.3,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'Choose Payment Method',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            RadioListTile<String>(
              title: const Text('Stripe'),
              value: 'Stripe',
              groupValue: _selectedPaymentMethod,
              onChanged: (String? value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Cash on Delivery'),
              value: 'Cash on Delivery',
              groupValue: _selectedPaymentMethod,
              onChanged: (String? value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
          onTap: () async {
            if (_selectedPaymentMethod == 'Stripe') {
              // Stripe payment
            } else {
              // Cash on delivery
              for (var item in ref.read(cartProvider).values) {
                DocumentSnapshot userDoc = await _firestore
                    .collection('buyer')
                    .doc(_auth.currentUser!.uid)
                    .get();

                CollectionReference orderRef = _firestore.collection('orders');
                final orderId = Uuid().v4();
                await orderRef.doc(orderId).set({
                  'orderId': orderId,
                  'userId': _auth.currentUser!.uid,
                  'productId': item.productid,
                  'productName': item.productName,
                  'productPrice': item.quantity * item.productPrice,
                  'productSize': item.productSize,
                  'quantity': item.quantity,
                  'categoryName': item.categoryName,
                  'imageUrl': item.imageUrl[0],
                  'state': (userDoc.data() as Map<String, dynamic>)['state'],
                  'email': (userDoc.data() as Map<String, dynamic>)['email'],
                  'locality':
                      (userDoc.data() as Map<String, dynamic>)['locality'],
                  'fullname':
                      (userDoc.data() as Map<String, dynamic>)['fullname'],
                  'buyerId': _auth.currentUser!.uid,
                  'deliveredCount': 0,
                  'delivered': false,
                  'processing': true,
                  'orderDate': DateTime.now(),
                });
              }
            }
          },
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width - 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xFF1532E7),
            ),
            child: const Center(
              child: Text(
                'Place Order',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
