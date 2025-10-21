import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/book_model.dart';

class ProductService {
  final CollectionReference productsCollection =
  FirebaseFirestore.instance.collection('products');

  Stream<List<Product>> getProductsStream() {
    return productsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
