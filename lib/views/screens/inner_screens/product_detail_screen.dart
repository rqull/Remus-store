import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/cart_provider.dart';
import '../../../provider/favorite_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final dynamic productData;

  const ProductDetailScreen({super.key, required this.productData});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String selectedSize = '';

  @override
  void initState() {
    super.initState();
    if (widget.productData['sizes'] != null &&
        widget.productData['sizes'].isNotEmpty) {
      selectedSize = widget.productData['sizes'][0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProviderData = ref.read(cartProvider.notifier);
    final favoriteProviderData = ref.read(favoriteProvider.notifier);
    final favoriteData = ref.watch(favoriteProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Detail',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  color: Color(0xFF363330),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                try {
                  favoriteProviderData.addProductToFavorite(
                    productName: widget.productData['productName'] ?? '',
                    productid: widget.productData['productId'] ?? '',
                    imageUrl: widget.productData['productImages'] ?? [],
                    productPrice: widget.productData['productPrice'] ?? 0.0,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        favoriteData
                                .containsKey(widget.productData['productId'])
                            ? ' ${widget.productData['productName']} Removed from favorites'
                            : ' ${widget.productData['productName']} Added to favorites',
                      ),
                      duration: Duration(seconds: 1),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: favoriteData.containsKey(widget.productData['productId'])
                  ? const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                  : const Icon(
                      Icons.favorite_border,
                      color: Colors.red,
                    ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 260,
                height: 274,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 260,
                        height: 260,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Color(0xFFD8DDFF),
                          borderRadius: BorderRadius.circular(130),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 22,
                      top: 0,
                      child: Container(
                        width: 216,
                        height: 274,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Color(0xFF9CA8FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: SizedBox(
                          height: 300,
                          child: PageView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                widget.productData['productImages'].length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                widget.productData['productImages'][index],
                                width: 198,
                                height: 225,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.productData['productName'],
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Color(0xFF3C55EF),
                      ),
                    ),
                  ),
                  Text(
                    '\$${widget.productData['productPrice'].toStringAsFixed(2)}',
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Color(0xFF3C55EF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.productData['category'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            widget.productData['rating'] == 0
                ? const Text('')
                : Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        Text(
                          widget.productData['rating'].toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          '(${widget.productData['totalReviews'].toString()})',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Size:',
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        color: Color(0xFF343434),
                        fontSize: 16,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.productData['sizes'].length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSize =
                                    widget.productData['sizes'][index];
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: selectedSize ==
                                        widget.productData['sizes'][index]
                                    ? Color(0xFF126881)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: selectedSize ==
                                          widget.productData['sizes'][index]
                                      ? Colors.transparent
                                      : Color(0xFF126881),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  widget.productData['sizes'][index],
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      color: selectedSize ==
                                              widget.productData['sizes'][index]
                                          ? Colors.white
                                          : Color(0xFF126881),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        color: Color(0xFF363330),
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Text(
                    widget.productData['description'],
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            try {
              if (widget.productData != null) {
                // For admin products, vendorId will be empty
                final vendorId = widget.productData['vendorId'] ?? '';

                cartProviderData.addProductToCart(
                  productName: widget.productData['productName'] ?? '',
                  productPrice:
                      (widget.productData['productPrice'] ?? 0.0).toDouble(),
                  categoryName: widget.productData['category'] ?? '',
                  imageUrl: widget.productData['productImages'] ?? [],
                  quantity: 1,
                  instock: widget.productData['quantity'] ?? 0,
                  productid: widget.productData['productId'] ?? '',
                  productSize: selectedSize,
                  discount: widget.productData['discount'] ?? 0,
                  description: widget.productData['description'] ?? '',
                  vendorId: vendorId, // Add vendorId parameter
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product added to cart successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error adding to cart: $e'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF3B54EE),
            minimumSize: Size(MediaQuery.of(context).size.width - 16, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(
            'ADD TO CART',
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
