// lib/core/theme/theme_provider.dart
// ══════════════════════════════════════════════════════════════
// Dark / Light mode toggle — persisted in Hive
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../theme/theme.dart';

const _kThemeBox  = 'app_settings';
const _kDarkMode  = 'dark_mode';

class ThemeProvider extends ChangeNotifier {
  late Box _box;
  bool _ready = false;

  bool _isDark = true;
  bool get isDark => _isDark;

  ThemeData get currentTheme => _isDark ? AppTheme.dark : AppTheme.light;

  Future<void> init() async {
    _box   = await Hive.openBox(_kThemeBox);
    _isDark = _box.get(_kDarkMode, defaultValue: true) as bool;
    _ready = true;
    _applySystemUI();
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    _isDark = value;
    if (_ready) await _box.put(_kDarkMode, value);
    _applySystemUI();
    notifyListeners();
  }

  void toggle() => setDark(!_isDark);

  void _applySystemUI() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor:
      _isDark ? const Color(0xFF0E1219) : const Color(0xFFF0F4F8),
    ));
  }
}