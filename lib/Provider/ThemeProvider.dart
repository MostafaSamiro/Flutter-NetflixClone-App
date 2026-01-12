import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void setDarkTheme() {
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  void setLightTheme() {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF141414),
      primaryColor: const Color(0xFFE50914), // Netflix Red
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE50914),
        secondary: Color(0xFFE50914),
        surface: Color(0xFF1F1F1F),
        error: Color(0xFFE50914),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF141414),
        elevation: 0,
      ),
      cardColor: const Color(0xFF1F1F1F),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      primaryColor: const Color(0xFFE50914), // Netflix Red
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFE50914),
        secondary: Color(0xFFE50914),
        surface: Colors.white,
        error: Color(0xFFE50914),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      cardColor: Colors.white,
    );
  }
}

class NetflixColors {
  static Color getBackground(BuildContext context, bool isDark) {
    return isDark ? const Color(0xFF141414) : const Color(0xFFF5F5F5);
  }

  static Color getCardBackground(BuildContext context, bool isDark) {
    return isDark ? const Color(0xFF1F1F1F) : Colors.white;
  }

  static Color getTextPrimary(BuildContext context, bool isDark) {
    return isDark ? Colors.white : Colors.black87;
  }

  static Color getTextSecondary(BuildContext context, bool isDark) {
    return isDark ? Colors.white.withOpacity(0.6) : Colors.black54;
  }

  static Color getBorder(BuildContext context, bool isDark) {
    return isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
  }

  static const Color netflixRed = Color(0xFFE50914);
}