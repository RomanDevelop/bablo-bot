import 'package:flutter/material.dart';

import '../../../../components/feedback.dart';
import '../../../../components/trading_card.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_format.dart';
import 'components/equity_curve_chart.dart';
import 'di/stats_wm_builder.dart';
import 'stats_wm.dart';

class StatsPage extends CoreMwwmWidget<StatsWidgetModel> {
  StatsPage({super.key}) : super(widgetModelBuilder: createStatsWidgetModel);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends MwwmWidgetState<StatsPage, StatsWidgetModel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StatsState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const StatsState();
        return Scaffold(
          appBar: AppBar(title: const Text('Stats')),
          body: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () => wm.refresh(forceRefresh: true),
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, StatsState state) {
    if (state.isLoading && state.stats == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 180), PageLoading()],
      );
    }

    final stats = state.stats;
    if (stats == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (state.error != null)
            ErrorBanner(message: state.error!, onRetry: () => wm.refresh()),
        ],
      );
    }

    final pnlColor = MoneyFormat.isPositive(stats.equityPnl)
        ? AppColors.buy
        : MoneyFormat.isNegative(stats.equityPnl)
            ? AppColors.sell
            : AppColors.textSecondary;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        if (state.error != null) ...[
          ErrorBanner(message: state.error!, onRetry: () => wm.refresh()),
          const SizedBox(height: 12),
        ],
        TradingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Эпоха статистики'),
              const SizedBox(height: 10),
              Text(
                MoneyFormat.dateTimeFull(stats.epochStartedAt),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stats.symbol,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              if (stats.baselineNote != null && stats.baselineNote!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  stats.baselineNote!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
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
              const SectionLabel('Equity'),
              const SizedBox(height: 12),
              Text(
                MoneyFormat.usd(stats.currentEquity),
                style: context.tradingText.monoLarge.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 6),
              Text(
                '${MoneyFormat.signedUsd(stats.equityPnl)}  ·  '
                '${MoneyFormat.pct(stats.equityPnlPct)}',
                style: context.tradingText.monoMedium.copyWith(color: pnlColor),
              ),
              const SizedBox(height: 14),
              KeyValueRow(
                label: 'Baseline',
                value: MoneyFormat.usd(stats.baselineEquity),
              ),
              KeyValueRow(
                label: 'Realized',
                value: MoneyFormat.signedUsd(stats.realizedPnl),
                valueColor: MoneyFormat.isPositive(stats.realizedPnl)
                    ? AppColors.buy
                    : MoneyFormat.isNegative(stats.realizedPnl)
                        ? AppColors.sell
                        : null,
              ),
              KeyValueRow(
                label: 'Unrealized',
                value: MoneyFormat.signedUsd(stats.unrealizedPnl),
              ),
            ],
          ),
        ),
        if (state.equityCurve != null) ...[
          const SizedBox(height: 12),
          EquityCurveChart(curve: state.equityCurve!),
        ],
        const SizedBox(height: 12),
        TradingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Performance'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatBox(
                    label: 'Win rate',
                    value:
                        '${MoneyFormat.trim(stats.winRatePct, maxDecimals: 2)}%',
                  ),
                  const SizedBox(width: 10),
                  _StatBox(
                    label: 'W / L',
                    value: '${stats.wins} / ${stats.losses}',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatBox(label: 'Fills', value: '${stats.totalFills}'),
                  const SizedBox(width: 10),
                  _StatBox(
                    label: 'Buy / Sell',
                    value: '${stats.buys} / ${stats.sells}',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatBox(label: 'Closed', value: '${stats.closedTrades}'),
                  const SizedBox(width: 10),
                  _StatBox(label: 'Flats', value: '${stats.flats}'),
                ],
              ),
            ],
          ),
        ),
        if (!stats.includesPreEpochExchangeHistory) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'История Binance до эпохи не входит в статистику. '
              'График собран по закрытым сделкам бота с baseline эпохи.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: context.tradingText.monoMedium.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
