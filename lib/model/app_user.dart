class AppUser {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String profilePicture;
  final List<String> wishlist;

  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.profilePicture,
    required this.wishlist,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String documentId) {
    return AppUser(
      id: documentId,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      wishlist: List<String>.from(data['wishlist'] ?? []),
    );
  }

  // Convert AppUser → Firestore for initial creation or full overwrite
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'profilePicture': profilePicture,
      'wishlist': wishlist,
    };
  }


  // This EXCLUDES 'wishlist' so it is not overwritten when using merge: true
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'profilePicture': profilePicture,
    };
  }
}