import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../inner_screens/product_detail_screen.dart';

class PopulerItem extends StatelessWidget {
  const PopulerItem({
    super.key,
    required this.productData,
  });

  final QueryDocumentSnapshot<Object?> productData;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productData: productData,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 110,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 87,
                height: 81,
                decoration: BoxDecoration(
                  color: Color(
                    0xFFB0CCFF,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Image.network(
                  productData['productImages'][0],
                  width: 71,
                  height: 71,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              '\$${productData['productPrice']}',
              style: TextStyle(
                fontSize: 17,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              productData['productName'],
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
