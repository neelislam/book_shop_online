import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CurrentOrderTrack extends StatelessWidget {
  const CurrentOrderTrack({super.key});

  // Map Firestore status values to translation keys
  static const Map<String, String> _statusTranslations = {
    'pending': 'status_pending',
    'processing': 'status_processing',
    'shipped': 'status_shipped',
    'delivered': 'status_delivered',
    'Unknown': 'status_unknown',
  };

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text('track_order'.tr)),
        body: Center(
          child: Text('please_sign_in'.tr),
        ),
      );
    }

    // Reference to users orders
    final orderRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('orders')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: Text('track_order'.tr)),
      body: StreamBuilder<QuerySnapshot>(
        stream: orderRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('no_orders_found'.tr),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              String status = data['status'] ?? 'Unknown';
              String displayStatus =
                  _statusTranslations[status]?.tr ?? 'status_unknown'.tr;
              double total = (data['amount'] ?? 0).toDouble();
              DateTime createdAt =
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              String address = data['address'] ?? '';
              String transactionId = data['transactionId'] ?? 'N/A';

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${'order_id'.tr}: ${doc.id}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text("${'placed_on'.tr}: ${createdAt.toLocal()}"),
                      Text("${'transaction_id'.tr}: $transactionId"),
                      Text("${'amount'.tr}: BDT ${total.toStringAsFixed(2)}"),
                      Text("${'delivery_address'.tr}: $address"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            "${'status'.tr}: ",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Chip(
                            label: Text(
                              displayStatus.toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: _getStatusColor(status),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper function to color status chips
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}