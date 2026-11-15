import 'package:flutter/material.dart';

class LiquidGlassTheme {
  // Background gradient shades
  static const Color bgDarkVoid = Color(0xFF06090F);
  static const Color bgMidnight = Color(0xFF0B1220);
  static const Color bgCard = Color(0xFF111A2E);

  // Futuristic Neon Glow Accents
  static const Color neonEmerald = Color(0xFF00F5A0);
  static const Color cyberCyan = Color(0xFF00D9F5);
  static const Color electricViolet = Color(0xFFA855F7);
  static const Color sunsetCoral = Color(0xFFFF4D6D);
  static const Color amberGold = Color(0xFFFFB703);
  static const Color sunsetAmber = Color(0xFFFF9E00);
  static const Color bgSurfaceElevated = Color(0xFF111A2E);

  // Glassmorphic Opacities (Optimized for 60 FPS performance)
  static const double glassBlur = 10.0;
  static final Color glassFill = Colors.white.withOpacity(0.06);
  static final Color glassFillLighter = Colors.white.withOpacity(0.10);
  static final Color glassBorder = Colors.white.withOpacity(0.18);
  static final Color glassBorderSubtle = Colors.white.withOpacity(0.08);

  // Text Colors
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Box Shadows for Neon Glow
  static List<BoxShadow> neonGlow(Color color, {double intensity = 0.25, double blur = 14.0}) {
    return [
      BoxShadow(
        color: color.withOpacity(intensity),
        blurRadius: blur,
        spreadRadius: -2,
      ),
    ];
  }

  static List<BoxShadow> glassShadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.03),
        blurRadius: 1,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: bgDarkVoid,
      primaryColor: neonEmerald,
      colorScheme: const ColorScheme.dark(
        primary: neonEmerald,
        secondary: cyberCyan,
        tertiary: electricViolet,
        surface: bgMidnight,
        error: sunsetCoral,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}
