import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/second_hand_book.dart';
import 'package:url_launcher/url_launcher.dart';

class SecondHandDetail extends StatelessWidget {
  static const String name = '/second_hand_detail';
  final SecondHandBook book;

  const SecondHandDetail({super.key, required this.book});

  Future<void> _callSeller(BuildContext context) async {
    final phone = book.contact;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('no_contact_provided'.tr)));
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('cannot_launch_call'.tr)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = book.image ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(book.name ?? 'second_hand_book'.tr),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.isAbsolute == true)
                  ? Image.network(
                imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 100),
              )
                  : Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.book, size: 100),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              book.name ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green),
                Text(
                  '${'price'.tr}: ৳${book.price ?? 0}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.grade, color: Colors.amber),
                const SizedBox(width: 6),
                Text(
                  '${'condition'.tr}: ${book.condition ?? 'unknown'.tr}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              'details'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.details ?? 'no_details_provided'.tr,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => _callSeller(context),
                    icon: const Icon(Icons.phone, color: Colors.white),
                    label: Text(
                      'contact_seller'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${'contact_number'.tr}: ${book.contact ?? 'no_contact'.tr}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}