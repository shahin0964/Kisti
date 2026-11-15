import 'package:flutter/material.dart';

class ThemePreset {
  final String id;
  final String name;
  final String subtitle;
  final String icon;
  final Color bgDarkVoid;
  final Color bgMidnight;
  final Color bgCard;
  final Color neonEmerald; // Primary accent
  final Color cyberCyan; // Secondary accent
  final Color electricViolet; // Tertiary accent
  final Color sunsetCoral; // Alert / danger
  final Color amberGold; // Gold / warm
  final Color sunsetAmber; // Amber / orange
  final Color bgSurfaceElevated;
  final Color orb1;
  final Color orb2;
  final Color orb3;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.bgDarkVoid,
    required this.bgMidnight,
    required this.bgCard,
    required this.neonEmerald,
    required this.cyberCyan,
    required this.electricViolet,
    required this.sunsetCoral,
    required this.amberGold,
    required this.sunsetAmber,
    required this.bgSurfaceElevated,
    required this.orb1,
    required this.orb2,
    required this.orb3,
  });
}

class LiquidGlassTheme {
  // Available Theme Presets
  static const List<ThemePreset> presets = [
    ThemePreset(
      id: 'cyber_neon',
      name: 'সাইবার নিয়ন (ডিফল্ট)',
      subtitle: 'অবসিডিয়ান ডার্ক, নিয়ন এমারেল্ড ও সাইবার সায়ান গ্লাস',
      icon: '⚡',
      bgDarkVoid: Color(0xFF06090F),
      bgMidnight: Color(0xFF0B1220),
      bgCard: Color(0xFF111A2E),
      neonEmerald: Color(0xFF00F5A0),
      cyberCyan: Color(0xFF00D9F5),
      electricViolet: Color(0xFFA855F7),
      sunsetCoral: Color(0xFFFF4D6D),
      amberGold: Color(0xFFFFB703),
      sunsetAmber: Color(0xFFFF9E00),
      bgSurfaceElevated: Color(0xFF111A2E),
      orb1: Color(0xFF00D9F5),
      orb2: Color(0xFF00F5A0),
      orb3: Color(0xFFA855F7),
    ),
    ThemePreset(
      id: 'purple_galaxy',
      name: 'পার্পল গ্যালাক্সি',
      subtitle: 'ডিপ অ্যামেথিস্ট, রয়্যাল ভায়োলেট ও নেবুলা গ্লাস',
      icon: '🌌',
      bgDarkVoid: Color(0xFF0A0514),
      bgMidnight: Color(0xFF130926),
      bgCard: Color(0xFF1E0E38),
      neonEmerald: Color(0xFFC084FC),
      cyberCyan: Color(0xFFA855F7),
      electricViolet: Color(0xFFE879F9),
      sunsetCoral: Color(0xFFFB7185),
      amberGold: Color(0xFFFDE047),
      sunsetAmber: Color(0xFFF472B6),
      bgSurfaceElevated: Color(0xFF241042),
      orb1: Color(0xFFA855F7),
      orb2: Color(0xFFC084FC),
      orb3: Color(0xFFE879F9),
    ),
    ThemePreset(
      id: 'midnight_ocean',
      name: 'মিডনাইট ওশান',
      subtitle: 'অতল সমুদ্রের নীল, সাইবার স্কাই ও একুয়াম্যারিন',
      icon: '🌊',
      bgDarkVoid: Color(0xFF030B17),
      bgMidnight: Color(0xFF07172E),
      bgCard: Color(0xFF0E2547),
      neonEmerald: Color(0xFF00E5FF),
      cyberCyan: Color(0xFF38BDF8),
      electricViolet: Color(0xFF2DD4BF),
      sunsetCoral: Color(0xFFFF5252),
      amberGold: Color(0xFFFFC107),
      sunsetAmber: Color(0xFFFF9800),
      bgSurfaceElevated: Color(0xFF122E54),
      orb1: Color(0xFF00E5FF),
      orb2: Color(0xFF38BDF8),
      orb3: Color(0xFF2DD4BF),
    ),
    ThemePreset(
      id: 'sunset_gold',
      name: 'লাক্সারি গোল্ড ও সানসেট',
      subtitle: 'ওয়ার্ম ব্ল্যাক, রাজকীয় অ্যাম্বার ও গোল্ডেন গ্লো',
      icon: '👑',
      bgDarkVoid: Color(0xFF0F0B05),
      bgMidnight: Color(0xFF1C1308),
      bgCard: Color(0xFF2C1E0D),
      neonEmerald: Color(0xFFFFB703),
      cyberCyan: Color(0xFFFF9E00),
      electricViolet: Color(0xFFFB923C),
      sunsetCoral: Color(0xFFF43F5E),
      amberGold: Color(0xFFFFD166),
      sunsetAmber: Color(0xFFFF9E00),
      bgSurfaceElevated: Color(0xFF38250E),
      orb1: Color(0xFFFFB703),
      orb2: Color(0xFFFF9E00),
      orb3: Color(0xFFFB923C),
    ),
    ThemePreset(
      id: 'crimson_ruby',
      name: 'ক্রিমসন রুবি',
      subtitle: 'উজ্জ্বল রুবি রেড, নিয়ন কোরাল ও ডার্ক রোজ',
      icon: '💎',
      bgDarkVoid: Color(0xFF120408),
      bgMidnight: Color(0xFF220810),
      bgCard: Color(0xFF360C19),
      neonEmerald: Color(0xFFFF2E63),
      cyberCyan: Color(0xFFFF4D6D),
      electricViolet: Color(0xFFFB7185),
      sunsetCoral: Color(0xFFFF0055),
      amberGold: Color(0xFFFFB703),
      sunsetAmber: Color(0xFFFB923C),
      bgSurfaceElevated: Color(0xFF421020),
      orb1: Color(0xFFFF2E63),
      orb2: Color(0xFFFF4D6D),
      orb3: Color(0xFFFB7185),
    ),
    ThemePreset(
      id: 'matrix_green',
      name: 'ম্যাট্রিক্স গ্রিন',
      subtitle: 'হাইপার টার্মিনাল কার্বন, টক্সিক লাইম ও মিন্ট',
      icon: '🌿',
      bgDarkVoid: Color(0xFF030C07),
      bgMidnight: Color(0xFF07190F),
      bgCard: Color(0xFF0D2919),
      neonEmerald: Color(0xFF10B981),
      cyberCyan: Color(0xFF22C55E),
      electricViolet: Color(0xFF34D399),
      sunsetCoral: Color(0xFFF43F5E),
      amberGold: Color(0xFFEAB308),
      sunsetAmber: Color(0xFFF59E0B),
      bgSurfaceElevated: Color(0xFF103320),
      orb1: Color(0xFF10B981),
      orb2: Color(0xFF22C55E),
      orb3: Color(0xFF34D399),
    ),
  ];

  static String currentThemeId = 'cyber_neon';

  static ThemePreset get currentPreset {
    return presets.firstWhere(
      (p) => p.id == currentThemeId,
      orElse: () => presets.first,
    );
  }

  // Core Static Const Palette (100% const compatibility with all widgets)
  static const Color bgDarkVoid = Color(0xFF06090F);
  static const Color bgMidnight = Color(0xFF0B1220);
  static const Color bgCard = Color(0xFF111A2E);

  static const Color neonEmerald = Color(0xFF00F5A0);
  static const Color cyberCyan = Color(0xFF00D9F5);
  static const Color electricViolet = Color(0xFFA855F7);
  static const Color sunsetCoral = Color(0xFFFF4D6D);
  static const Color amberGold = Color(0xFFFFB703);
  static const Color sunsetAmber = Color(0xFFFF9E00);
  static const Color bgSurfaceElevated = Color(0xFF111A2E);

  static const Color orb1 = Color(0xFF00D9F5);
  static const Color orb2 = Color(0xFF00F5A0);
  static const Color orb3 = Color(0xFFA855F7);

  // Dynamic active theme properties (updated on theme switch)
  static Color activeBgDarkVoid = const Color(0xFF06090F);
  static Color activeBgMidnight = const Color(0xFF0B1220);
  static Color activeBgCard = const Color(0xFF111A2E);
  static Color activeNeonEmerald = const Color(0xFF00F5A0);
  static Color activeCyberCyan = const Color(0xFF00D9F5);
  static Color activeElectricViolet = const Color(0xFFA855F7);
  static Color activeSunsetCoral = const Color(0xFFFF4D6D);
  static Color activeAmberGold = const Color(0xFFFFB703);
  static Color activeSunsetAmber = const Color(0xFFFF9E00);
  static Color activeBgSurfaceElevated = const Color(0xFF111A2E);
  static Color activeOrb1 = const Color(0xFF00D9F5);
  static Color activeOrb2 = const Color(0xFF00F5A0);
  static Color activeOrb3 = const Color(0xFFA855F7);

  static void applyTheme(String themeId) {
    final preset = presets.firstWhere(
      (p) => p.id == themeId,
      orElse: () => presets.first,
    );
    currentThemeId = preset.id;
    activeBgDarkVoid = preset.bgDarkVoid;
    activeBgMidnight = preset.bgMidnight;
    activeBgCard = preset.bgCard;
    activeNeonEmerald = preset.neonEmerald;
    activeCyberCyan = preset.cyberCyan;
    activeElectricViolet = preset.electricViolet;
    activeSunsetCoral = preset.sunsetCoral;
    activeAmberGold = preset.amberGold;
    activeSunsetAmber = preset.sunsetAmber;
    activeBgSurfaceElevated = preset.bgSurfaceElevated;
    activeOrb1 = preset.orb1;
    activeOrb2 = preset.orb2;
    activeOrb3 = preset.orb3;
  }

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
      colorScheme: ColorScheme.dark(
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
