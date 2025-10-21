import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../model/book_model.dart';
import '../services/ml_recommendation_service.dart';

class RecommendationController extends GetxController {
  final MLRecommendationService _mlService = MLRecommendationService();

  final RxList<Product> aiRecommendedBooks = <Product>[].obs;
  final RxBool isLoadingRecommendations = false.obs;
  final RxString recommendationStatus = ''.obs;

  Future<void> loadAIRecommendations(List<Product> allBooks) async {
    if (allBooks.isEmpty) return;

    isLoadingRecommendations.value = true;
    recommendationStatus.value = 'analyzing_preferences'.tr;

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final recommendations = await _mlService.getRecommendations(
        allBooks: allBooks,
        limit: 10,
      );

      aiRecommendedBooks.assignAll(recommendations);

      if (recommendations.isEmpty) {
        recommendationStatus.value = 'explore_more_books'.tr;
      } else {
        recommendationStatus.value = 'personalized_for_you'.tr;
      }
    } catch (e) {
      debugPrint('error_loading_recommendations'.trParams({'error': e.toString()}));
      Get.snackbar(
        'error'.tr,
        'unable_to_load_recommendations'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      aiRecommendedBooks.assignAll(
          allBooks.where((b) => b.isBestseller == true).take(10).toList());
    } finally {
      isLoadingRecommendations.value = false;
    }
  }

  Future<List<Product>> getSimilarBooks({
    required Product book,
    required List<Product> allBooks,
  }) async {
    try {
      return await _mlService.getSimilarBooks(
        targetBook: book,
        allBooks: allBooks,
        limit: 5,
      );
    } catch (e) {
      debugPrint('error_getting_similar_books'.trParams({'error': e.toString()}));

      return allBooks
          .where((b) => b.genre == book.genre && b.id != book.id)
          .take(5)
          .toList();
    }
  }

  Future<void> refreshRecommendations(List<Product> allBooks) async {
    await loadAIRecommendations(allBooks);
  }
}