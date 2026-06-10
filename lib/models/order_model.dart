import 'cart_item_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final List<OrderItemSnapshot> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final String deliveryAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.status = OrderStatus.pending,
    required this.deliveryAddress,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userPhone: map['userPhone'] as String? ?? '',
      items: rawItems
          .map((e) =>
              OrderItemSnapshot.fromMap(e as Map<String, dynamic>))
          .toList(),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      status:
          _statusFromString(map['status'] as String? ?? 'pending'),
      deliveryAddress: map['deliveryAddress'] as String? ?? '',
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(
              map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
              map['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  factory OrderModel.fromCart({
    required String orderId,
    required String userId,
    required String userName,
    required String userPhone,
    required List<CartItemModel> cartItems,
    required String deliveryAddress,
    required double deliveryFee,
    String? notes,
  }) {
    final items =
        cartItems.map((c) => OrderItemSnapshot.fromCartItem(c)).toList();
    final subtotal = cartItems.fold<double>(
        0, (sum, item) => sum + item.totalPrice);
    return OrderModel(
      id: orderId,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: subtotal + deliveryFee,
      deliveryAddress: deliveryAddress,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  OrderModel copyWith({
    OrderStatus? status,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status.name,
      'deliveryAddress': deliveryAddress,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedTotal => 'KSh ${total.toStringAsFixed(0)}';
  String get formattedSubtotal =>
      'KSh ${subtotal.toStringAsFixed(0)}';
  String get formattedDeliveryFee =>
      'KSh ${deliveryFee.toStringAsFixed(0)}';

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:    return 'Pending';
      case OrderStatus.confirmed:  return 'Confirmed';
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.shipped:    return 'Shipped';
      case OrderStatus.delivered:  return 'Delivered';
      case OrderStatus.cancelled:  return 'Cancelled';
    }
  }

  String get statusEmoji {
    switch (status) {
      case OrderStatus.pending:    return '⏳';
      case OrderStatus.confirmed:  return '✅';
      case OrderStatus.processing: return '🔄';
      case OrderStatus.shipped:    return '🚚';
      case OrderStatus.delivered:  return '📦';
      case OrderStatus.cancelled:  return '❌';
    }
  }

  static OrderStatus _statusFromString(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':  return OrderStatus.confirmed;
      case 'processing': return OrderStatus.processing;
      case 'shipped':    return OrderStatus.shipped;
      case 'delivered':  return OrderStatus.delivered;
      case 'cancelled':  return OrderStatus.cancelled;
      default:           return OrderStatus.pending;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ── OrderItemSnapshot ─────────────────────────────────────────
class OrderItemSnapshot {
  final String productId;
  final String productName;
  final String productImageUrl;
  final String productUnit;
  final double priceAtOrder;
  final int quantity;

  const OrderItemSnapshot({
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.productUnit,
    required this.priceAtOrder,
    required this.quantity,
  });

  factory OrderItemSnapshot.fromCartItem(CartItemModel item) {
    return OrderItemSnapshot(
      productId: item.product.id,
      productName: item.product.name,
      productImageUrl: item.product.imageUrl,
      productUnit: item.product.unit,
      priceAtOrder: item.product.price,
      quantity: item.quantity,
    );
  }

  factory OrderItemSnapshot.fromMap(Map<String, dynamic> map) {
    return OrderItemSnapshot(
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      productImageUrl: map['productImageUrl'] as String? ?? '',
      productUnit: map['productUnit'] as String? ?? 'pcs',
      priceAtOrder:
          (map['priceAtOrder'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'productUnit': productUnit,
      'priceAtOrder': priceAtOrder,
      'quantity': quantity,
    };
  }

  double get totalPrice => priceAtOrder * quantity;
  String get formattedTotal =>
      'KSh ${totalPrice.toStringAsFixed(0)}';
}