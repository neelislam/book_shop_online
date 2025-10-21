import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../screen/home_page/home_page.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final obscurePassword = true.obs;

  final rememberMe = false.obs;
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  void _checkSession() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User already logged in, go to HomePage
      Get.offAllNamed(HomePage.name);
    }
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (rememberMe.value) {
        storage.write('email', emailController.text.trim());
        storage.write('password', passwordController.text.trim());
      } else {
        storage.remove('email');
        storage.remove('password');
      }

      Get.offAllNamed(HomePage.name);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'enter_valid_email'.tr;
          break;
        case 'user-not-found':
          errorMessage = 'user_not_found'.tr;
          break;
        case 'wrong-password':
          errorMessage = 'wrong_password'.tr;
          break;
        case 'user-disabled':
          errorMessage = 'user_disabled'.tr;
          break;
        case 'too-many-requests':
          errorMessage = 'too_many_requests'.tr;
          break;
        default:
          errorMessage = 'error'.tr;
      }
      Get.snackbar(
        'login_failed'.tr,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}