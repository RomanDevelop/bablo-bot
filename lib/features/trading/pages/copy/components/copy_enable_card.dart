import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../components/trading_card.dart';
import '../../../../../core/constants/copy_constants.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../models/copy_model.dart';

class CopyEnableCard extends StatefulWidget {
  const CopyEnableCard({
    super.key,
    required this.status,
    required this.amountRsv,
    required this.disclaimerAccepted,
    required this.isMutating,
    required this.onAmountChanged,
    required this.onDisclaimerChanged,
    required this.onEnable,
  });

  final CopyStatus status;
  final double amountRsv;
  final bool disclaimerAccepted;
  final bool isMutating;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<bool> onDisclaimerChanged;
  final VoidCallback onEnable;

  @override
  State<CopyEnableCard> createState() => _CopyEnableCardState();
}

class _CopyEnableCardState extends State<CopyEnableCard> {
  late final TextEditingController _amountCtrl;
  final FocusNode _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: CopyConstants.plain(widget.amountRsv),
    );
  }

  @override
  void didUpdateWidget(covariant CopyEnableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_amountFocus.hasFocus && oldWidget.amountRsv != widget.amountRsv) {
      final next = CopyConstants.plain(widget.amountRsv);
      if (_amountCtrl.text != next) {
        _amountCtrl.text = next;
      }
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final status = widget.status;
    final min = status.minStakeRsv.toDouble();
    final max = status.availableEarnedRsv.toDouble();
    final canStake = max >= min;
    final canSlide = max > min;
    final value = widget.amountRsv.clamp(min, canStake ? max : min).toDouble();
    final range = max - min;
    final divisions = range < 1 ? 1 : range.round().clamp(1, 200);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _RuleChip(CopyConstants.minRule(status.minStakeRsv)),
            _RuleChip(CopyConstants.lockRule(status.lockDays)),
            _RuleChip(CopyConstants.penaltyRule(status.earlyExitPenaltyPct)),
            const _RuleChip(CopyConstants.notBinance),
          ],
        ),
        const SizedBox(height: 16),
        TradingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                CopyConstants.availableLabel,
                style: TextStyle(
                  color: p.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                CopyConstants.rsv(status.availableEarnedRsv),
                style: context.tradingText.monoLarge.copyWith(fontSize: 22),
              ),
              if (!canStake) ...[
                const SizedBox(height: 8),
                Text(
                  CopyConstants.insufficientForMin,
                  style: TextStyle(color: p.danger, fontSize: 13),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                CopyConstants.amountLabel,
                style: TextStyle(
                  color: p.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                focusNode: _amountFocus,
                enabled: canStake && !widget.isMutating,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                onChanged: (raw) {
                  final parsed = double.tryParse(raw.replaceAll(',', '.'));
                  if (parsed != null) widget.onAmountChanged(parsed);
                },
                decoration: InputDecoration(
                  suffixText: 'RSV',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                  ),
                ),
              ),
              if (canSlide) ...[
                const SizedBox(height: 8),
                Slider(
                  min: min,
                  max: max,
                  value: value,
                  divisions: divisions,
                  label: CopyConstants.plain(value),
                  onChanged: widget.isMutating ? null : widget.onAmountChanged,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        TradingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.disclaimerText,
                style: TextStyle(
                  color: p.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: widget.isMutating
                    ? null
                    : () => widget.onDisclaimerChanged(
                          !widget.disclaimerAccepted,
                        ),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    Icon(
                      widget.disclaimerAccepted
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: widget.disclaimerAccepted ? p.primary : p.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        CopyConstants.acceptDisclaimer,
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (!canStake ||
                          !widget.disclaimerAccepted ||
                          widget.isMutating)
                      ? null
                      : widget.onEnable,
                  style: FilledButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: p.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.controlRadius),
                    ),
                  ),
                  child: widget.isMutating
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: p.onPrimary,
                          ),
                        )
                      : const Text(
                          CopyConstants.connectCta,
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

class _RuleChip extends StatelessWidget {
  const _RuleChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: p.elevatedCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.borderSubtle),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: p.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
