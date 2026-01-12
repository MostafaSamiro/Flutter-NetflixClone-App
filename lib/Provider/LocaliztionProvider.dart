import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocalizationProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  void setEnglish() {
    _locale = const Locale('en');
    notifyListeners();
  }

  void setArabic() {
    _locale = const Locale('ar');
    notifyListeners();
  }

  void toggleLanguage() {
    _locale = _locale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    notifyListeners();
  }
}

// Localization Strings
class AppLocalizations {
  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'profile': 'Profile',
      'please_log_in': 'Please log in',
      'no_profile_data': 'No profile data found',
      'my_list': 'My List',
      'watched': 'Watched',
      'settings': 'Settings',
      'help_support': 'Help & Support',
      'sign_out': 'Sign Out',
      'sign_out_confirm': 'Are you sure you want to sign out?',
      'cancel': 'Cancel',
      'theme': 'Theme',
      'language': 'Language',
      'dark': 'Dark',
      'light': 'Light',
      'english': 'English',
      'arabic': 'العربية',
      'done': 'Done',
      'settings_saved': 'Settings saved successfully',
    },
    'ar': {
      'profile': 'الملف الشخصي',
      'please_log_in': 'الرجاء تسجيل الدخول',
      'no_profile_data': 'لم يتم العثور على بيانات الملف الشخصي',
      'my_list': 'قائمتي',
      'watched': 'تمت المشاهدة',
      'settings': 'الإعدادات',
      'help_support': 'المساعدة والدعم',
      'sign_out': 'تسجيل الخروج',
      'sign_out_confirm': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'cancel': 'إلغاء',
      'theme': 'السمة',
      'language': 'اللغة',
      'dark': 'داكن',
      'light': 'فاتح',
      'english': 'English',
      'arabic': 'العربية',
      'done': 'تم',
      'settings_saved': 'تم حفظ الإعدادات بنجاح',
    },
  };

  static String translate(BuildContext context, String key) {
    final localizationProvider = context.read<LocalizationProvider>();
    final languageCode = localizationProvider.locale.languageCode;
    return _localizedValues[languageCode]?[key] ?? key;
  }

  // Static method for use without context
  static String get(String languageCode, String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }
}

// Extension for easy translation
extension TranslationExtension on String {
  String tr(BuildContext context) {
    return AppLocalizations.translate(context, this);
  }
}