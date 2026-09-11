import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../components/trading_card.dart';
import '../../../../../core/constants/copy_constants.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../models/copy_model.dart';

class CopyActiveCard extends StatelessWidget {
  const CopyActiveCard({
    super.key,
    required this.status,
    required this.countdownSeconds,
    required this.isMutating,
    required this.onTopup,
    required this.onExit,
    required this.onComplete,
  });

  final CopyStatus status;
  final int countdownSeconds;
  final bool isMutating;
  final VoidCallback onTopup;
  final VoidCallback onExit;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final stake = status.stake;
    if (stake == null) return const SizedBox.shrink();

    final pnlColor = stake.pnlPositive
        ? p.positive
        : stake.pnlNegative
            ? p.negative
            : p.textPrimary;

    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                CopyConstants.virtualBadge,
                style: TextStyle(
                  color: p.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                CopyConstants.notBinance,
                style: TextStyle(color: p.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Equity',
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CopyConstants.rsv(stake.equityRsv),
            style: context.tradingText.monoLarge.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              MetricTile(
                label: 'Locked',
                value: CopyConstants.rsv(stake.lockedRsv),
              ),
              MetricTile(
                label: 'PnL',
                value: _signedRsv(stake.pnlRsv),
                valueColor: pnlColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              MetricTile(
                label: 'Доля пула',
                value: stake.poolShareLabel,
              ),
              MetricTile(
                label: 'До конца',
                value: CopyConstants.countdown(countdownSeconds),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CopyConstants.topupHint,
            style: TextStyle(color: p.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isMutating || status.availableEarnedRsv <= 0
                  ? null
                  : onTopup,
              style: FilledButton.styleFrom(
                backgroundColor: p.primary,
                foregroundColor: p.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                ),
              ),
              child: const Text(
                CopyConstants.topupCta,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      isMutating || !stake.canEarlyExit ? null : onExit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: p.danger,
                    side: BorderSide(color: p.danger.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.controlRadius),
                    ),
                  ),
                  child: Text(
                    '${CopyConstants.exitCta} (−${CopyConstants.plain(status.earlyExitPenaltyPct)}%)',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          if (stake.canComplete) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isMutating ? null : onComplete,
                style: FilledButton.styleFrom(
                  backgroundColor: p.success,
                  foregroundColor: p.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                  ),
                ),
                child: const Text(
                  CopyConstants.completeCta,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
          if (isMutating) ...[
            const SizedBox(height: 12),
            const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _signedRsv(num value) {
    final body = CopyConstants.rsv(value.abs());
    if (value > 0) return '+$body';
    if (value < 0) return '−$body';
    return body;
  }
}
