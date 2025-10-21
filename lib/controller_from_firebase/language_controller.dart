import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utilities/locale_helper.dart';

class LanguageController extends GetxController {
  final currentLocale = Get.locale ?? LocaleHelper.enUS.obs;


  final selectedLocale = LocaleHelper.enUS.obs;

  void changeLanguage(Locale locale) {
    selectedLocale.value = locale;
    LocaleHelper.updateLocale(locale);

    Get.snackbar(
      'success'.tr,
      'language_updated'.trParams({
        'name': locale == LocaleHelper.enUS ? 'English' : 'বাংলা',
      }),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
