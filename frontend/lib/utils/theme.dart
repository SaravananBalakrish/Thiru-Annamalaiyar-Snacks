import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kGold,
        brightness: Brightness.light,
        primary: kGold,
        onPrimary: kWhite,
        secondary: kRed,
        onSecondary: kWhite,
        surface: kWhite,
        onSurface: kText,
        onSurfaceVariant: kTextMuted,
        outline: kGoldLight,
        outlineVariant: kGold.withValues(alpha: 0.2),
        surfaceContainerHighest: kCream,
        surfaceContainer: kGoldPale,
        error: kRed,
        onError: kWhite,
      ),
      textTheme: GoogleFonts.latoTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: kText,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: kText,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          color: kText,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: const TextStyle(
          color: kText,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        titleSmall: const TextStyle(
          color: kText,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        bodyLarge: const TextStyle(color: kText),
        bodyMedium: const TextStyle(color: kText),
        bodySmall: const TextStyle(color: kTextMuted),
        labelSmall: const TextStyle(color: kTextMuted, letterSpacing: 1.1),
      ),
      scaffoldBackgroundColor: kCream,
      appBarTheme: AppBarTheme(
        backgroundColor: kCream,
        foregroundColor: kText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: kText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: kWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusM),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kGold,
          foregroundColor: kWhite,
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusM),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: kPaddingM,
            horizontal: kPaddingL,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusM),
          borderSide: BorderSide(color: kGold.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusM),
          borderSide: BorderSide(color: kGold.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusM),
          borderSide: const BorderSide(color: kGold, width: 2),
        ),
        hintStyle: const TextStyle(color: kTextMuted),
        contentPadding: const EdgeInsets.all(kPaddingM),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kGold,
        brightness: Brightness.dark,
        primary: kGold,
        onPrimary: kWhite,
        secondary: kRed,
        onSecondary: kWhite,
        surface: const Color(0xFF1E1E1E),
        onSurface: Colors.white,
        onSurfaceVariant: Colors.white70,
        outline: Colors.white24,
        outlineVariant: Colors.white10,
        surfaceContainerHighest: const Color(0xFF2C2C2C),
        surfaceContainer: const Color(0xFF252525),
        error: const Color(0xFFCF6679),
        onError: Colors.black,
      ),
      textTheme: GoogleFonts.latoTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        titleSmall: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        bodyLarge: const TextStyle(color: Colors.white70),
        bodyMedium: const TextStyle(color: Colors.white70),
        bodySmall: const TextStyle(color: Colors.white54),
        labelSmall: const TextStyle(color: Colors.white54, letterSpacing: 1.1),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusM),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kGold,
          foregroundColor: kWhite,
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusM),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: kPaddingM,
            horizontal: kPaddingL,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusM),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusM),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusM),
          borderSide: const BorderSide(color: kGold, width: 2),
        ),
        hintStyle: const TextStyle(color: Colors.white38),
        contentPadding: const EdgeInsets.all(kPaddingM),
      ),
    );
  }
}
