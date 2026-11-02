import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFF7E4D6);
  static const Color primary = Color(0xFFE8703F);
  static const Color secondary = Color(0xFFD9922E);
  static const Color textDark = Color(0xFF3A2015);
  static const Color textMuted = Color(0xFF8A4A2E);
  static const Color cardBorder = Color(0xFFE8CBB4);
  static const Color success = Color(0xFF0F6E56);
  static const Color successBg = Color(0xFFC3E4D5);
  static const Color navInactive = Color(0xFF9C8A7D);

  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        background: background,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyMedium: TextStyle(color: textDark),
      ),
    );
  }
}
