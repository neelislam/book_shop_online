class BookSummaryModel {
  final String bookId;
  final String shortSummary;
  final String detailedSummary;
  final List<String> themes;
  final List<String> keyTakeaways;
  final String mood;
  final DateTime generatedAt;

  BookSummaryModel({
    required this.bookId,
    required this.shortSummary,
    required this.detailedSummary,
    required this.themes,
    required this.keyTakeaways,
    required this.mood,
    required this.generatedAt,
  });

  factory BookSummaryModel.fromJson(Map<String, dynamic> json) {
    return BookSummaryModel(
      bookId: json['book_id'] ?? '',
      shortSummary: json['short_summary'] ?? '',
      detailedSummary: json['detailed_summary'] ?? '',
      themes: List<String>.from(json['themes'] ?? []),
      keyTakeaways: List<String>.from(json['key_takeaways'] ?? []),
      mood: json['mood'] ?? '',
      generatedAt: json['generated_at'] != null
          ? DateTime.parse(json['generated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'short_summary': shortSummary,
      'detailed_summary': detailedSummary,
      'themes': themes,
      'key_takeaways': keyTakeaways,
      'mood': mood,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}
