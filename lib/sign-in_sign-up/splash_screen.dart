import 'package:books_smart_app/sign-in_sign-up/wrapper.dart';
import 'package:books_smart_app/widgets/screen_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../utilities/asset_paths.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String name = '/splash_screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _moveToNextScreen();
  }

  Future<void> _moveToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, Wrapper.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : null,
      body: ScreenBackground(
          child:
          Center(
              child:
              SvgPicture.asset(AssetPaths.logoSvg)
          )
      ),
    );
  }
}