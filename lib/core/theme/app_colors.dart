import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Facade over the active [AppPalette].
/// Bound by [ThemeController] so existing `AppColors.x` call sites follow theme.
class AppColors {
  AppColors._();

  static AppPalette _palette = AppPalette.dark;

  static AppPalette get palette => _palette;

  static void bind(AppPalette palette) {
    _palette = palette;
  }

  static Color get background => _palette.background;
  static Color get surface => _palette.surface;
  static Color get surfaceElevated => _palette.surfaceElevated;
  static Color get card => _palette.card;
  static Color get elevatedCard => _palette.elevatedCard;

  static Color get border => _palette.border;
  static Color get borderSubtle => _palette.borderSubtle;
  static Color get divider => _palette.divider;

  static Color get primary => _palette.primary;
  static Color get primaryHover => _palette.primaryHover;
  static Color get primaryDim => _palette.primaryDim;
  static Color get onPrimary => _palette.onPrimary;

  static Color get textPrimary => _palette.textPrimary;
  static Color get textSecondary => _palette.textSecondary;
  static Color get textMuted => _palette.textMuted;

  static Color get buy => _palette.buy;
  static Color get buyBg => _palette.buyBg;
  static Color get sell => _palette.sell;
  static Color get sellBg => _palette.sellBg;
  static Color get hold => _palette.hold;
  static Color get holdBg => _palette.holdBg;

  static Color get warning => _palette.warning;
  static Color get warningBg => _palette.warningBg;
  static Color get danger => _palette.danger;
  static Color get success => _palette.success;
  static Color get online => _palette.online;
  static Color get offline => _palette.offline;

  static Color get testnet => _palette.testnet;
  static Color get mainnet => _palette.mainnet;

  static Color get positive => _palette.positive;
  static Color get negative => _palette.negative;

  static Color get navGlass => _palette.navGlass;
  static Color get scrim => _palette.scrim;

  static Color get alligatorJaw => _palette.alligatorJaw;
  static Color get alligatorTeeth => _palette.alligatorTeeth;
  static Color get alligatorLips => _palette.alligatorLips;
}
