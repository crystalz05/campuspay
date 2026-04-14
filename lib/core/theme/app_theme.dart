import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CampusPayTheme {
  // ── Brand Tokens (Auchi Polytechnic Identity) ──────────────────────
  static const Color primaryRed = Color(0xFF8C1515);   // Deep Crimson Red
  static const Color secondaryGold = Color(0xFFFFC400); // Warm Gold
  static const Color successGreen = Color(0xFF1D6B1D); // Forest Green
  static const Color errorRed = Color(0xFFD32F2F);     // Clear Error Red

  // ── Dark Palette ─────────────────────────────────────────────────
  static const Color _darkBg = Color(0xFF161616);       // Deep Charcoal
  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkInputBg = Color(0xFF262626);
  static const Color _darkTextPrimary = Color(0xFFFFFFFF);
  static const Color _darkTextSecondary = Color(0xFFA0A0A0);
  static const Color _darkBorder = Color(0xFF2E2E2E);

  // ── Light Palette ─────────────────────────────────────────────────
  static const Color _lightBg = Color(0xFFF8F9FA);      // Soft, airy background
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightInputBg = Color(0xFFF3F4F6);
  static const Color _lightTextPrimary = Color(0xFF111827);
  static const Color _lightTextSecondary = Color(0xFF6B7280);
  static const Color _lightBorder = Color(0xFFE5E7EB);

  // ── Typography ───────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    // Outfit provides a very refined, geometric sans-serif look
    final baseStyle = GoogleFonts.outfit();
    final bodyStyle = GoogleFonts.inter(color: secondaryColor); // Inter for ultimate legibility

    return TextTheme(
      displayLarge: baseStyle.copyWith(fontSize: 32, fontWeight: FontWeight.w700, color: primaryColor, letterSpacing: -0.5),
      displayMedium: baseStyle.copyWith(fontSize: 26, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: -0.5),
      displaySmall: baseStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w600, color: primaryColor, letterSpacing: -0.5),
      titleLarge: baseStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: primaryColor),
      titleMedium: baseStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor),
      titleSmall: baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
      bodyLarge: bodyStyle.copyWith(fontSize: 16, color: primaryColor, fontWeight: FontWeight.w400),
      bodyMedium: bodyStyle.copyWith(fontSize: 14, color: secondaryColor, fontWeight: FontWeight.w400),
      bodySmall: bodyStyle.copyWith(fontSize: 12, color: secondaryColor, fontWeight: FontWeight.w400),
      labelLarge: baseStyle.copyWith(fontSize: 16, color: primaryColor, fontWeight: FontWeight.w500),
      labelMedium: baseStyle.copyWith(fontSize: 14, color: primaryColor, fontWeight: FontWeight.w500),
    );
  }

  // ── Components ───────────────────────────────────────────────────
  static InputDecorationTheme _inputTheme(Color fill, Color borderColor) {
    // Ultra minimal inputs
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // Removed borders for a cleaner surface look
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryRed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed, width: 1.5),
      ),
      labelStyle: const TextStyle(fontSize: 14),
      hintStyle: TextStyle(fontSize: 14, color: _lightTextSecondary.withValues(alpha: 0.7)),
    );
  }

  static ElevatedButtonThemeData _buttonTheme(Color bg, Color fg) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), // Smoother corners
        textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    );
  }

  // ── Dark Theme ───────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBg,
      primaryColor: primaryRed,
      colorScheme: const ColorScheme.dark(
        primary: primaryRed,
        secondary: secondaryGold,
        surface: _darkSurface,
        error: errorRed,
        onPrimary: _darkTextPrimary,
        onSecondary: _darkBg,
        onSurface: _darkTextPrimary,
        onError: _darkTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBg,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: _darkTextPrimary),
      ),
      textTheme: _buildTextTheme(_darkTextPrimary, _darkTextSecondary),
      elevatedButtonTheme: _buttonTheme(primaryRed, _darkTextPrimary),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryGold,
          textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: _inputTheme(_darkInputBg, _darkBorder),
      dividerTheme: const DividerThemeData(color: _darkBorder, thickness: 1),
    );
  }

  // ── Light Theme ──────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBg,
      primaryColor: primaryRed,
      colorScheme: const ColorScheme.light(
        primary: primaryRed,
        secondary: secondaryGold,
        surface: _lightSurface,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: _lightBg,
        onSurface: _lightTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightBg,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: _lightTextPrimary),
      ),
      textTheme: _buildTextTheme(_lightTextPrimary, _lightTextSecondary),
      elevatedButtonTheme: _buttonTheme(primaryRed, Colors.white),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryRed,
          textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: _inputTheme(_lightInputBg, _lightBorder),
      dividerTheme: const DividerThemeData(color: _lightBorder, thickness: 1),
    );
  }
}
