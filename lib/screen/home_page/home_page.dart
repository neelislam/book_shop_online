import 'package:books_smart_app/screen/home_page/theme_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:books_smart_app/screen/home_page/user_account_settings.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controller_from_firebase/home_controller.dart';
import '../../controller_from_firebase/recommendation_controller.dart';
import '../book_page/screen/book_detail_screen.dart';
import 'books_screen.dart';
import '../payment_pages/cart_screen.dart';
import '../../model/book_model.dart';
import '../../utilities/asset_paths.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:books_smart_app/model/approved_book.dart';
import '../preowned_book_pages/explore_used_book_market.dart';
import '../preowned_book_pages/sell_book.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String name = '/home';

  @override
  State<HomePage> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePage>
    with TickerProviderStateMixin {
  final RecommendationController _recommendationController =
  Get.put(RecommendationController());
  final user = FirebaseAuth.instance.currentUser;

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {

    });
    Get.snackbar(
      'success'.tr,
      'signed_out'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2D3748),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  int _selectedBottomIndex = 1;
  late PageController _pageController;
  final TextEditingController _searchBookByNameController =
  TextEditingController();
  final HomeController _controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedBottomIndex);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _recommendationController.loadAIRecommendations(_controller.products);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchBookByNameController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    if (_selectedBottomIndex == index) return;
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        titleSpacing: 1,
        title: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SvgPicture.asset(
            AssetPaths.logoSvg,
            height: 220,
          ),
        ),
        actions: [
          _buildAppBarIcon(
              Icons.favorite_outline, Colors.deepPurpleAccent.shade400, () {
            Navigator.pushNamed(context, '/wishlist-screen');
          }),
          _buildAppBarIcon(Icons.sell_outlined, const Color(0xFF800080), () {
            Get.to(() => SellBookPage());
          }),
          Builder(
            builder: (context) {
              return _buildAppBarIcon(Icons.menu, const Color(0xFF6366F1), () {
                Scaffold.of(context).openEndDrawer();
              });
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        child: Column(
          children: [
            Container(
              height: 240,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_outline,
                            size: 120, color: Color(0xFF6366F1)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.email ?? 'no_email'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 13),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                'ID: ${user?.uid ?? 'no_uid'.tr}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                if (user?.uid != null) {
                                  Clipboard.setData(
                                      ClipboardData(text: user!.uid));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied to clipboard'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              child: const Icon(
                                Icons.copy,
                                size: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDrawerItem(
                    icon: Icons.logout_outlined,
                    title: 'sign_in_out'.tr,
                    gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                    onTap: () => signOut(),
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'settings'.tr,
                    gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings-screen');
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    icon: Icons.language_outlined,
                    title: 'language'.tr,
                    subtitle: GetStorage().read("language") == 'bn_BD'
                        ? 'language_bangla'.tr
                        : 'language_english'.tr,
                    gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/language-screen');
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'dark_mode'.tr,
                    gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const ThemeScreen());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedBottomIndex = index;
          });
        },
        children: [
          const BooksScreen(),
          _buildHomeContent(),
          const CartScreen(),
          const UserAccountSettings(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.menu_book_outlined, 'books'.tr),
                _buildNavItem(1, Icons.home_outlined, 'home'.tr),
                _buildNavItem(2, Icons.shopping_bag_outlined, 'Cart'.tr),
                _buildNavItem(3, Icons.person_outline, 'profile'.tr),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedBottomIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF)),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF374151) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextFormField(
            controller: _searchBookByNameController,
            onChanged: (_) => setState(() {}),
            style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'search'.tr,
              hintStyle: TextStyle(color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF), fontSize: 15),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF6366F1), size: 22),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.purple, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Get.to(() => const ApprovedBooksMarket());
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.storefront_outlined,
                        color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Explore Pre-Owned Book Market'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Obx(() {
          _controller.searchBooks(_searchBookByNameController.text);

          return Column(
            children: [
              Obx(() {
                if (_recommendationController.isLoadingRecommendations.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                      strokeWidth: 3,
                    ),
                  );
                }

                if (_recommendationController.aiRecommendedBooks.isEmpty) {
                  return const SizedBox.shrink();
                }

                final books = _recommendationController.aiRecommendedBooks
                    .take(6)
                    .toList();
                return _buildHorizontalBookSection(
                  title: 'recommended_for_you'.tr,
                  books: books,
                  isAI: true,
                );
              }),
              if (_controller.discountBooks.isNotEmpty)
                _buildHorizontalBookSection(
                  title: 'discount'.tr,
                  books: _controller.discountBooks,
                ),
              if (_controller.bestsellerBooks.isNotEmpty)
                _buildHorizontalBookSection(
                  title: 'bestseller'.tr,
                  books: _controller.bestsellerBooks,
                ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('approvedBooks')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: Color(0xFF6366F1),
                        strokeWidth: 3,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final books = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ApprovedBook.fromJson(data, doc.id);
                  }).toList();

                  final searchText =
                  _searchBookByNameController.text.toLowerCase();
                  final filteredBooks = searchText.isEmpty
                      ? books
                      : books
                      .where(
                          (b) => b.title.toLowerCase().contains(searchText))
                      .toList();

                  if (filteredBooks.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF6366F1)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.verified,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pre-owned Book'.tr,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  'Approved by BooksSmart!'.tr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6366F1),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredBooks[index];
                            return _buildElegantBookCard(
                              imageUrl: book.imageUrl ?? '',
                              title: book.title,
                              price: book.price,
                              onTap: () {},
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                },
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildHorizontalBookSection({
    required String title,
    required List<Product> books,
    bool isAI = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (isAI)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 18),
              ),
            if (isAI) const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return _buildElegantBookCard(
                imageUrl: book.image ?? '',
                title: book.name ?? '',
                price: book.price ?? 0,
                onTap: () => Get.to(() => BookDetailScreen(product: book)),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildElegantBookCard({
    required String imageUrl,
    required String title,
    required num price,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                    child: Center(
                      child: Icon(Icons.auto_stories,
                          size: 48, color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "\৳${price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF6366F1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}