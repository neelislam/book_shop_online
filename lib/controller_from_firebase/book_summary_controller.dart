import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/book_summary_model.dart';
import '../services/openrouter_summary_service.dart';

class BookSummaryController extends GetxController {
  final OpenRouterSummaryService _aiService = OpenRouterSummaryService();
  final GetStorage _storage = GetStorage();

  final Rx<BookSummaryModel?> currentSummary = Rx<BookSummaryModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> loadSummary({
    required String bookId,
    required String bookName,
    required String author,
    String? genre,
  }) async {
    isLoading.value = true;
    error.value = '';

    try {
      final cached = _getCachedSummary(bookId);
      if (cached != null) {
        currentSummary.value = cached;
        isLoading.value = false;
        return;
      }

      final summary = await _aiService.generateSummary(
        bookId: bookId,
        bookName: bookName,
        author: author,
        genre: genre,
      );

      _cacheSummary(summary);
      currentSummary.value = summary;

    } catch (e) {
      error.value = e.toString();
      debugPrint('Error loading summary: $e');
    } finally {
      isLoading.value = false;
    }
  }

  BookSummaryModel? _getCachedSummary(String bookId) {
    try {
      final cached = _storage.read('summary_$bookId');
      if (cached != null) {
        final data = jsonDecode(cached);
        final summary = BookSummaryModel.fromJson(data);

        if (DateTime.now().difference(summary.generatedAt).inDays < 90) {
          return summary;
        }
      }
    } catch (e) {
      debugPrint('Error reading cache: $e');
    }
    return null;
  }

  void _cacheSummary(BookSummaryModel summary) {
    try {
      _storage.write('summary_${summary.bookId}', jsonEncode(summary.toJson()));
    } catch (e) {
      debugPrint('Error caching summary: $e');
    }
  }

  void clearSummary() {
    currentSummary.value = null;
    error.value = '';
  }
}