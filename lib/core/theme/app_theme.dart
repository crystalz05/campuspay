import 'package:flutter/material.dart';

class CampusPayTheme {
  // ── Shared Brand Token ──────────────────────────────────────────
  static const Color secondary = Color(0xFFD4AF37); // Premium Gold (both modes)
  static const Color error = Color(0xFFCC3333);
  static const Color success = Color(0xFF00C853);

  // ── Dark Palette ─────────────────────────────────────────────────
  static const Color _darkPrimary = Color(0xFF1E1E2C);
  static const Color _darkBg = Color(0xFF12121A);
  static const Color _darkSurface = Color(0xFF1C1C26);
  static const Color _darkInputBg = Color(0xFF262635);
  static const Color _darkTextPrimary = Color(0xFFFFFFFF);
  static const Color _darkTextSecondary = Color(0xFF9E9EA7);

  // ── Light Palette ─────────────────────────────────────────────────
  static const Color _lightPrimary = Color(0xFF1E1E2C);
  static const Color _lightBg = Color(0xFFF4F4F8);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightInputBg = Color(0xFFEDEDF4);
  static const Color _lightTextPrimary = Color(0xFF0F0F1A);
  static const Color _lightTextSecondary = Color(0xFF6B6B7A);

  // ── Helper ───────────────────────────────────────────────────────
  static InputDecorationTheme _inputTheme(Color fill) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: secondary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
    );
  }

  static ElevatedButtonThemeData _buttonTheme(Color fg) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondary,
        foregroundColor: fg,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    );
  }

  // ── Dark Theme ───────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBg,
      primaryColor: _darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        secondary: secondary,
        surface: _darkSurface,
        error: error,
        onPrimary: _darkTextPrimary,
        onSecondary: _darkBg,
        onSurface: _darkTextPrimary,
        onError: _darkTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _darkTextPrimary),
        titleTextStyle: TextStyle(
          color: _darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: _darkTextPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(
            color: _darkTextPrimary, fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(
            color: _darkTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(
            color: _darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(
            color: _darkTextSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400),
        labelLarge: TextStyle(
            color: _darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: _buttonTheme(_darkBg),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary,
          textStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: _inputTheme(_darkInputBg),
    );
  }

  // ── Light Theme ──────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBg,
      primaryColor: _lightPrimary,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        secondary: secondary,
        surface: _lightSurface,
        error: error,
        onPrimary: _lightTextPrimary,
        onSecondary: _lightBg,
        onSurface: _lightTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _lightTextPrimary),
        titleTextStyle: TextStyle(
          color: _lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: _lightTextPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(
            color: _lightTextPrimary, fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(
            color: _lightTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(
            color: _lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(
            color: _lightTextSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400),
        labelLarge: TextStyle(
            color: _lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: _buttonTheme(_lightBg),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary,
          textStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: _inputTheme(_lightInputBg),
    );
  }
}
