import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color primaryBlueDark = Color(0xFF0D47A1);
  static const Color accentAmber = Color(0xFFFFB300);
  static const Color accentOrange = Color(0xFFFF6D00);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color errorRed = Color(0xFFC62828);
  static const Color warningYellow = Color(0xFFF9A825);

  // Dark Theme Surfaces
  static const Color bgDark = Color(0xFF0A0E1A);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color cardDark = Color(0xFF1A2236);
  static const Color cardDark2 = Color(0xFF1E293B);
  static const Color dividerDark = Color(0xFF2D3748);

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: accentAmber,
        onSecondary: Colors.black,
        surface: surfaceDark,
        onSurface: textPrimary,
        error: errorRed,
        onError: Colors.white,
        outline: dividerDark,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 32),
        displayMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 26),
        headlineLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 22),
        headlineMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        headlineSmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
        titleMedium: GoogleFonts.inter(color: textSecondary, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge: GoogleFonts.inter(color: textPrimary, fontSize: 15),
        bodyMedium: GoogleFonts.inter(color: textSecondary, fontSize: 13),
        labelLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        labelSmall: GoogleFonts.inter(color: textMuted, fontSize: 11),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        color: cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorRed),
        ),
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerDark,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDark,
        contentTextStyle: GoogleFonts.inter(color: textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
