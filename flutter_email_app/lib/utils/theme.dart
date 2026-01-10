import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class AppTheme {
  // Primary Colors (Pure Black & White)
  static const Color primaryBlack = Color(0xFF000000);
  static const Color secondaryBlack = Color(0xFF0A0A0A);
  static const Color tertiaryBlack = Color(0xFF111111);
  static const Color accentWhite = Color(0xFFFFFFFF);
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBlack = Color(0x4D000000);
  
  // Glow Effects (Monochrome Focus)
  static const Color glowWhite = Color(0xFFFFFFFF);
  static const Color glowGrey = Color(0xFFE0E0E0);
  static const Color glowDarkGrey = Color(0xFF424242);
  
  // Status Colors (Monochrome Version but distinct)
  static const Color successWhite = Color(0xFFF5F5F5);
  static const Color errorWhite = Color(0xFFFFEBEE); // Extremely subtle red tint if needed, but mostly white
  
  // Gradients (Sleek Black/White)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentWhite, Color(0xFFB0B0B0)],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF222222), primaryBlack],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentWhite, Color(0xFF888888)],
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF),
      Color(0x0DFFFFFF),
    ],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryBlack,
      primaryColor: accentWhite,
      colorScheme: const ColorScheme.dark(
        primary: accentWhite,
        secondary: Color(0xFFE0E0E0),
        surface: secondaryBlack,
        background: primaryBlack,
        error: Color(0xFFFF5252),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: accentWhite,
          letterSpacing: -1,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: accentWhite,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 17,
          color: accentWhite.withOpacity(0.95),
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 15,
          color: accentWhite.withOpacity(0.75),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentWhite,
          foregroundColor: primaryBlack,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.all(Colors.black12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        hintStyle: GoogleFonts.outfit(
          color: accentWhite.withOpacity(0.35),
          fontSize: 15,
        ),
      ),
    );
  }

  // Enhanced Glassmorphism Decorations
  static BoxDecoration glassmorphicDecoration({
    double opacity = 0.08,
    double blur = 20,
    Color? borderColor,
    double borderWidth = 1.0,
    List<Color>? gradientColors,
    bool addShadow = true,
    double borderRadius = 24,
  }) {
    return BoxDecoration(
      gradient: gradientColors != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(opacity + 0.05),
                Colors.white.withOpacity(opacity),
              ],
            ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.15),
        width: borderWidth,
      ),
      boxShadow: addShadow
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: -10,
              ),
              if (opacity > 0)
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                  spreadRadius: 1,
                ),
            ]
          : [],
    );
  }

  static BoxDecoration cardDecoration({
    Gradient? gradient,
    Color? color,
    double borderRadius = 24,
    bool addGlow = true,
  }) {
    return BoxDecoration(
      gradient: gradient,
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.12),
        width: 1.2,
      ),
      boxShadow: addGlow
          ? [
              BoxShadow(
                color: Colors.white.withOpacity(0.01),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ]
          : [],
    );
  }

  // 3D Neumorphism / Glassmorphism mix
  static BoxDecoration neumorphicDecoration() {
    return BoxDecoration(
      color: secondaryBlack,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(5, 5),
          blurRadius: 15,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.05),
          offset: const Offset(-5, -5),
          blurRadius: 15,
        ),
      ],
    );
  }

  // Shimmer Effect for Loading
  static List<Color> get shimmerGradient => [
        Colors.white.withOpacity(0.03),
        Colors.white.withOpacity(0.08),
        Colors.white.withOpacity(0.03),
      ];

  // Legacy Compatibility Colors (Monochromed)
  static const Color accentPurple = accentWhite;
  static const Color errorRed = Colors.white70;
}
