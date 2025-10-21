import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentFailedScreen extends StatelessWidget {
  final String reason;
  final String transactionId;
  final String amount;
  final String cardType;

  const PaymentFailedScreen({
    super.key,
    required this.reason,
    required this.transactionId,
    required this.amount,
    required this.cardType,
  });

  // Map translated Firestore cardType values to translation keys
  static const Map<String, String> _valueToTranslationKey = {
    'Unknown': 'unknown',
    'অজানা': 'unknown',
    'Cash on Delivery': 'cash_on_delivery',
    'ক্যাশ অন ডেলিভারি': 'cash_on_delivery',
    'Online Payment': 'online_payment',
    'অনলাইন পেমেন্ট': 'online_payment',
  };

  @override
  Widget build(BuildContext context) {
    // Map cardType to translation key for display, or use raw value if not localized
    final cardTypeKey = _valueToTranslationKey[cardType] ?? cardType;

    return Scaffold(
      appBar: AppBar(title: Text('payment_failed'.tr)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              Text(
                'transaction_failed'.tr,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                reason,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text('${'transaction_id'.tr}: $transactionId'),
              Text('${'amount'.tr}: ${'currency'.tr} $amount'),
              Text('${'payment_method'.tr}: ${cardTypeKey.tr}'),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('try_again'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}