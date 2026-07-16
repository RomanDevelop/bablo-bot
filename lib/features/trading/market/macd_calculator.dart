import '../models/candle_model.dart';

class MacdCalculator {
  const MacdCalculator({
    this.fast = 5,
    this.slow = 13,
    this.signal = 2,
  });

  final int fast;
  final int slow;
  final int signal;

  List<MacdPoint> compute(List<Candle> candles) {
    if (candles.isEmpty) return const [];
    final closes = candles.map((c) => c.close).toList(growable: false);
    final emaFast = _ema(closes, fast);
    final emaSlow = _ema(closes, slow);

    final macdLine = List<double?>.generate(closes.length, (i) {
      final f = emaFast[i];
      final s = emaSlow[i];
      if (f == null || s == null) return null;
      return f - s;
    });

    final macdValues = <double>[];
    final macdIndexMap = <int, int>{};
    for (var i = 0; i < macdLine.length; i++) {
      final v = macdLine[i];
      if (v != null) {
        macdIndexMap[macdValues.length] = i;
        macdValues.add(v);
      }
    }

    final signalOnMacd = _ema(macdValues, signal);
    final signalLine = List<double?>.filled(closes.length, null);
    for (var j = 0; j < signalOnMacd.length; j++) {
      final candleIndex = macdIndexMap[j];
      if (candleIndex != null) {
        signalLine[candleIndex] = signalOnMacd[j];
      }
    }

    return List<MacdPoint>.generate(candles.length, (i) {
      final m = macdLine[i];
      final s = signalLine[i];
      return MacdPoint(
        time: candles[i].openTime,
        macd: m,
        signal: s,
        histogram: (m != null && s != null) ? m - s : null,
      );
    });
  }

  /// Detect MACD/signal crossovers (bot-style entries).
  List<ChartMarker> crossoverMarkers(
    List<Candle> candles,
    List<MacdPoint> macd,
  ) {
    final markers = <ChartMarker>[];
    for (var i = 1; i < macd.length; i++) {
      final prev = macd[i - 1];
      final curr = macd[i];
      if (prev.macd == null ||
          prev.signal == null ||
          curr.macd == null ||
          curr.signal == null) {
        continue;
      }
      final prevDiff = prev.macd! - prev.signal!;
      final currDiff = curr.macd! - curr.signal!;
      if (prevDiff <= 0 && currDiff > 0) {
        markers.add(
          ChartMarker(
            time: candles[i].openTime,
            price: candles[i].low,
            kind: ChartMarkerKind.buySignal,
            label: 'MACD↑',
          ),
        );
      } else if (prevDiff >= 0 && currDiff < 0) {
        markers.add(
          ChartMarker(
            time: candles[i].openTime,
            price: candles[i].high,
            kind: ChartMarkerKind.sellSignal,
            label: 'MACD↓',
          ),
        );
      }
    }
    return markers;
  }

  static List<double?> _ema(List<double> values, int period) {
    final out = List<double?>.filled(values.length, null);
    if (values.length < period || period <= 0) return out;
    final k = 2.0 / (period + 1);
    var sum = 0.0;
    for (var i = 0; i < period; i++) {
      sum += values[i];
    }
    out[period - 1] = sum / period;
    for (var i = period; i < values.length; i++) {
      out[i] = values[i] * k + out[i - 1]! * (1 - k);
    }
    return out;
  }
}
