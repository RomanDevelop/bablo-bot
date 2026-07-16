import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/money_format.dart';
import '../features/trading/models/bot_status_model.dart';
import 'status_chip.dart';
import 'trading_card.dart';

class EquityHeader extends StatelessWidget {
  const EquityHeader({
    super.key,
    required this.equity,
    required this.dailyPnlPct,
    required this.symbol,
    required this.interval,
    required this.isRunning,
    required this.isHalted,
  });

  final String equity;
  final String dailyPnlPct;
  final String symbol;
  final String interval;
  final bool isRunning;
  final bool isHalted;

  @override
  Widget build(BuildContext context) {
    final pnlPositive = MoneyFormat.isPositive(dailyPnlPct);
    final pnlNegative = MoneyFormat.isNegative(dailyPnlPct);
    final pnlColor = pnlPositive
        ? AppColors.buy
        : pnlNegative
            ? AppColors.sell
            : AppColors.textSecondary;

    return TradingCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'EQUITY',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              StatusChip(
                label: isHalted
                    ? 'HALTED'
                    : isRunning
                        ? 'RUNNING'
                        : 'STOPPED',
                color: isHalted
                    ? AppColors.danger
                    : isRunning
                        ? AppColors.buy
                        : AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            MoneyFormat.usd(equity, decimals: 2),
            style: context.tradingText.monoLarge.copyWith(
              fontSize: 34,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                MoneyFormat.pct(dailyPnlPct),
                style: context.tradingText.monoMedium.copyWith(
                  color: pnlColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'день',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$symbol · $interval',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SignalCard extends StatelessWidget {
  const SignalCard({super.key, required this.status});

  final BotStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status.signalType) {
      SignalType.buy => ('BUY', AppColors.buy, AppColors.buyBg),
      SignalType.sell => ('SELL', AppColors.sell, AppColors.sellBg),
      SignalType.hold => ('HOLD', AppColors.hold, AppColors.holdBg),
    };

    return TradingCard(
      borderColor: color.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Price ${MoneyFormat.trim(status.lastPrice, maxDecimals: 2)}',
                style: context.tradingText.monoSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            status.lastSignalReason.isEmpty ? '—' : status.lastSignalReason,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              MetricTile(
                label: 'MACD',
                value: MoneyFormat.trim(status.lastMacd, maxDecimals: 4),
              ),
              MetricTile(
                label: 'Signal',
                value: MoneyFormat.trim(status.lastSignalLine, maxDecimals: 4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MiniPositionCard extends StatelessWidget {
  const MiniPositionCard({super.key, required this.status});

  final BotStatus status;

  @override
  Widget build(BuildContext context) {
    final open = status.position.isOpen;
    final pnlColor = MoneyFormat.isPositive(status.position.unrealizedPnl)
        ? AppColors.buy
        : MoneyFormat.isNegative(status.position.unrealizedPnl)
            ? AppColors.sell
            : AppColors.textSecondary;

    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Позиция бота'),
          const SizedBox(height: 12),
          if (!open)
            const Text(
              'Нет открытой позиции',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            )
          else ...[
            Text(
              '${status.position.side ?? 'LONG'}  '
              '${MoneyFormat.trim(status.position.quantity)} @ '
              '${MoneyFormat.trim(status.position.entryPrice, maxDecimals: 2)}',
              style: context.tradingText.monoMedium.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'uPnL ${MoneyFormat.signedUsd(status.position.unrealizedPnl)}',
              style: context.tradingText.monoSmall.copyWith(color: pnlColor),
            ),
          ],
        ],
      ),
    );
  }
}
