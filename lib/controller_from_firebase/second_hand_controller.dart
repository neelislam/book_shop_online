import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../model/second_hand_book.dart';

class SecondHandController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final RxList<SecondHandBook> secondHandBooks = <SecondHandBook>[].obs;

  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _listenToSecondHandBooks();
  }

  void _listenToSecondHandBooks() {
    _subscription = firestore
        .collection('second_hand_books')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final List<SecondHandBook> fetchedBooks = snapshot.docs.map((doc) {
        final data = doc.data();
        return SecondHandBook.fromJson(data)..id = doc.id;
      }).toList();

      secondHandBooks.assignAll(fetchedBooks);
      Get.snackbar(
        'success'.tr,
        'fetched_books_count'.trParams({'count': fetchedBooks.length.toString()}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode ? null : const Color(0xFFCCE5FF),
        colorText: Get.isDarkMode ? null : const Color(0xFF004085),
      );
    }, onError: (error) {
      Get.snackbar(
        'error'.tr,
        'fetch_failed'.trParams({'error': error.toString()}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFCDD2),
        colorText: Colors.black,
      );
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}