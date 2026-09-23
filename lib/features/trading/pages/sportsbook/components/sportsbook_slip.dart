import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../components/trading_card.dart';
import '../../../../../core/constants/sportsbook_constants.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../models/sportsbook_model.dart';

class SportsbookSlip extends StatelessWidget {
  const SportsbookSlip({
    super.key,
    required this.status,
    required this.market,
    required this.stakeRsv,
    required this.selectedOutcomeId,
    required this.isMutating,
    required this.canSubmit,
    required this.oddsChanged,
    required this.onSelectOutcome,
    required this.onStakeChanged,
    required this.onStepStake,
    required this.onConfirm,
    required this.onRefreshOdds,
  });

  final SportsbookStatus status;
  final SportsbookMarket market;
  final double stakeRsv;
  final String? selectedOutcomeId;
  final bool isMutating;
  final bool canSubmit;
  final bool oddsChanged;
  final ValueChanged<SportsbookOutcome> onSelectOutcome;
  final ValueChanged<double> onStakeChanged;
  final ValueChanged<double> onStepStake;
  final VoidCallback onConfirm;
  final VoidCallback onRefreshOdds;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final selected = market.byProviderId(selectedOutcomeId);
    final min = status.minStakeRsv.toDouble();
    final max = status.stakeCeiling.toDouble();
    final canSlide = max > min && status.canAffordMin;
    final value = stakeRsv.clamp(min, canSlide ? max : min).toDouble();
    final preview = selected == null ? 0 : stakeRsv * selected.odds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TradingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SportsbookConstants.pickLabel,
                style: TextStyle(
                  color: p.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              for (final outcome in market.outcomes) ...[
                _OutcomeTile(
                  outcome: outcome,
                  selected: outcome.providerOutcomeId == selectedOutcomeId,
                  enabled: market.isOpen && !isMutating,
                  onTap: () => onSelectOutcome(outcome),
                ),
                const SizedBox(height: 8),
              ],
              if (!market.isOpen)
                Text(
                  SportsbookConstants.errorMarketClosed,
                  style: TextStyle(color: p.danger, fontSize: 13),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TradingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SportsbookConstants.stakeLabel,
                style: TextStyle(
                  color: p.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StepButton(
                    icon: Icons.remove_rounded,
                    onPressed: isMutating || !status.canAffordMin
                        ? null
                        : () => onStepStake(-SportsbookConstants.stakeStep),
                  ),
                  Expanded(
                    child: Text(
                      SportsbookConstants.rsv(value),
                      textAlign: TextAlign.center,
                      style: context.tradingText.monoLarge.copyWith(fontSize: 22),
                    ),
                  ),
                  _StepButton(
                    icon: Icons.add_rounded,
                    onPressed: isMutating || !status.canAffordMin
                        ? null
                        : () => onStepStake(SportsbookConstants.stakeStep),
                  ),
                ],
              ),
              if (canSlide)
                Slider(
                  min: min,
                  max: max,
                  value: value,
                  divisions: ((max - min) / SportsbookConstants.stakeStep)
                      .round()
                      .clamp(1, 20),
                  label: SportsbookConstants.plain(value),
                  onChanged: isMutating ? null : onStakeChanged,
                ),
              if (!status.canAffordMin)
                Text(
                  SportsbookConstants.errorInsufficient,
                  style: TextStyle(color: p.danger, fontSize: 13),
                ),
              const SizedBox(height: 8),
              Text(
                '${SportsbookConstants.previewLabel} ${SportsbookConstants.rsv(preview)}',
                style: TextStyle(
                  color: p.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (oddsChanged) ...[
                const SizedBox(height: 8),
                Text(
                  SportsbookConstants.errorOddsChanged,
                  style: TextStyle(color: p.danger, fontSize: 13),
                ),
                TextButton(
                  onPressed: isMutating ? null : onRefreshOdds,
                  child: const Text(SportsbookConstants.refreshOdds),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: canSubmit ? onConfirm : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: p.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.controlRadius),
                    ),
                  ),
                  child: isMutating
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: p.onPrimary,
                          ),
                        )
                      : const Text(
                          SportsbookConstants.confirmCta,
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OutcomeTile extends StatelessWidget {
  const _OutcomeTile({
    required this.outcome,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final SportsbookOutcome outcome;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Material(
      color: selected
          ? p.primary.withValues(alpha: 0.12)
          : p.elevatedCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? p.primary : p.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  outcome.name,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                SportsbookConstants.odds(outcome.odds),
                style: context.tradingText.monoMedium.copyWith(
                  color: p.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return IconButton.filledTonal(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: p.elevatedCard,
        foregroundColor: p.textPrimary,
      ),
      icon: Icon(icon),
    );
  }
}
