import 'product_model.dart';

class CartItemModel {
  final String id;           // unique cart item id (product.id)
  final ProductModel product;
  final int quantity;

  const CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
  });

  // ── CopyWith ─────────────────────────────────────────────────
  CartItemModel copyWith({
    int? quantity,
  }) {
    return CartItemModel(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  double get totalPrice => product.price * quantity;

  String get formattedTotal => 'KSh ${totalPrice.toStringAsFixed(0)}';

  // ── Serialization (for local storage) ────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quantity': quantity,
      'productId': product.id,
      'productName': product.name,
      'productPrice': product.price,
      'productImageUrl': product.imageUrl,
      'productUnit': product.unit,
    };
  }

  @override
  String toString() {
    return 'CartItemModel(id: $id, product: ${product.name}, qty: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}