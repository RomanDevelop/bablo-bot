import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';
import 'app_palette.dart';

/// Persisted theme mode + binds [AppColors] to the active palette.
class ThemeController extends ChangeNotifier {
  ThemeController._(this._mode) {
    // Drop legacy system mode — it desynced MaterialApp vs AppColors on web.
    if (_mode == ThemeMode.system) {
      _mode = ThemeMode.dark;
    }
    _syncPalette();
  }

  static const _prefsKey = 'bablo_theme_mode';

  ThemeMode _mode;

  ThemeMode get mode => _mode;

  /// MaterialApp always gets an explicit light/dark mode.
  ThemeMode get resolvedMode => isDark ? ThemeMode.dark : ThemeMode.light;

  bool get isDark => _mode != ThemeMode.light;

  /// Single source of truth for UI chrome (never drift from [isDark]).
  AppPalette get palette => isDark ? AppPalette.dark : AppPalette.light;

  String get label => isDark ? 'Тёмная' : 'Светлая';

  static Future<ThemeController> create() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final mode = switch (raw) {
      'light' => ThemeMode.light,
      _ => ThemeMode.dark,
    };
    return ThemeController._(mode);
  }

  Future<void> setMode(ThemeMode mode) async {
    final next = mode == ThemeMode.light ? ThemeMode.light : ThemeMode.dark;
    if (_mode == next) {
      _syncPalette();
      notifyListeners();
      return;
    }
    _mode = next;
    _syncPalette();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, next == ThemeMode.light ? 'light' : 'dark');
  }

  Future<void> toggleLightDark() async {
    await setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> cycle() async {
    await setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  void _syncPalette() {
    AppColors.bind(palette);
    _applySystemUi();
  }

  void _applySystemUi() {
    final dark = isDark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: palette.background,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark,
      ),
    );
  }
}
