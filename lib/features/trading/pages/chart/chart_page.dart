import 'package:flutter/material.dart';

import '../../../../components/feedback.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/app_colors.dart';
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
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            leading: IconButton(
              tooltip: 'Назад',
              onPressed: () => navigateBackOrHome(context),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
              ),
            ),
            title: Text(
              'Chart',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
          lips: snap.lips,
          jaw: snap.jaw,
          scanMode: snap.scanMode,
          mode: snap.mode,
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
            height: 360,
            width: double.infinity,
            child: CustomPaint(
              painter: CandleChartPainter(
                candles: snap.candles,
                markers: snap.markers,
                alligator: snap.alligator,
                visibleFrom: state.visibleFrom,
                visibleCount: state.visibleCount,
                lastPrice: metrics.lastPrice,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _AlligatorLegend(),
        const SizedBox(height: 10),
        const _MarkersLegend(),
        const SizedBox(height: 8),
        Text(
          snap.dataSourceNote ??
              'Свечи · Alligator (Jaw/Teeth/Lips) · стрелки = кросс Lips/Jaw / fills',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _AlligatorLegend extends StatelessWidget {
  const _AlligatorLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _LineLegend(color: AppColors.alligatorJaw, text: 'Jaw 13/8'),
        _LineLegend(color: AppColors.alligatorTeeth, text: 'Teeth 8/5'),
        _LineLegend(color: AppColors.alligatorLips, text: 'Lips 5/3'),
      ],
    );
  }
}

class _LineLegend extends StatelessWidget {
  const _LineLegend({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 2.5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

class _MarkersLegend extends StatelessWidget {
  const _MarkersLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _LegendItem(color: AppColors.primary, text: 'Lips↑ (buy signal)'),
        _LegendItem(color: AppColors.hold, text: 'Lips↓ (sell signal)'),
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
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
