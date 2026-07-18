import '../../../models/candle_model.dart';

/// Derived chart header metrics from visible candles (no I/O).
class ChartMetrics {
  const ChartMetrics({
    required this.lastPrice,
    required this.changeAbs,
    required this.changePct,
    required this.high,
    required this.low,
    required this.isUp,
    this.openTime,
  });

  final double lastPrice;
  final double changeAbs;
  final double changePct;
  final double high;
  final double low;
  final bool isUp;
  final DateTime? openTime;

  /// [lastPriceOverride] — bot status price when available.
  factory ChartMetrics.fromVisible({
    required List<Candle> candles,
    required int visibleFrom,
    required int visibleCount,
    double? lastPriceOverride,
  }) {
    if (candles.isEmpty || visibleCount <= 0) {
      return const ChartMetrics(
        lastPrice: 0,
        changeAbs: 0,
        changePct: 0,
        high: 0,
        low: 0,
        isUp: true,
      );
    }

    final end = (visibleFrom + visibleCount).clamp(0, candles.length);
    final start = visibleFrom.clamp(0, end);
    final visible = candles.sublist(start, end);
    if (visible.isEmpty) {
      return const ChartMetrics(
        lastPrice: 0,
        changeAbs: 0,
        changePct: 0,
        high: 0,
        low: 0,
        isUp: true,
      );
    }

    var high = visible.first.high;
    var low = visible.first.low;
    for (final c in visible) {
      if (c.high > high) high = c.high;
      if (c.low < low) low = c.low;
    }

    final firstOpen = visible.first.open;
    final lastClose = visible.last.close;
    final price = (lastPriceOverride != null && lastPriceOverride > 0)
        ? lastPriceOverride
        : lastClose;
    final changeAbs = price - firstOpen;
    final changePct = firstOpen == 0 ? 0.0 : (changeAbs / firstOpen) * 100;

    return ChartMetrics(
      lastPrice: price,
      changeAbs: changeAbs,
      changePct: changePct,
      high: high,
      low: low,
      isUp: changeAbs >= 0,
      openTime: visible.first.openTime,
    );
  }
}
