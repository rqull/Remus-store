import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderDetailScreen extends StatefulWidget {
  final dynamic orderData;

  const OrderDetailScreen({super.key, required this.orderData});
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final TextEditingController _reviewController = TextEditingController();
  double rating = 0;

  // is to check if the user has already reviewed the product or not
  Future<bool> hasUserReviewedProduct(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('productsReviews')
        .where('productId', isEqualTo: productId)
        .where('buyerId', isEqualTo: user!.uid)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

// update review and rating within the product collection
  Future<void> updateProductRating(String productId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('productsReviews')
        .where('productId', isEqualTo: productId)
        .get();

    double totalRating = 0;
    int totalReviews = querySnapshot.docs.length;
    for (var doc in querySnapshot.docs) {
      totalRating += doc['rating'];
    }
    final double averageRating =
        totalReviews > 0 ? totalRating / totalReviews : 0;
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({'rating': averageRating, 'totalReviews': totalReviews});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderData['productName']),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 25,
            ),
            child: Container(
              width: 335,
              height: 153,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFEFF0F2)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 13,
                    top: 9,
                    child: Container(
                      width: 78,
                      height: 78,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBCC5FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 10,
                            top: 5,
                            child: widget.orderData['productImage'] != null
                                ? Image.network(
                                    widget.orderData['productImage'],
                                    width: 58,
                                    height: 67,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading image: $error');
                                      return const Icon(Icons.error);
                                    },
                                  )
                                : const Icon(Icons.image_not_supported),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 101,
                    top: 14,
                    child: SizedBox(
                      width: 216,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
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
                                      widget.orderData['productName'],
                                      style: GoogleFonts.lato(
                                        textStyle: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      widget.orderData['categoryName'],
                                      style: const TextStyle(
                                        color: Color(0xFF7F808C),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    "\$${widget.orderData['productPrice']}",
                                    style: const TextStyle(
                                      color: Color(0xFF0B0C1E),
                                      fontSize: 14,
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
                    top: 113,
                    left: 13,
                    child: Container(
                      width: 77,
                      height: 25,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: widget.orderData['delivered'] == true
                            ? Color(0xFF3C55EF)
                            : widget.orderData['processing'] == true
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
                              widget.orderData['delivered'] == true
                                  ? 'Delivered'
                                  : widget.orderData['processing'] == true
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
                  ),
                  Positioned(
                    left: 298,
                    top: 115,
                    child: Container(
                      width: 20,
                      height: 20,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Container(
              width: 336,
              height: 195,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Color(0xFFEFF0F2),
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Address',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 2),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.orderData['locality'] +
                              ' ' +
                              widget.orderData['city'],
                          style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          widget.orderData['state'],
                          style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'To ${widget.orderData['fullname']}',
                          style: const TextStyle(
                              fontSize: 16,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                  widget.orderData['delivered'] == true
                      ? ElevatedButton(
                          onPressed: () async {
                            final productId = widget.orderData['productId'];
                            final hasReviewed =
                                await hasUserReviewedProduct(productId);
                            if (hasReviewed) {
                              await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Update a Review'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          controller: _reviewController,
                                          decoration: const InputDecoration(
                                            labelText: 'Update Your Review',
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RatingBar.builder(
                                            initialRating: rating,
                                            direction: Axis.horizontal,
                                            minRating: 1,
                                            maxRating: 5,
                                            allowHalfRating: true,
                                            itemSize: 24,
                                            unratedColor: Colors.grey,
                                            itemCount: 5,
                                            itemPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 4.0),
                                            itemBuilder: (context, _) {
                                              return const Icon(Icons.star,
                                                  color: Colors.amber);
                                            },
                                            onRatingUpdate: (value) {
                                              rating = value;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          if (_reviewController.text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please write a review'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          if (rating == 0) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please give a rating'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          try {
                                            final review =
                                                _reviewController.text;
                                            await FirebaseFirestore.instance
                                                .collection('productsReviews')
                                                .doc(
                                                    widget.orderData['orderId'])
                                                .update({
                                              'reviewId':
                                                  widget.orderData['orderId'],
                                              'productId':
                                                  widget.orderData['productId'],
                                              'fullName':
                                                  widget.orderData['fullname'],
                                              'email':
                                                  widget.orderData['email'],
                                              'buyerId': FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              'rating': rating,
                                              'review': review,
                                              'timeStamp': Timestamp.now(),
                                            });
                                            await updateProductRating(
                                                productId);
                                            Navigator.of(context).pop();
                                            _reviewController.clear();
                                            rating = 0;

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Review submitted successfully'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } catch (e) {
                                            print(
                                                'Error submitting review: $e');
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Error submitting review: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        child: Text('Submit'),
                                      )
                                    ],
                                  );
                                },
                              );
                            } else {
                              await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Leave a Review'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          controller: _reviewController,
                                          decoration: const InputDecoration(
                                            labelText: 'Your Review',
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RatingBar.builder(
                                            initialRating: rating,
                                            direction: Axis.horizontal,
                                            minRating: 1,
                                            maxRating: 5,
                                            allowHalfRating: true,
                                            itemSize: 24,
                                            unratedColor: Colors.grey,
                                            itemCount: 5,
                                            itemPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 4.0),
                                            itemBuilder: (context, _) {
                                              return const Icon(Icons.star,
                                                  color: Colors.amber);
                                            },
                                            onRatingUpdate: (value) {
                                              rating = value;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          if (_reviewController.text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please write a review'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          if (rating == 0) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please give a rating'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          try {
                                            final review =
                                                _reviewController.text;
                                            await FirebaseFirestore.instance
                                                .collection('productsReviews')
                                                .doc(
                                                    widget.orderData['orderId'])
                                                .set({
                                              'reviewId':
                                                  widget.orderData['orderId'],
                                              'productId':
                                                  widget.orderData['productId'],
                                              'fullName':
                                                  widget.orderData['fullname'],
                                              'email':
                                                  widget.orderData['email'],
                                              'buyerId': FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              'rating': rating,
                                              'review': review,
                                              'timeStamp': Timestamp.now(),
                                            });
                                            await updateProductRating(
                                                productId);
                                            Navigator.of(context).pop();
                                            _reviewController.clear();
                                            rating = 0;

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Review submitted successfully'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } catch (e) {
                                            print(
                                                'Error submitting review: $e');
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Error submitting review: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        child: Text('Submit'),
                                      )
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Text('Review'),
                        )
                      : SizedBox()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
