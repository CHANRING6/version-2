import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  Stream<List<ProductModel>> getProductsStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addProduct(ProductModel product) async {
    await _firestore
        .collection(_collection)
        .doc(product.id)
        .set(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    final updateData = {
      ...product.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _firestore
        .collection(_collection)
        .doc(product.id)
        .update(updateData);
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
