import 'package:books_smart_app/widgets/screen_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../sign-in_sign-up/sign_in_screen.dart';

class VerificationMailSent extends StatelessWidget {
  final String? email;

  const VerificationMailSent({super.key, this.email});
  static const String name = '/verification_password_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'password_reset_email_sent'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Text(
                  email != null
                      ? 'password_reset_email_sent_message'.trParams({'email': email!})
                      : 'password_reset_link_info'.tr,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                const Icon(
                  Icons.email,
                  size: 100,
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(SignInScreen.name);
                  },
                  child: Text('sign_in'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}