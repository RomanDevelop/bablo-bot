import 'package:flutter/material.dart';

/// Full product palette — dark & light variants of Midnight Signal.
class AppPalette {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.card,
    required this.elevatedCard,
    required this.border,
    required this.borderSubtle,
    required this.divider,
    required this.primary,
    required this.primaryHover,
    required this.primaryDim,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.buy,
    required this.buyBg,
    required this.sell,
    required this.sellBg,
    required this.hold,
    required this.holdBg,
    required this.warning,
    required this.warningBg,
    required this.danger,
    required this.success,
    required this.online,
    required this.offline,
    required this.testnet,
    required this.mainnet,
    required this.positive,
    required this.negative,
    required this.navGlass,
    required this.scrim,
    required this.alligatorJaw,
    required this.alligatorTeeth,
    required this.alligatorLips,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color card;
  final Color elevatedCard;
  final Color border;
  final Color borderSubtle;
  final Color divider;
  final Color primary;
  final Color primaryHover;
  final Color primaryDim;
  final Color onPrimary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color buy;
  final Color buyBg;
  final Color sell;
  final Color sellBg;
  final Color hold;
  final Color holdBg;
  final Color warning;
  final Color warningBg;
  final Color danger;
  final Color success;
  final Color online;
  final Color offline;
  final Color testnet;
  final Color mainnet;
  final Color positive;
  final Color negative;
  final Color navGlass;
  final Color scrim;
  final Color alligatorJaw;
  final Color alligatorTeeth;
  final Color alligatorLips;

  /// Midnight Signal — current dark identity.
  static const dark = AppPalette(
    background: Color(0xFF000814),
    surface: Color(0xFF0B1220),
    surfaceElevated: Color(0xFF121A2A),
    card: Color(0xFF121A2A),
    elevatedCard: Color(0xFF182234),
    border: Color(0xFF243247),
    borderSubtle: Color(0x14FFFFFF),
    divider: Color(0x12FFFFFF),
    primary: Color(0xFF1C6CFF),
    primaryHover: Color(0xFF3D84FF),
    primaryDim: Color(0xFF123B8C),
    onPrimary: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFF7F8FA),
    textSecondary: Color(0xFF9AA3B2),
    textMuted: Color(0xFF6B7382),
    buy: Color(0xFF00CC6A),
    buyBg: Color(0x1A00CC6A),
    sell: Color(0xFFFF4455),
    sellBg: Color(0x1AFF4455),
    hold: Color(0xFFF0B429),
    holdBg: Color(0x1AF0B429),
    warning: Color(0xFFF0B429),
    warningBg: Color(0x26F0B429),
    danger: Color(0xFFFF4455),
    success: Color(0xFF00CC6A),
    online: Color(0xFF00CC6A),
    offline: Color(0xFFFF4455),
    testnet: Color(0xFFF0B429),
    mainnet: Color(0xFF1C6CFF),
    positive: Color(0xFF00CC6A),
    negative: Color(0xFFFF4455),
    navGlass: Color(0xE60B1220),
    scrim: Color(0xB3000814),
    alligatorJaw: Color(0xFF4A90E2),
    alligatorTeeth: Color(0xFFE74C3C),
    alligatorLips: Color(0xFF00CC6A),
  );

  /// Daylight Signal — clean light fintech twin (same accent & PnL).
  static const light = AppPalette(
    background: Color(0xFFF4F6FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFEEF2F8),
    card: Color(0xFFFFFFFF),
    elevatedCard: Color(0xFFE8EDF5),
    border: Color(0xFFD5DCE8),
    borderSubtle: Color(0x14000A14),
    divider: Color(0x12000A14),
    primary: Color(0xFF1C6CFF),
    primaryHover: Color(0xFF0B57E0),
    primaryDim: Color(0xFFD6E4FF),
    onPrimary: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0B1220),
    textSecondary: Color(0xFF5C667A),
    textMuted: Color(0xFF8B93A7),
    buy: Color(0xFF00A85A),
    buyBg: Color(0x1A00A85A),
    sell: Color(0xFFE11D37),
    sellBg: Color(0x1AE11D37),
    hold: Color(0xFFD99A00),
    holdBg: Color(0x1AD99A00),
    warning: Color(0xFFD99A00),
    warningBg: Color(0x26D99A00),
    danger: Color(0xFFE11D37),
    success: Color(0xFF00A85A),
    online: Color(0xFF00A85A),
    offline: Color(0xFFE11D37),
    testnet: Color(0xFFD99A00),
    mainnet: Color(0xFF1C6CFF),
    positive: Color(0xFF00A85A),
    negative: Color(0xFFE11D37),
    navGlass: Color(0xF2FFFFFF),
    scrim: Color(0x66000A14),
    alligatorJaw: Color(0xFF2F6FDB),
    alligatorTeeth: Color(0xFFD64545),
    alligatorLips: Color(0xFF00A85A),
  );
}
