import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductItemWidget extends StatelessWidget {
  final dynamic productData;

  const ProductItemWidget({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              productData['productName'],
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
        ],
      ),
    );
  }
}
