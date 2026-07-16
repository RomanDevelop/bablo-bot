import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/candle_model.dart';

class CandleCache {
  CandleCache(this._prefs);

  final SharedPreferences _prefs;

  static String _key(String symbol, String interval) =>
      'candles_${symbol.toUpperCase()}_$interval';

  Future<void> save({
    required String symbol,
    required String interval,
    required List<Candle> candles,
    required String source,
  }) async {
    if (candles.isEmpty) return;
    final payload = {
      'saved_at': DateTime.now().toUtc().toIso8601String(),
      'source': source,
      'candles': candles
          .map(
            (c) => {
              't': c.openTime.toUtc().millisecondsSinceEpoch,
              'o': c.open,
              'h': c.high,
              'l': c.low,
              'c': c.close,
              'v': c.volume,
            },
          )
          .toList(),
    };
    await _prefs.setString(_key(symbol, interval), jsonEncode(payload));
  }

  CachedCandles? read({
    required String symbol,
    required String interval,
  }) {
    final raw = _prefs.getString(_key(symbol, interval));
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final list = (map['candles'] as List<dynamic>)
          .map((e) {
            final m = e as Map<String, dynamic>;
            return Candle(
              openTime: DateTime.fromMillisecondsSinceEpoch(
                (m['t'] as num).toInt(),
                isUtc: true,
              ),
              open: (m['o'] as num).toDouble(),
              high: (m['h'] as num).toDouble(),
              low: (m['l'] as num).toDouble(),
              close: (m['c'] as num).toDouble(),
              volume: (m['v'] as num).toDouble(),
            );
          })
          .toList(growable: false);
      if (list.isEmpty) return null;
      return CachedCandles(
        candles: list,
        source: map['source'] as String? ?? 'cache',
        savedAt: DateTime.tryParse(map['saved_at'] as String? ?? '')?.toLocal(),
      );
    } catch (_) {
      return null;
    }
  }
}

class CachedCandles {
  const CachedCandles({
    required this.candles,
    required this.source,
    this.savedAt,
  });

  final List<Candle> candles;
  final String source;
  final DateTime? savedAt;

  bool isFresh(Duration maxAge) {
    if (savedAt == null) return false;
    return DateTime.now().difference(savedAt!) <= maxAge;
  }
}

class MarketCandlesResult {
  const MarketCandlesResult({
    required this.candles,
    required this.source,
    this.fromCache = false,
    this.savedAt,
  });

  final List<Candle> candles;
  final String source;
  final bool fromCache;
  final DateTime? savedAt;
}
