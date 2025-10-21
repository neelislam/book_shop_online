import 'package:books_smart_app/screen/home_page/settings_screen.dart';
import 'package:books_smart_app/screen/home_page/theme_screen.dart';
import 'package:books_smart_app/sign-in_sign-up/sign_in_screen.dart';
import 'package:books_smart_app/sign-in_sign-up/splash_screen.dart';
import 'package:books_smart_app/sign-in_sign-up/verification_mail_sent.dart';
import 'package:books_smart_app/sign-in_sign-up/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:books_smart_app/translations/app_translations.dart';
import 'firebase_option.dart';
import 'package:books_smart_app/sign-in_sign-up/sign_up_screen.dart';
import 'package:books_smart_app/screen/home_page/home_page.dart';
import 'package:books_smart_app/sign-in_sign-up/forget_password_screen.dart';
import 'package:books_smart_app/screen/home_page/user_account_settings.dart';
import 'package:books_smart_app/screen/home_page/books_screen.dart';
import 'package:books_smart_app/screen/payment_pages/cart_screen.dart';
import 'package:books_smart_app/screen/home_page/profile_page.dart';
import 'package:books_smart_app/translations/language_screen.dart';
import 'package:books_smart_app/screen/home_page/wishlist_screen.dart';
import 'package:books_smart_app/screen/preowned_book_pages/second_hand_detail.dart';
import 'package:books_smart_app/utilities/locale_helper.dart';
import 'package:books_smart_app/controller_from_firebase/language_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: firebaseOptions);

  Get.put(LanguageController());

  final storage = GetStorage();
  final savedLocaleCode = storage.read('locale') ?? 'en';
  final initialLocale =
  savedLocaleCode == 'bn' ? LocaleHelper.bnBD : LocaleHelper.enUS;

  runApp(BooksSmartApp(initialLocale: initialLocale));
}

class BooksSmartApp extends StatelessWidget {
  final Locale initialLocale;

  const BooksSmartApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'app_name'.tr,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: LocaleHelper.enUS,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('en', 'US'),
        Locale('bn', 'BD'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: SplashScreen.name,
      routes: {
        SplashScreen.name: (context) => const SplashScreen(),
        Wrapper.name: (context) => const Wrapper(),
        SignInScreen.name: (context) => const SignInScreen(),
        SignUpScreen.name: (context) => const SignUpScreen(),
        HomePage.name: (context) => const HomePage(),
        ForgetPasswordScreen.name: (context) => const ForgetPasswordScreen(),
        UserAccountSettings.name: (context) => const UserAccountSettings(),
        BooksScreen.name: (context) => const BooksScreen(),
        CartScreen.name: (context) => const CartScreen(),
        ProfilePageScreen.name: (context) => const ProfilePageScreen(),
        LanguageScreen.name: (context) => const LanguageScreen(),
        WishlistScreen.name: (context) => const WishlistScreen(),
        VerificationMailSent.name: (context) => const VerificationMailSent(),
        SettingsScreen.name: (context) => const SettingsScreen(),
        ThemeScreen.name: (context) => const ThemeScreen(),
        SecondHandDetail.name: (context) =>
        const Placeholder(),
      },
    );
  }
}
