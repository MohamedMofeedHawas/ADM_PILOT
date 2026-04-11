// lib/theme/theme.dart  — UPDATED (adds AppTheme.light + bigger text)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core cockpit palette — dark
  static const Color bg         = Color(0xFF07090F);
  static const Color surface    = Color(0xFF0E1219);
  static const Color surfaceAlt = Color(0xFF141922);
  static const Color elevated   = Color(0xFF1A2130);
  static const Color border     = Color(0xFF1E2D45);
  static const Color borderGlow = Color(0xFF1A3A5C);

  // Light palette
  static const Color bgLight      = Color(0xFFF0F4F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight  = Color(0xFFD0DCE8);
  static const Color elevatedLight= Color(0xFFE8EFF6);

  // Accent
  static const Color cyan       = Color(0xFF00C8F0);
  static const Color cyanDim    = Color(0xFF0A4A5E);
  static const Color amber      = Color(0xFFFFB020);
  static const Color amberDim   = Color(0xFF4A3000);
  static const Color green      = Color(0xFF00E676);
  static const Color greenDim   = Color(0xFF003A1A);
  static const Color red        = Color(0xFFFF3D57);
  static const Color redDim     = Color(0xFF3A0010);
  static const Color purple     = Color(0xFFB060FF);
  static const Color purpleDim  = Color(0xFF280A45);

  // Text — dark mode
  static const Color textPrimary   = Color(0xFFFFFFFF);   // ← brighter
  static const Color textSecondary = Color(0xFFB0C8E0);   // ← brighter
  static const Color textTertiary  = Color(0xFF6B8CAE);

  // Text — light mode
  static const Color textPrimaryLight   = Color(0xFF0D1520);
  static const Color textSecondaryLight = Color(0xFF3A5070);
  static const Color textTertiaryLight  = Color(0xFF6B8CAE);

  static Color riskColor(String level) {
    switch (level.toUpperCase()) {
      case 'LOW':    return green;
      case 'MEDIUM': return amber;
      case 'HIGH':   return red;
      default:       return textSecondary;
    }
  }

  static Color riskDim(String level) {
    switch (level.toUpperCase()) {
      case 'LOW':    return greenDim;
      case 'MEDIUM': return amberDim;
      case 'HIGH':   return redDim;
      default:       return surfaceAlt;
    }
  }
}

class AppTheme {
  // ── DARK (original, enhanced with bigger text) ─────────────
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary:    AppColors.cyan,
        secondary:  AppColors.amber,
        surface:    AppColors.surface,
        background: AppColors.bg,
        error:      AppColors.red,
        onPrimary:  AppColors.bg,
        onSurface:  AppColors.textPrimary,
      ),
      textTheme: _buildTextTheme(AppColors.textPrimary, AppColors.textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.shareTechMono(
          color: AppColors.cyan, fontSize: 15, letterSpacing: 3,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.cyan, size: 22),
      ),
      inputDecorationTheme: _inputTheme(
        AppColors.surface, AppColors.border, AppColors.textPrimary,
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.border, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.cyan,
        labelStyle: GoogleFonts.shareTechMono(fontSize: 13, color: AppColors.textPrimary,
        fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── LIGHT ──────────────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary:    AppColors.cyan,
        secondary:  AppColors.amber,
        surface:    AppColors.surfaceLight,
        background: AppColors.bgLight,
        error:      AppColors.red,
        onPrimary:  Colors.white,
        onSurface:  AppColors.textPrimaryLight,
      ),
      textTheme: _buildTextTheme(
          AppColors.textPrimaryLight, AppColors.textSecondaryLight),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.shareTechMono(
          color: AppColors.cyan, fontSize: 15, letterSpacing: 3,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.cyan, size: 22),
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: _inputTheme(
        AppColors.surfaceLight, AppColors.borderLight,
        AppColors.textPrimaryLight,
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.borderLight, thickness: 1),
      cardColor: AppColors.surfaceLight,
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color secondary) =>
      GoogleFonts.rajdhaniTextTheme().copyWith(
        // Display
        displayLarge:  _t(primary, 32, FontWeight.w700),
        displayMedium: _t(primary, 26, FontWeight.w700),
        displaySmall:  _t(primary, 22, FontWeight.w700),
        // Headline
        headlineLarge:  _t(primary, 20, FontWeight.w700),
        headlineMedium: _t(primary, 18, FontWeight.w600),
        headlineSmall:  _t(primary, 16, FontWeight.w600),
        // Title
        titleLarge:  _t(primary, 16, FontWeight.w700),
        titleMedium: _t(primary, 15, FontWeight.w600),
        titleSmall:  _t(primary, 14, FontWeight.w600),
        // Body — BIGGER than before
        bodyLarge:   _t(primary, 16, FontWeight.w500),
        bodyMedium:  _t(primary, 15, FontWeight.w400),
        bodySmall:   _t(secondary, 13, FontWeight.w400),
        // Label
        labelLarge:  _t(primary, 14, FontWeight.w600),
        labelMedium: _t(secondary, 13, FontWeight.w500),
        labelSmall:  _t(secondary, 12, FontWeight.w400),
      );

  static TextStyle _t(Color c, double s, FontWeight w) =>
      TextStyle(color: c, fontSize: s, fontWeight: w);

  static InputDecorationTheme _inputTheme(
      Color fill, Color border, Color text) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        labelStyle: GoogleFonts.rajdhani(fontSize: 14, color: AppColors.cyan),
        hintStyle: GoogleFonts.shareTechMono(
            fontSize: 13, color: AppColors.textTertiary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}

// ── Responsive helper (unchanged) ─────────────────────────────
class R {
  static bool isMobile(BuildContext ctx)  => MediaQuery.of(ctx).size.width < 600;
  static bool isTablet(BuildContext ctx)  => MediaQuery.of(ctx).size.width >= 600 && MediaQuery.of(ctx).size.width < 1024;
  static bool isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1024;
  static double w(BuildContext ctx) => MediaQuery.of(ctx).size.width;
  static double h(BuildContext ctx) => MediaQuery.of(ctx).size.height;
  static EdgeInsets pad(BuildContext ctx) {
    if (isDesktop(ctx)) return const EdgeInsets.symmetric(horizontal: 80, vertical: 24);
    if (isTablet(ctx))  return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }
  static int cols(BuildContext ctx, {int m=1, int t=2, int d=3}) {
    if (isDesktop(ctx)) return d;
    if (isTablet(ctx))  return t;
    return m;
  }
}