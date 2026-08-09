import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

class AppTheme {
  AppTheme._();

  static const double cardRadius = 20;
  static const double controlRadius = 14;

  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static ThemeData get light => _build(AppPalette.light, Brightness.light);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseText = GoogleFonts.dmSansTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );
    final mono = GoogleFonts.jetBrainsMonoTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: p.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: p.primary,
        onPrimary: p.onPrimary,
        secondary: p.primaryHover,
        onSecondary: p.onPrimary,
        error: p.danger,
        onError: p.onPrimary,
        surface: p.surface,
        onSurface: p.textPrimary,
        outline: p.border,
        surfaceContainerHighest: p.elevatedCard,
        surfaceContainerHigh: p.card,
        surfaceContainer: p.surfaceElevated,
        surfaceContainerLow: p.surface,
        surfaceContainerLowest: p.background,
      ),
      textTheme: baseText.copyWith(
        displayLarge: baseText.displayLarge?.copyWith(
          color: p.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          color: p.textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.6,
        ),
        headlineSmall: baseText.headlineSmall?.copyWith(
          color: p.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          color: p.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          color: p.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(color: p.textPrimary),
        bodyMedium: baseText.bodyMedium?.copyWith(color: p.textSecondary),
        bodySmall: baseText.bodySmall?.copyWith(color: p.textMuted),
        labelLarge: baseText.labelLarge?.copyWith(
          color: p.textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: baseText.titleLarge?.copyWith(
          color: p.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: p.borderSubtle),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: p.divider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.elevatedCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: p.primary, width: 1.4),
        ),
        labelStyle: TextStyle(color: p.textSecondary),
        hintStyle: TextStyle(color: p.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textPrimary,
          side: BorderSide(color: p.border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.elevatedCard,
          foregroundColor: p.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.elevatedCard,
        contentTextStyle: TextStyle(color: p.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(controlRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: p.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? p.primary : p.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? p.primary : p.textSecondary,
            size: 22,
          );
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.primary;
          return p.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.primaryDim;
          return p.border;
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      extensions: [
        TradingTextStyles(
          monoLarge: mono.headlineMedium!.copyWith(
            color: p.textPrimary,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          monoMedium: mono.titleMedium!.copyWith(
            color: p.textPrimary,
            fontWeight: FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          monoSmall: mono.bodySmall!.copyWith(
            color: p.textSecondary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class TradingTextStyles extends ThemeExtension<TradingTextStyles> {
  const TradingTextStyles({
    required this.monoLarge,
    required this.monoMedium,
    required this.monoSmall,
  });

  final TextStyle monoLarge;
  final TextStyle monoMedium;
  final TextStyle monoSmall;

  @override
  TradingTextStyles copyWith({
    TextStyle? monoLarge,
    TextStyle? monoMedium,
    TextStyle? monoSmall,
  }) {
    return TradingTextStyles(
      monoLarge: monoLarge ?? this.monoLarge,
      monoMedium: monoMedium ?? this.monoMedium,
      monoSmall: monoSmall ?? this.monoSmall,
    );
  }

  @override
  TradingTextStyles lerp(ThemeExtension<TradingTextStyles>? other, double t) {
    if (other is! TradingTextStyles) return this;
    return TradingTextStyles(
      monoLarge: TextStyle.lerp(monoLarge, other.monoLarge, t)!,
      monoMedium: TextStyle.lerp(monoMedium, other.monoMedium, t)!,
      monoSmall: TextStyle.lerp(monoSmall, other.monoSmall, t)!,
    );
  }
}

extension TradingThemeX on BuildContext {
  TradingTextStyles get tradingText =>
      Theme.of(this).extension<TradingTextStyles>()!;
}
