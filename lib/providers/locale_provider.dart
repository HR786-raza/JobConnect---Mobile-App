import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US');
  final List<Locale> _supportedLocales = const [
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
    Locale('de', 'DE'),
    Locale('zh', 'CN'),
    Locale('ja', 'JP'),
    Locale('ar', 'SA'),
    Locale('hi', 'IN'),
  ];

  Locale get locale => _locale;
  List<Locale> get supportedLocales => _supportedLocales;

  LocaleProvider() {
    _loadLocale();
  }

  // Load saved locale
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(AppConfig.prefLanguage) ?? 'en';
      final countryCode = _getCountryCode(languageCode);
      
      _locale = Locale(languageCode, countryCode);
      notifyListeners();
    } catch (e) {
      print('Error loading locale: $e');
    }
  }

  // Set locale
  Future<void> setLocale(Locale locale) async {
    try {
      if (!_locale.languageCode.contains(locale.languageCode)) {
        _locale = locale;
        
        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConfig.prefLanguage, locale.languageCode);
        
        notifyListeners();
      }
    } catch (e) {
      print('Error setting locale: $e');
    }
  }

  // Get country code for language
  String _getCountryCode(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'US';
      case 'es':
        return 'ES';
      case 'fr':
        return 'FR';
      case 'de':
        return 'DE';
      case 'zh':
        return 'CN';
      case 'ja':
        return 'JP';
      case 'ar':
        return 'SA';
      case 'hi':
        return 'IN';
      default:
        return 'US';
    }
  }

  // Get language name in its native form
  String getCurrentLanguageName() {
    switch (_locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      case 'ar':
        return 'العربية';
      case 'hi':
        return 'हिन्दी';
      default:
        return 'English';
    }
  }

  // Get flag emoji for current language
  String getCurrentLanguageFlag() {
    switch (_locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'zh':
        return '🇨🇳';
      case 'ja':
        return '🇯🇵';
      case 'ar':
        return '🇸🇦';
      case 'hi':
        return '🇮🇳';
      default:
        return '🇺🇸';
    }
  }

  // Check if RTL language
  bool get isRtl {
    return _locale.languageCode == 'ar';
  }

  // Get text direction
  TextDirection get textDirection {
    return isRtl ? TextDirection.rtl : TextDirection.ltr;
  }
}