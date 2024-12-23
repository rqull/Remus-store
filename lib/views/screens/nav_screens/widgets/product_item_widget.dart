import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mob3_uas_klp_04/views/screens/inner_screens/product_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/favorite_provider.dart';

class ProductItemWidget extends ConsumerStatefulWidget {
  final dynamic productData;

  const ProductItemWidget({super.key, required this.productData});

  @override
  ConsumerState<ProductItemWidget> createState() => _ProductItemWidgetState();
}

class _ProductItemWidgetState extends ConsumerState<ProductItemWidget> {
  @override
  Widget build(BuildContext context) {
    final favoriteProviderData = ref.read(favoriteProvider.notifier);
    final favoriteData = ref.watch(favoriteProvider);
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(
                productData: widget.productData,
              ),
            ));
      },
      child: Container(
        width: 146,
        height: 246,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 146,
                height: 246,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0X0F040828),
                      spreadRadius: 0,
                      blurRadius: 30,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 7,
              top: 130,
              child: Text(
                widget.productData['productName'],
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: Color(0XFF1E3354),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 7,
              top: 177,
              child: Text(
                widget.productData['category'],
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: Color(0XFF7F8E9D),
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 7,
              top: 207,
              child: Text(
                '\$${widget.productData['productPrice'].toStringAsFixed(2)}',
                style: GoogleFonts.lato(
                  color: Color(0XFF1E3354),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Discount price position
            // Positioned(
            //   left: 51,
            //   top: 210,
            //   child: Text(
            //     '\$${productData['discount']}',
            //     style: TextStyle(
            //       color: Colors.grey,
            //       fontSize: 16,
            //       fontWeight: FontWeight.bold,
            //       letterSpacing: 0.3,
            //       decoration: TextDecoration.lineThrough,
            //     ),
            //   ),
            // ),
            Positioned(
              left: 9,
              top: 9,
              child: Container(
                width: 128,
                height: 108,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -1,
                      left: -1,
                      child: Container(
                        width: 130,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF5C3),
                          border: Border.all(width: 0.8, color: Colors.white),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 4,
                      child: Opacity(
                        opacity: 0.5,
                        child: Container(
                          height: 100,
                          width: 100,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFF44F),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: -10,
                      child: CachedNetworkImage(
                        imageUrl: widget.productData['productImages'][0],
                        width: 108,
                        height: 107,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 56,
              top: 155,
              child: Text(
                '500> Sold',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: Color(0XFF7F8E9D),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 155,
              left: 23,
              child: Text(
                '4.5',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: Color(0XFF7F8E9D),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 104,
              top: 15,
              child: Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  // color: Color(0xFFFA634D),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33FF200),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 5,
              top: 5,
              child: //IconButton(
                  //   onPressed: () {},
                  //   icon: Icon(
                  //     Icons.favorite_border,
                  //     color: Colors.white,
                  //     size: 16,
                  //   ),
                  // ),
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
            )
          ],
        ),
      ),
    );
  }
}
