class ApprovedBook {
  final String id;
  final String title;
  final String author;
  final double price;
  final String genre;
  final String language;
  final String? description;
  final String? imageUrl;
  final String? status;
  final String? userId;

  ApprovedBook({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.genre,
    required this.language,
    this.description,
    this.imageUrl,
    this.status,
    this.userId,
  });

  factory ApprovedBook.fromJson(Map<String, dynamic> json, String id) {
    return ApprovedBook(
      id: id,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      genre: json['genre'] ?? '',
      language: json['language'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      status: json['status'],
      userId: json['userId'],
    );
  }
}
