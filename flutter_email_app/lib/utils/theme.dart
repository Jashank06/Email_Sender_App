import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlack = Color(0xFF0A0A0A);
  static const Color secondaryBlack = Color(0xFF1A1A1A);
  static const Color accentWhite = Color(0xFFFFFFFF);
  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color glowBlue = Color(0xFF00D4FF);
  static const Color glowPurple = Color(0xFF8B5CF6);
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryBlack,
      primaryColor: glowBlue,
      colorScheme: const ColorScheme.dark(
        primary: glowBlue,
        secondary: glowPurple,
        surface: secondaryBlack,
        background: primaryBlack,
        error: errorRed,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: accentWhite,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: accentWhite,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: accentWhite.withOpacity(0.9),
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: accentWhite.withOpacity(0.7),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: glowBlue,
          foregroundColor: primaryBlack,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: glassWhite.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glowBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.poppins(
          color: accentWhite.withOpacity(0.4),
          fontSize: 14,
        ),
      ),
    );
  }

  static BoxDecoration glassmorphicDecoration({
    double opacity = 0.1,
    double blur = 10,
    Color? borderColor,
    double borderWidth = 1,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.2),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: glowBlue.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
