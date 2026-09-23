import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../components/trading_card.dart';
import '../../../../../core/constants/sportsbook_constants.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/theme_controller.dart';

class SportsbookGateCard extends StatelessWidget {
  const SportsbookGateCard({
    super.key,
    required this.onOpenPremium,
    this.disabled = false,
  });

  final VoidCallback onOpenPremium;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            disabled
                ? SportsbookConstants.disabledTitle
                : SportsbookConstants.premiumTitle,
            style: TextStyle(
              color: p.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            disabled
                ? SportsbookConstants.disabledBody
                : SportsbookConstants.premiumBody,
            style: TextStyle(color: p.textSecondary, height: 1.45),
          ),
          if (!disabled) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onOpenPremium,
                style: FilledButton.styleFrom(
                  backgroundColor: p.primary,
                  foregroundColor: p.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.controlRadius),
                  ),
                ),
                child: const Text(
                  SportsbookConstants.premiumCta,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
