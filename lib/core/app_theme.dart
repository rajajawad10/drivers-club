
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF1E3A8A); // Deep Navy Blue
  static const Color secondaryColor = Color(0xFFC0A062); // Luxury Gold
  static const Color accentColor = Color(0xFF10B981); // Success Green (e.g., Avail Rooms)
  static const Color errorColor = Color(0xFFEF4444); // Error Red

  static const Color darkBackground = Color(0xFF111827); // Dark Charcoal
  static const Color darkSurface = Color(0xFF1F2937); // Lighter Charcoal
  static const Color lightBackground = Color(0xFFF3F4F6); // Soft Gray
  static const Color lightSurface = Color(0xFFFFFFFF); // White

  // Text Styles
  static TextTheme _textTheme(bool isDark) {
    Color textColor = isDark ? Colors.white : const Color(0xFF111827);
    return TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: textColor.withValues(alpha: 0.8),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: textColor.withValues(alpha: 0.7),
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
        onSurface: Color(0xFF111827),
      ),
      textTheme: _textTheme(false),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor, // Keep navy or switch?
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: secondaryColor, // Gold as primary in dark mode
        secondary: primaryColor,
        surface: darkSurface,
        onSurface: Colors.white,
      ),
      textTheme: _textTheme(true),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: secondaryColor),
        titleTextStyle: TextStyle(color: secondaryColor, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
