import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/favorite_models.dart';

class FavoriteNotifier extends StateNotifier<Map<String, FavoriteModels>> {
  FavoriteNotifier() : super({});

  // Is to add product to favorite

  void addProductToFavorite({
    required String productName,
    required String productid,
    required List imageUrl,
    required double productPrice,
  }) {
    state[productid] = FavoriteModels(
        productName: productName,
        productid: productid,
        imageUrl: imageUrl,
        productPrice: productPrice);

    // notify listeners that the state has changed

    state = {...state};
  }

  // Is to remove product to favorite

  void removeProductFromFavorite(String productid) {
    state.remove(productid);
    state = {...state};
  }
}
