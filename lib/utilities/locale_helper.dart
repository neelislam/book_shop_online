import 'dart:ui';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer' as developer;

/// A helper class for managing localization settings and persistence.
class LocaleHelper {
  static const String _localeKey = 'locale';
  static final GetStorage _storage = GetStorage();

  /// Supported locales
  static const Locale enUS = Locale('en', 'US');
  static const Locale bnBD = Locale('bn', 'BD');
  static const List<Locale> supportedLocales = [enUS, bnBD];

  /// Loads the saved locale from storage.
  /// Defaults to English (en_US) if none is found or invalid.
  static Locale _loadInitialLocale() {
    final String? savedLocale = _storage.read<String>(_localeKey);

    if (savedLocale == null || savedLocale.isEmpty) {
      developer.log('🌐 No saved locale found. Defaulting to en_US.');
      return enUS;
    }

    final parts = savedLocale.split('_');
    if (parts.length == 2) {
      final locale = Locale(parts[0], parts[1]);
      if (supportedLocales.contains(locale)) {
        developer.log('🌍 Loaded saved locale: $savedLocale');
        return locale;
      } else {
        developer.log('⚠️ Unsupported saved locale: $savedLocale. Using default (en_US).');
      }
    } else {
      developer.log('⚠️ Invalid saved locale format: $savedLocale. Using default (en_US).');
    }

    return enUS;
  }

  /// Returns the initial locale to use at app startup.
  static Locale getInitialLocale() => _loadInitialLocale();

  /// Saves the given [locale] to local storage.
  static void saveLocale(Locale locale) {
    final localeCode = '${locale.languageCode}_${locale.countryCode ?? ''}';
    _storage.write(_localeKey, localeCode);
    developer.log('💾 Saved locale: $localeCode');
  }

  /// Updates the app’s locale and saves it persistently.
  static void updateLocale(Locale locale) {
    if (supportedLocales.any((l) =>
    l.languageCode == locale.languageCode &&
        l.countryCode == locale.countryCode)) {
      developer.log('🔄 Updating locale to: ${locale.languageCode}_${locale.countryCode}');
      Get.updateLocale(locale);
      saveLocale(locale);
    } else {
      developer.log('❌ Attempted to update to unsupported locale: $locale');
    }
  }

  /// Clears any saved locale (for testing or reset).
  static void clearSavedLocale() {
    _storage.remove(_localeKey);
    developer.log('🧹 Cleared saved locale.');
  }
}
