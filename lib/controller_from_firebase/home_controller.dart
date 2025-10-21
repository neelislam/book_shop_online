import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../model/book_model.dart';

class HomeController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final CollectionReference productCollection;

  final RxList<Product> products = <Product>[].obs;

  StreamSubscription<QuerySnapshot>? _productsSub;

  @override
  void onInit() {
    super.onInit();
    productCollection = firestore.collection('products');
    _listenToProducts();
  }

  void _listenToProducts() {
    _productsSub = productCollection.snapshots().listen((snapshot) {
      final List<Product> fetched = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromJson(data)..id = doc.id;
      }).toList();

      products.assignAll(fetched);
      debugPrint('fetched_products'.trParams({'count': fetched.length.toString()}));
    }, onError: (error) {
      debugPrint('products_snapshot_error'.trParams({'error': error.toString()}));
      Get.snackbar(
        'error'.tr,
        'products_snapshot_error'.trParams({'error': error.toString()}),
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  List<Product> get discountBooks =>
      products.where((p) => p.isDiscounted == true).toList();

  List<Product> get recommendedBooks =>
      products.where((p) => p.isRecommended == true).toList();

  List<Product> get bestsellerBooks =>
      products.where((p) => p.isBestseller == true).toList();

  List<Product> booksByCategory(String? category) {
    if (category == null || category == 'genre_all'.tr) return products.toList();
    return products.where((p) =>
    (p.genre ?? '').toLowerCase() == category.toLowerCase()).toList();
  }

  List<Product> searchBooks(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return products.toList();
    return products.where((p) {
      final name = (p.name ?? '').toLowerCase();
      final author = (p.author ?? '').toLowerCase();
      return name.contains(q) || author.contains(q);
    }).toList();
  }

  @override
  void onClose() {
    _productsSub?.cancel();
    super.onClose();
  }
}