import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends StateNotifier<AppLocale> {
  LanguageNotifier() : super(AppLocale.en) {
    _loadLanguage();
  }

  static const String _languageKey = 'selected_language';

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);

      if (languageCode != null) {
        final locale = _getLocaleFromCode(languageCode);
        if (locale != null) {
          state = locale;
          LocaleSettings.setLocale(locale);
        }
      }
    } catch (e) {
      // If loading fails, use default language
    }
  }

  Future<void> setLanguage(AppLocale locale) async {
    try {
      state = locale;
      LocaleSettings.setLocale(locale);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      // Handle error
    }
  }

  AppLocale? _getLocaleFromCode(String code) {
    switch (code) {
      case 'en':
        return AppLocale.en;
      case 'zh':
        return AppLocale.zhCn;
      default:
        return null;
    }
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLocale>(
  (ref) => LanguageNotifier(),
);
