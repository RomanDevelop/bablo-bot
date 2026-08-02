import '../models/candle_model.dart';

/// Bill Williams Alligator: Jaw / Teeth / Lips (SMMA + forward shift).
class AlligatorCalculator {
  const AlligatorCalculator({
    this.jawPeriod = 13,
    this.jawShift = 8,
    this.teethPeriod = 8,
    this.teethShift = 5,
    this.lipsPeriod = 5,
    this.lipsShift = 3,
  });

  final int jawPeriod;
  final int jawShift;
  final int teethPeriod;
  final int teethShift;
  final int lipsPeriod;
  final int lipsShift;

  List<AlligatorPoint> compute(List<Candle> candles) {
    if (candles.isEmpty) return const [];

    final closes = candles.map((c) => c.close).toList(growable: false);
    final jawSmma = _smma(closes, jawPeriod);
    final teethSmma = _smma(closes, teethPeriod);
    final lipsSmma = _smma(closes, lipsPeriod);

    final jaw = _shiftForward(jawSmma, jawShift);
    final teeth = _shiftForward(teethSmma, teethShift);
    final lips = _shiftForward(lipsSmma, lipsShift);

    return List<AlligatorPoint>.generate(
      candles.length,
      (i) => AlligatorPoint(
        time: candles[i].openTime,
        jaw: jaw[i],
        teeth: teeth[i],
        lips: lips[i],
      ),
      growable: false,
    );
  }

  /// Lips/Jaw crossover markers (Alligator wake / sleep style).
  List<ChartMarker> crossoverMarkers(
    List<Candle> candles,
    List<AlligatorPoint> points,
  ) {
    if (candles.isEmpty || points.length < 2) return const [];
    final markers = <ChartMarker>[];
    for (var i = 1; i < points.length && i < candles.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      if (prev.lips == null ||
          prev.jaw == null ||
          curr.lips == null ||
          curr.jaw == null) {
        continue;
      }
      final prevDiff = prev.lips! - prev.jaw!;
      final currDiff = curr.lips! - curr.jaw!;
      if (prevDiff <= 0 && currDiff > 0) {
        markers.add(
          ChartMarker(
            time: candles[i].openTime,
            price: candles[i].low,
            kind: ChartMarkerKind.buySignal,
            label: 'Lips↑',
          ),
        );
      } else if (prevDiff >= 0 && currDiff < 0) {
        markers.add(
          ChartMarker(
            time: candles[i].openTime,
            price: candles[i].high,
            kind: ChartMarkerKind.sellSignal,
            label: 'Lips↓',
          ),
        );
      }
    }
    return markers;
  }

  /// Wilder's Smoothed MA (RMA / SMMA).
  static List<double?> _smma(List<double> values, int period) {
    final out = List<double?>.filled(values.length, null);
    if (values.length < period || period <= 0) return out;

    var sum = 0.0;
    for (var i = 0; i < period; i++) {
      sum += values[i];
    }
    var prev = sum / period;
    out[period - 1] = prev;

    for (var i = period; i < values.length; i++) {
      prev = (prev * (period - 1) + values[i]) / period;
      out[i] = prev;
    }
    return out;
  }

  /// Plot value from bar i at bar i + shift (forward displacement).
  static List<double?> _shiftForward(List<double?> source, int shift) {
    final out = List<double?>.filled(source.length, null);
    if (shift <= 0) return List<double?>.from(source);
    for (var i = 0; i < source.length; i++) {
      final v = source[i];
      if (v == null) continue;
      final dest = i + shift;
      if (dest < out.length) out[dest] = v;
    }
    return out;
  }
}
