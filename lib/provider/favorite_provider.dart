import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/favorite_models.dart';

final favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, Map<String, FavoriteModels>>(
  (ref) => FavoriteNotifier(),
);

class FavoriteNotifier extends StateNotifier<Map<String, FavoriteModels>> {
  FavoriteNotifier() : super({});

  void addProductToFavorite({
    required String productName,
    required String productid,
    required List imageUrl,
    required dynamic productPrice,
  }) {
    if (state.containsKey(productid)) {
      // Jika produk sudah ada di favorit, hapus dari favorit
      final updatedFavorites = Map<String, FavoriteModels>.from(state);
      updatedFavorites.remove(productid);
      state = updatedFavorites;
    } else {
      // Jika produk belum ada di favorit, tambahkan ke favorit
      final updatedFavorites = Map<String, FavoriteModels>.from(state);
      updatedFavorites[productid] = FavoriteModels(
        productName: productName,
        productid: productid,
        imageUrl: imageUrl,
        productPrice:
            productPrice is int ? productPrice.toDouble() : productPrice,
      );
      state = updatedFavorites;
    }
  }

  void removeFromFavorite(String productid) {
    if (state.containsKey(productid)) {
      final updatedFavorites = Map<String, FavoriteModels>.from(state);
      updatedFavorites.remove(productid);
      state = updatedFavorites;
    }
  }

  void clearAllFavorites() {
    state.clear();
    state = {...state};
  }

  Map<String, FavoriteModels> get getFavoriteItems => state;
}
