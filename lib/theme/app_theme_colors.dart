// lib/theme/app_theme_colors.dart
// ══════════════════════════════════════════════════════════════
// Context-aware color provider — used by all screens
// Usage:  final c = context.appColors;
//         Container(color: c.bg)
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

// ── Extension shortcut ─────────────────────────────────────────
extension AppThemeColorsX on BuildContext {
  AppThemeColors get appColors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? AppThemeColors.dark() : AppThemeColors.light();
  }
}

// ── Color set ─────────────────────────────────────────────────
class AppThemeColors {
  final Color bg;
  final Color surface;
  final Color elevated;
  final Color surfaceAlt;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  // ── Accent colours — same in both modes ───────────────────
  static const cyan   = Color(0xFF00C8F0);
  static const cyanDim = Color(0xFF007A99);
  static const green  = Color(0xFF00E676);
  static const amber  = Color(0xFFFFB020);
  static const red    = Color(0xFFFF3D57);
  static const purple = Color(0xFFB060FF);

  const AppThemeColors({
    required this.bg,
    required this.surface,
    required this.elevated,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });

  // ── Dark palette ───────────────────────────────────────────
  factory AppThemeColors.dark() => const AppThemeColors(
    bg:            Color(0xFF07090F),
    surface:       Color(0xFF0E1219),
    elevated:      Color(0xFF131C2B),
    surfaceAlt:    Color(0xFF0A1020),
    border:        Color(0xFF1E2D45),
    textPrimary:   Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0C8E0),
    textTertiary:  Color(0xFF4A6A8A),
  );

  // ── Light palette ──────────────────────────────────────────
  factory AppThemeColors.light() => const AppThemeColors(
    bg:            Color(0xFFF0F4F8),
    surface:       Color(0xFFFFFFFF),
    elevated:      Color(0xFFEEF2F7),
    surfaceAlt:    Color(0xFFE4EAF2),
    border:        Color(0xFFD0DCE8),
    textPrimary:   Color(0xFF0D1520),
    textSecondary: Color(0xFF3A5070),
    textTertiary:  Color(0xFF6B8CAE),
  );
}