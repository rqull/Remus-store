import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../provider/cart_provider.dart';
import 'package:uuid/uuid.dart';

import '../main_screen.dart';
import 'shipping_address_screen.dart';

class ChekoutScreen extends ConsumerStatefulWidget {
  const ChekoutScreen({super.key});

  @override
  ConsumerState<ChekoutScreen> createState() => _ChekoutScreenState();
}

class _ChekoutScreenState extends ConsumerState<ChekoutScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedPaymentMethod = 'Stripe';

  // get current user information
  String state = '';
  String city = '';
  String locality = '';

  @override
  void initState() {
    // TODO: implement initState
    getUserData();
    super.initState();
  }

  // get current user detail
  void getUserData() {
    Stream<DocumentSnapshot> userDataStream =
        _firestore.collection('buyers').doc(_auth.currentUser!.uid).snapshots();

    // Listen to the stream and update the data
    userDataStream.listen(
      (DocumentSnapshot userData) {
        if (userData.exists) {
          setState(() {
            state = userData.get('state');
            city = userData.get('city');
            locality = userData.get('locality');
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProviderData = ref.read(cartProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Chekout',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShippingAddressScreen(),
                      ));
                },
                child: SizedBox(
                  width: 335,
                  height: 74,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 335,
                          height: 74,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color(0xFFEFF0F2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 70,
                        top: 17,
                        child: SizedBox(
                          width: 215,
                          height: 41,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: -1,
                                top: -1,
                                child: SizedBox(
                                  width: 219,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Add Address',
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Enter City',
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              height: 1.3,
                                              color: Color(0xFF7F808C),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        top: 16,
                        child: SizedBox.square(
                          dimension: 42,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 43,
                                  height: 43,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBF7F5),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.hardEdge,
                                    children: [
                                      Positioned(
                                        left: 11,
                                        top: 11,
                                        child: Image.network(
                                          'https://storage.googleapis.com/codeless-dev.appspot.com/uploads%2Fimages%2Fnn2Ldqjoc2Xp89Y7Wfzf%2F2ee3a5ce3b02828d0e2806584a6baa88.png',
                                          height: 20,
                                          width: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 305,
                        top: 25,
                        child: Image.asset(
                          'assets/icons/pencil.png',
                          height: 20,
                          width: 20,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
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
      ),
      bottomSheet: state == ''
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const ShippingAddressScreen();
                      },
                    ));
                  },
                  child: const Text('Add Address')),
            )
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () async {
                  if (_selectedPaymentMethod == 'Stripe') {
                    // Stripe payment
                  } else {
                    // Cash on delivery
                    setState(() {
                      isLoading = true;
                    });

                    // Simpan items dalam list terlebih dahulu
                    final cartItems = ref.read(cartProvider).values.toList();

                    try {
                      for (var item in cartItems) {
                        DocumentSnapshot userDoc = await _firestore
                            .collection('buyers')
                            .doc(_auth.currentUser!.uid)
                            .get();

                        // Get product data to get vendorId
                        DocumentSnapshot productDoc = await _firestore
                            .collection('products')
                            .doc(item.productid)
                            .get();

                        CollectionReference orderRef =
                            _firestore.collection('orders');
                        final orderId = const Uuid().v4();
                        await orderRef.doc(orderId).set({
                          'orderId': orderId,
                          'userId': _auth.currentUser!.uid,
                          'productName': item.productName,
                          'productId': item.productid,
                          'productSize': item.productSize,
                          'quantity': item.quantity,
                          'productPrice': item.quantity * item.productPrice,
                          'categoryName': item.categoryName,
                          'productImage': item.imageUrl[0],
                          'state':
                              (userDoc.data() as Map<String, dynamic>)['state'],
                          'city':
                              (userDoc.data() as Map<String, dynamic>)['city'],
                          'email':
                              (userDoc.data() as Map<String, dynamic>)['email'],
                          'locality': (userDoc.data()
                              as Map<String, dynamic>)['locality'],
                          'fullname': (userDoc.data()
                              as Map<String, dynamic>)['fullname'],
                          'buyerId': _auth.currentUser!.uid,
                          'vendorId': (productDoc.data()
                              as Map<String, dynamic>)['vendorId'],
                          'deliveredCount': 0,
                          'delivered': false,
                          'cancelled': false,
                          'processing': true,
                          'orderDate': DateTime.now(),
                        });
                      }

                      // Clear cart setelah semua order berhasil dibuat
                      ref.read(cartProvider.notifier).state = {};

                      setState(() {
                        isLoading = false;
                      });

                      // Navigate to order screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(),
                        ),
                      );
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Error creating order: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF1532E7),
                  ),
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
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
