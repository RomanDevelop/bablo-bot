import 'package:flutter/material.dart';

import '../../../../components/feedback.dart';
import '../../../../components/status_chip.dart';
import '../../../../components/trading_card.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_format.dart';
import '../../repositories/chart_repository.dart';
import 'chart_wm.dart';
import 'components/chart_painters.dart';
import 'di/chart_wm_builder.dart';

class ChartPage extends CoreMwwmWidget<ChartWidgetModel> {
  ChartPage({super.key}) : super(widgetModelBuilder: createChartWidgetModel);

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends MwwmWidgetState<ChartPage, ChartWidgetModel> {
  double _panAcc = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChartState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const ChartState();
        final snap = state.snapshot;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              snap == null
                  ? 'Chart'
                  : '${snap.symbol} · ${snap.interval}',
            ),
            actions: [
              if (snap != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: StatusChip(
                    label: snap.testnet ? 'TESTNET' : 'MAINNET',
                    color: snap.testnet ? AppColors.testnet : AppColors.mainnet,
                  ),
                ),
              IconButton(
                onPressed: () => wm.refresh(),
                icon: const Icon(Icons.refresh, size: 20),
              ),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () => wm.refresh(),
            child: _buildBody(state),
          ),
        );
      },
    );
  }

  Widget _buildBody(ChartState state) {
    if (state.isLoading && state.snapshot == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 180), PageLoading()],
      );
    }

    final snap = state.snapshot;
    if (snap == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (state.error != null)
            ErrorBanner(message: state.error!, onRetry: () => wm.refresh()),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      children: [
        if (state.error != null) ...[
          ErrorBanner(message: state.error!, onRetry: () => wm.refresh()),
          const SizedBox(height: 10),
        ],
        _SignalBar(snapshot: snap),
        const SizedBox(height: 10),
        TradingCard(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SectionLabel('Price'),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onHorizontalDragUpdate: (d) {
                  _panAcc += d.delta.dx;
                  if (_panAcc.abs() > 12) {
                    wm.panBy(_panAcc > 0 ? -1 : 1);
                    _panAcc = 0;
                  }
                },
                child: SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: CandleChartPainter(
                      candles: snap.candles,
                      markers: snap.markers,
                      visibleFrom: state.visibleFrom,
                      visibleCount: state.visibleCount,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TradingCard(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SectionLabel(
                  'MACD ${snap.config.macdFast}/${snap.config.macdSlow}/${snap.config.macdSignal}',
                  trailing: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LegendDot(color: AppColors.primary, label: 'MACD'),
                      SizedBox(width: 10),
                      _LegendDot(color: AppColors.hold, label: 'Signal'),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(
                  painter: MacdChartPainter(
                    macd: snap.macd,
                    visibleFrom: state.visibleFrom,
                    visibleCount: state.visibleCount,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _MarkersLegend(),
        const SizedBox(height: 8),
        Text(
          snap.dataSourceNote ??
              'Свечи: Binance · стрелки = кроссовер MACD · кольцо = entry/fill',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.35),
        ),
      ],
    );
  }
}

class _SignalBar extends StatelessWidget {
  const _SignalBar({required this.snapshot});
  final ChartSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final signal = (snapshot.lastSignal ?? 'HOLD').toUpperCase();
    final color = switch (signal) {
      'BUY' => AppColors.buy,
      'SELL' => AppColors.sell,
      _ => AppColors.hold,
    };
    return TradingCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              signal,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Price ${MoneyFormat.trim(snapshot.lastPrice, maxDecimals: 2)}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Text(
            '${snapshot.candles.length} bars',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
      ],
    );
  }
}

class _MarkersLegend extends StatelessWidget {
  const _MarkersLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _LegendItem(color: AppColors.primary, text: 'BUY signal (MACD↑)'),
        _LegendItem(color: AppColors.hold, text: 'SELL signal (MACD↓)'),
        _LegendItem(color: AppColors.buy, text: 'BUY fill'),
        _LegendItem(color: AppColors.sell, text: 'SELL fill'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.change_history, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
