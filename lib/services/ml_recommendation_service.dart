import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/book_model.dart';
import 'dart:math';

class MLRecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  static const double COLLABORATIVE_WEIGHT = 0.4;
  static const double CONTENT_WEIGHT = 0.35;
  static const double POPULARITY_WEIGHT = 0.15;
  static const double DIVERSITY_WEIGHT = 0.1;


  Future<List<Product>> getRecommendations({
    required List<Product> allBooks,
    int limit = 10,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return _getFallbackRecommendations(allBooks, limit);
    }


    final userProfile = await _buildUserProfile(userId);

    if (userProfile.isEmpty) {
      return _getFallbackRecommendations(allBooks, limit);
    }


    Map<String, double> bookScores = {};

    for (var book in allBooks) {

      if (userProfile['interactedBooks'].contains(book.id)) {
        continue;
      }

      double score = 0.0;

      score += await _getCollaborativeScore(book, userProfile) * COLLABORATIVE_WEIGHT;

      score += _getContentBasedScore(book, userProfile) * CONTENT_WEIGHT;

      score += await _getPopularityScore(book) * POPULARITY_WEIGHT;

      score += _getDiversityScore(book, userProfile) * DIVERSITY_WEIGHT;

      bookScores[book.id ?? ''] = score;
    }


    var sortedBooks = allBooks.where((b) => bookScores.containsKey(b.id)).toList();
    sortedBooks.sort((a, b) {
      return bookScores[b.id]!.compareTo(bookScores[a.id]!);
    });

    return sortedBooks.take(limit).toList();
  }

  Future<Map<String, dynamic>> _buildUserProfile(String userId) async {
    Set<String> interactedBooks = {};
    Map<String, int> genrePreferences = {};
    Map<String, int> authorPreferences = {};

    try {

      final ordersSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .get();

      for (var order in ordersSnapshot.docs) {
        final items = order.data()['items'] as List<dynamic>? ?? [];
        for (var item in items) {
          final bookId = item['id'] as String?;
          if (bookId != null) {
            interactedBooks.add(bookId);


            final bookDoc = await _firestore.collection('products').doc(bookId).get();
            if (bookDoc.exists) {
              final genre = bookDoc.data()?['genre'] as String?;
              final author = bookDoc.data()?['author'] as String?;

              if (genre != null) {
                genrePreferences[genre] = (genrePreferences[genre] ?? 0) + 2; // Purchases weighted higher
              }
              if (author != null) {
                authorPreferences[author] = (authorPreferences[author] ?? 0) + 2;
              }
            }
          }
        }
      }


      final userDoc = await _firestore.collection('users').doc(userId).get();
      final wishlist = List<String>.from(userDoc.data()?['wishlist'] ?? []);

      for (var bookId in wishlist) {
        interactedBooks.add(bookId);

        final bookDoc = await _firestore.collection('products').doc(bookId).get();
        if (bookDoc.exists) {
          final genre = bookDoc.data()?['genre'] as String?;
          final author = bookDoc.data()?['author'] as String?;

          if (genre != null) {
            genrePreferences[genre] = (genrePreferences[genre] ?? 0) + 1;
          }
          if (author != null) {
            authorPreferences[author] = (authorPreferences[author] ?? 0) + 1;
          }
        }
      }

      final cartSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      for (var item in cartSnapshot.docs) {
        final bookId = item.data()['id'] as String?;
        if (bookId != null) {
          interactedBooks.add(bookId);

          final bookDoc = await _firestore.collection('products').doc(bookId).get();
          if (bookDoc.exists) {
            final genre = bookDoc.data()?['genre'] as String?;
            final author = bookDoc.data()?['author'] as String?;

            if (genre != null) {
              genrePreferences[genre] = (genrePreferences[genre] ?? 0) + 1;
            }
            if (author != null) {
              authorPreferences[author] = (authorPreferences[author] ?? 0) + 1;
            }
          }
        }
      }
    } catch (e) {
      print('Error building user profile: $e');
    }

    return {
      'interactedBooks': interactedBooks,
      'genrePreferences': genrePreferences,
      'authorPreferences': authorPreferences,
    };
  }


  Future<double> _getCollaborativeScore(
      Product book,
      Map<String, dynamic> userProfile,
      ) async {
    try {
      Set<String> userBooks = userProfile['interactedBooks'] as Set<String>;
      if (userBooks.isEmpty) return 0.0;


      Map<String, int> similarUsers = {};

      for (var bookId in userBooks.take(5)) { // Limit to avoid too many queries
        final ordersSnapshot = await _firestore
            .collectionGroup('orders')
            .where('items', arrayContains: {'id': bookId})
            .limit(10)
            .get();

        for (var order in ordersSnapshot.docs) {
          final userId = order.reference.parent.parent?.id;
          if (userId != null && userId != _auth.currentUser?.uid) {
            similarUsers[userId] = (similarUsers[userId] ?? 0) + 1;
          }
        }
      }


      int interactions = 0;
      for (var userId in similarUsers.keys.take(5)) {
        final userOrders = await _firestore
            .collection('users')
            .doc(userId)
            .collection('orders')
            .get();

        for (var order in userOrders.docs) {
          final items = order.data()['items'] as List<dynamic>? ?? [];
          if (items.any((item) => item['id'] == book.id)) {
            interactions += similarUsers[userId]!;
          }
        }
      }

      return min<double>(interactions / 10.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }


  double _getContentBasedScore(
      Product book,
      Map<String, dynamic> userProfile,
      ) {
    Map<String, int> genrePrefs = userProfile['genrePreferences'] as Map<String, int>;
    Map<String, int> authorPrefs = userProfile['authorPreferences'] as Map<String, int>;

    double score = 0.0;


    if (book.genre != null && genrePrefs.containsKey(book.genre)) {
      int totalGenreInteractions = genrePrefs.values.reduce((a, b) => a + b);
      score += (genrePrefs[book.genre]! / totalGenreInteractions) * 0.7;
    }


    if (book.author != null && authorPrefs.containsKey(book.author)) {
      int totalAuthorInteractions = authorPrefs.values.reduce((a, b) => a + b);
      score += (authorPrefs[book.author]! / totalAuthorInteractions) * 0.3;
    }

    return min<double>(score, 1.0);
  }


  Future<double> _getPopularityScore(Product book) async {
    try {
      final usersWithBook = await _firestore
          .collection('users')
          .where('wishlist', arrayContains: book.id)
          .limit(50)
          .get();

      int count = usersWithBook.docs.length;


      final ordersWithBook = await _firestore
          .collectionGroup('orders')
          .where('items', arrayContains: {'id': book.id})
          .limit(50)
          .get();

      count += ordersWithBook.docs.length * 2;


      return 0.1 + min<double>(count / 20.0, 0.9);
    } catch (e) {
      return 0.5; // Default middle score
    }
  }


  double _getDiversityScore(
      Product book,
      Map<String, dynamic> userProfile,
      ) {
    Map<String, int> genrePrefs = userProfile['genrePreferences'] as Map<String, int>;

    if (genrePrefs.isEmpty) return 0.5;

    // Give bonus to under-explored genres
    if (book.genre == null) return 0.3;

    int genreCount = genrePrefs[book.genre] ?? 0;
    int maxCount = genrePrefs.values.reduce((a, b) => a > b ? a : b);


    return 1.0 - (genreCount / maxCount);
  }


  List<Product> _getFallbackRecommendations(
      List<Product> allBooks,
      int limit,
      ) {

    var recommended = allBooks.where((b) =>
    b.isBestseller == true || b.isRecommended == true
    ).toList();

    recommended.shuffle();
    return recommended.take(limit).toList();
  }


  Future<List<Product>> getSimilarBooks({
    required Product targetBook,
    required List<Product> allBooks,
    int limit = 5,
  }) async {
    Map<String, double> similarityScores = {};

    for (var book in allBooks) {
      if (book.id == targetBook.id) continue;

      double score = 0.0;


      if (book.genre == targetBook.genre && book.genre != null) {
        score += 0.5;
      }


      if (book.author == targetBook.author && book.author != null) {
        score += 0.3;
      }


      if (book.price != null && targetBook.price != null) {
        double priceDiff = (book.price! - targetBook.price!).abs().toDouble();
        if (priceDiff < 5) {
          score += 0.2;
        }
      }

      similarityScores[book.id ?? ''] = score;
    }

    var sortedBooks = allBooks.where((b) => similarityScores.containsKey(b.id)).toList();
    sortedBooks.sort((a, b) => similarityScores[b.id]!.compareTo(similarityScores[a.id]!));

    return sortedBooks.take(limit).toList();
  }
}