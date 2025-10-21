import '../model/book_model.dart';

class WishlistStore {
  static List<Product> wishlist = [];

  static void addToWishlist(Product product) {
    if (!wishlist.any((p) => p.id == product.id)) {
      wishlist.add(product);
    }
  }

  static void removeFromWishlist(String id) {
    wishlist.removeWhere((p) => p.id == id);
  }
}
