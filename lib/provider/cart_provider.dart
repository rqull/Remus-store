import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_models.dart';

class CartNotifier extends StateNotifier<Map<String, CartModels>> {
  CartNotifier() : super({});

  void addProductToCart({
    required String productName,
    required double productPrice,
    required int categoryName,
    required List imageUrl,
    required int quantity,
    required int instock,
    required String productid,
    required String productSize,
    required int discount,
    required String description,
  }) {
    if (state.containsKey(productid)) {
      state = {
        ...state,
        productid: CartModels(
          productName: state[productid]!.productName,
          productPrice: state[productid]!.productPrice,
          categoryName: state[productid]!.categoryName,
          imageUrl: state[productid]!.imageUrl,
          quantity: state[productid]!.quantity + quantity,
          instock: state[productid]!.instock,
          productid: state[productid]!.productid,
          productSize: state[productid]!.productSize,
          discount: state[productid]!.discount,
          description: state[productid]!.description,
        )
      };
    } else {
      state = {
        ...state,
        productid: CartModels(
          productName: productName,
          productPrice: productPrice,
          categoryName: categoryName,
          imageUrl: imageUrl,
          quantity: quantity,
          instock: instock,
          productid: productid,
          productSize: productSize,
          discount: discount,
          description: description,
        )
      };
    }
  }
}
