import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';

class TradingCard extends StatelessWidget {
  const TradingCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final body = Padding(
      padding: padding,
      child: SizedBox(width: double.infinity, child: child),
    );

    return Material(
      color: p.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor ?? p.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? body
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: body,
            ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Row(
      children: [
        Text(
          text.toUpperCase(),
          style: TextStyle(
            color: p.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.subtitle,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: context.tradingText.monoMedium.copyWith(
              color: valueColor ?? p.textPrimary,
              fontSize: 16,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(color: p.textMuted, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.mono = true,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: p.textSecondary, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: (mono ? context.tradingText.monoSmall : null)?.copyWith(
                  color: valueColor ?? p.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ) ??
                TextStyle(
                  color: valueColor ?? p.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
