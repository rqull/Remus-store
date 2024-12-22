import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartData = ref.watch(cartProvider);
    return Scaffold(
        body: ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: cartData.length,
      itemBuilder: (context, index) {
        final cartItem = cartData.values.toList()[index];
        return Center(child: Text(cartItem.productName));
      },
    ));
  }
}
