class CartModels {
  final String productName;
  final double productPrice;
  final String categoryName;
  final List imageUrl;
  final int quantity;
  final int instock;
  final String productid;
  final String productSize;
  final int discount;
  final String description;

  CartModels({
    required this.productName,
    required this.productPrice,
    required this.categoryName,
    required this.imageUrl,
    required this.quantity,
    required this.instock,
    required this.productid,
    required this.productSize,
    required this.discount,
    required this.description,
  });
}
