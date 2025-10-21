
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/app_user.dart';


class UserService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Save user after signup
  Future<void> saveUserData({
    required String name,
    required String phone,
    required String address,
    required String profilePictureUrl,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);

      final newUser = AppUser(
        id: user.uid,
        name: name,
        phone: phone,
        address: address,
        profilePicture: profilePictureUrl,
        wishlist: [],
      );

      await userRef.set(newUser.toMap());
    }
  }

  // Fetch current user
  Future<AppUser?> getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!, doc.id);
      }
    }
    return null;
  }

  // Add book to wishlist
  Future<void> addToWishlist(String bookId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'wishlist': FieldValue.arrayUnion([bookId]),
      });
    }
  }

  // Remove book from wishlist
  Future<void> removeFromWishlist(String bookId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'wishlist': FieldValue.arrayRemove([bookId]),
      });
    }
  }
}
