import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_models.dart';

// Provider untuk mengelola data chart
final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, CartModels>>(
  (ref) => CartNotifier(),
);

// Kelas CartNotifier yang mengelola data chart
class CartNotifier extends StateNotifier<Map<String, CartModels>> {
  // Konstruktor CartNotifier
  CartNotifier() : super({});

  // Method to clear the entire cart
  void clearCart() {
    state = {};
  }

  // Fungsi untuk menambahkan produk ke chart
  void addProductToCart({
    required String productName,
    required double productPrice,
    required String categoryName,
    required List imageUrl,
    required int quantity,
    required int instock,
    required String productid,
    required String productSize,
    required int discount,
    required String description,
    required String vendorId,
  }) {
    // Jika produk sudah ada di chart, maka update quantity
    if (state.containsKey(productid)) {
      // Membuat copy dari chart yang ada
      final updatedCart = Map<String, CartModels>.from(state);
      // Update quantity
      updatedCart[productid] = CartModels(
        productName: state[productid]!.productName,
        productPrice: state[productid]!.productPrice,
        categoryName: state[productid]!.categoryName,
        imageUrl: state[productid]!.imageUrl,
        quantity: state[productid]!.quantity + 1,
        instock: state[productid]!.instock,
        productid: state[productid]!.productid,
        productSize: state[productid]!.productSize,
        discount: state[productid]!.discount,
        description: state[productid]!.description,
        vendorId: state[productid]!.vendorId,
      );
      // Update state
      state = updatedCart;
    } else {
      // Jika produk belum ada di chart, maka tambahkan produk ke chart
      final updatedCart = Map<String, CartModels>.from(state);
      // Tambahkan produk ke chart
      updatedCart[productid] = CartModels(
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
        vendorId: vendorId,
      );
      // Update state
      state = updatedCart;
    }
  }

  // Fungsi untuk menghapus produk dari chart
  void removeProductFromCart(String productid) {
    // Membuat copy dari chart yang ada
    final updatedCart = Map<String, CartModels>.from(state);
    // Hapus produk dari chart
    updatedCart.remove(productid);
    // Update state
    state = updatedCart;
  }

  // Fungsi untuk menambahkan quantity produk di chart
  void incrementQuantity(String productid) {
    if (state.containsKey(productid)) {
      // Membuat copy dari chart yang ada
      final updatedCart = Map<String, CartModels>.from(state);
      // Update quantity
      updatedCart[productid] = CartModels(
        productName: state[productid]!.productName,
        productPrice: state[productid]!.productPrice,
        categoryName: state[productid]!.categoryName,
        imageUrl: state[productid]!.imageUrl,
        quantity: state[productid]!.quantity + 1,
        instock: state[productid]!.instock,
        productid: state[productid]!.productid,
        productSize: state[productid]!.productSize,
        discount: state[productid]!.discount,
        description: state[productid]!.description,
        vendorId: state[productid]!.vendorId,
      );
      // Update state
      state = updatedCart;
    }
  }

  // Fungsi untuk mengurangi quantity produk di chart
  void decrementQuantity(String productid) {
    if (state.containsKey(productid)) {
      final updatedCart = Map<String, CartModels>.from(state);
      if (state[productid]!.quantity > 1) {
        updatedCart[productid] = CartModels(
          productName: state[productid]!.productName,
          productPrice: state[productid]!.productPrice,
          categoryName: state[productid]!.categoryName,
          imageUrl: state[productid]!.imageUrl,
          quantity: state[productid]!.quantity - 1,
          instock: state[productid]!.instock,
          productid: state[productid]!.productid,
          productSize: state[productid]!.productSize,
          discount: state[productid]!.discount,
          description: state[productid]!.description,
          vendorId: state[productid]!.vendorId,
        );
        state = updatedCart;
      } else {
        removeProductFromCart(productid);
      }
    }
  }

  double getTotalPrice() {
    double totalPrice = 0;
    for (var entry in state.entries) {
      // Hitung harga setelah diskon
      double itemPrice = entry.value.productPrice;
      // int discount = entry.value.discount;
      int quantity = entry.value.quantity;

      // if (discount > 0) {
      //   double discountAmount = (itemPrice * discount) / 100;
      //   itemPrice = itemPrice - discountAmount;
      // }

      totalPrice += itemPrice * quantity;
    }
    return double.parse(totalPrice.toStringAsFixed(2));
  }

  // Getter untuk mengakses data chart
  Map<String, CartModels> get cartItems => state;
}
