import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort client-side — avoids needing a composite Firestore index
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  Stream<List<OrderModel>> getAllOrdersStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  Future<void> placeOrder(OrderModel order) async {
    await _firestore
        .collection(_collection)
        .doc(order.id)
        .set(order.toMap());
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection(_collection).doc(orderId).update({
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
