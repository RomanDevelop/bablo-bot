import 'package:flutter/material.dart';

import '../../../../components/feedback.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/candle_model.dart';
import 'chart_wm.dart';
import 'components/chart_header.dart';
import 'components/chart_metrics.dart';
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

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () => wm.refresh(),
              child: _buildBody(state),
            ),
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

    final overridePrice = double.tryParse(snap.lastPrice ?? '');
    final metrics = ChartMetrics.fromVisible(
      candles: snap.candles,
      visibleFrom: state.visibleFrom,
      visibleCount: state.visibleCount,
      lastPriceOverride: overridePrice,
    );

    final lastMacd = _lastMacd(snap.macd, state.visibleFrom, state.visibleCount);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
      children: [
        if (state.error != null) ...[
          ErrorBanner(message: state.error!, onRetry: () => wm.refresh()),
          const SizedBox(height: 10),
        ],
        ChartHeader(
          symbol: snap.symbol,
          interval: snap.interval,
          metrics: metrics,
          signal: snap.lastSignal ?? 'HOLD',
          testnet: snap.testnet,
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onHorizontalDragUpdate: (d) {
            _panAcc += d.delta.dx;
            if (_panAcc.abs() > 12) {
              wm.panBy(_panAcc > 0 ? -1 : 1);
              _panAcc = 0;
            }
          },
          child: SizedBox(
            height: 320,
            width: double.infinity,
            child: CustomPaint(
              painter: CandleChartPainter(
                candles: snap.candles,
                markers: snap.markers,
                visibleFrom: state.visibleFrom,
                visibleCount: state.visibleCount,
                lastPrice: metrics.lastPrice,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _MacdPanel(
          fast: snap.config.macdFast,
          slow: snap.config.macdSlow,
          signalPeriod: snap.config.macdSignal,
          last: lastMacd,
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: MacdChartPainter(
                macd: snap.macd,
                visibleFrom: state.visibleFrom,
                visibleCount: state.visibleCount,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const _MarkersLegend(),
        const SizedBox(height: 8),
        Text(
          snap.dataSourceNote ??
              'Свечи · High/Low по видимым барам · стрелки = MACD / fills',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  MacdPoint? _lastMacd(List<MacdPoint> macd, int from, int count) {
    if (macd.isEmpty) return null;
    final end = (from + count).clamp(0, macd.length);
    final start = from.clamp(0, end);
    if (start >= end) return null;
    for (var i = end - 1; i >= start; i--) {
      final p = macd[i];
      if (p.macd != null || p.signal != null || p.histogram != null) {
        return p;
      }
    }
    return null;
  }
}

class _MacdPanel extends StatelessWidget {
  const _MacdPanel({
    required this.fast,
    required this.slow,
    required this.signalPeriod,
    required this.last,
    required this.child,
  });

  final int fast;
  final int slow;
  final int signalPeriod;
  final MacdPoint? last;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'MACD($fast, $slow, $signalPeriod)',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            if (last != null) ...[
              _MacdValue(
                label: 'MACD',
                value: last!.macd,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              _MacdValue(
                label: 'Signal',
                value: last!.signal,
                color: AppColors.hold,
              ),
              const SizedBox(width: 10),
              _MacdValue(
                label: 'Hist',
                value: last!.histogram,
                color: (last!.histogram ?? 0) >= 0
                    ? AppColors.buy
                    : AppColors.sell,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _MacdValue extends StatelessWidget {
  const _MacdValue({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? '—' : value!.toStringAsFixed(4);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
          TextSpan(
            text: text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
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
