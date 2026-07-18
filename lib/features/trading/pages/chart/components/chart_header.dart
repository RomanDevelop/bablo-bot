import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/money_format.dart';
import 'chart_metrics.dart';

class ChartHeader extends StatelessWidget {
  const ChartHeader({
    super.key,
    required this.symbol,
    required this.interval,
    required this.metrics,
    required this.signal,
    required this.testnet,
  });

  final String symbol;
  final String interval;
  final ChartMetrics metrics;
  final String signal;
  final bool testnet;

  static String baseAsset(String symbol) {
    final s = symbol.toUpperCase().replaceAll('/', '').replaceAll('-', '');
    if (s.endsWith('USDT')) return s.substring(0, s.length - 4);
    if (s.endsWith('USD')) return s.substring(0, s.length - 3);
    if (s.endsWith('BUSD')) return s.substring(0, s.length - 4);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final sig = signal.toUpperCase();
    final signalColor = switch (sig) {
      'BUY' => AppColors.buy,
      'SELL' => AppColors.sell,
      _ => AppColors.hold,
    };
    final deltaColor = metrics.isUp ? AppColors.buy : AppColors.sell;
    final priceStr = MoneyFormat.trim(
      metrics.lastPrice.toString(),
      maxDecimals: 2,
    );
    final absStr = metrics.changeAbs.abs().toStringAsFixed(2);
    final pctStr = metrics.changePct.abs().toStringAsFixed(2);
    final deltaText = metrics.isUp
        ? '+$absStr (+$pctStr%)'
        : '-$absStr (-$pctStr%)';

    final openLabel = metrics.openTime == null
        ? null
        : DateFormat('HH:mm dd/MM').format(metrics.openTime!.toLocal());

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          baseAsset(symbol),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$symbol · $interval',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      priceStr,
                      style: TextStyle(
                        color: deltaColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        letterSpacing: -0.8,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deltaText,
                      style: TextStyle(
                        color: deltaColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (openLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Visible from $openLabel',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SignalChip(label: sig, color: signalColor),
                      if (testnet) ...[
                        const SizedBox(width: 6),
                        const _MiniChip(
                          label: 'TESTNET',
                          color: AppColors.testnet,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StatLine(
                    label: 'High',
                    value: MoneyFormat.trim(
                      metrics.high.toString(),
                      maxDecimals: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _StatLine(
                    label: 'Low',
                    value: MoneyFormat.trim(
                      metrics.low.toString(),
                      maxDecimals: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignalChip extends StatelessWidget {
  const _SignalChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
