import 'dart:async';

import 'package:dio/dio.dart';

import '../../../core/errors/data_error.dart';
import '../models/candle_model.dart';
import 'candle_cache.dart';

/// Free public market data: parallel race + local cache.
class MarketDataProvider {
  MarketDataProvider({
    Dio? dio,
    CandleCache? cache,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 6),
                receiveTimeout: const Duration(seconds: 8),
                headers: const {'Accept': 'application/json'},
              ),
            ),
        _cache = cache;

  final Dio _dio;
  CandleCache? _cache;

  static const _freshFor = Duration(minutes: 3);

  void attachCache(CandleCache cache) => _cache = cache;

  Future<MarketCandlesResult> getKlines({
    required String symbol,
    required String interval,
    int limit = 26,
    bool testnet = true,
    bool allowStaleCache = true,
  }) async {
    final cached = _cache?.read(symbol: symbol, interval: interval);
    if (cached != null && cached.isFresh(_freshFor)) {
      // Refresh in background, return cache immediately.
      unawaited(_fetchAndCache(symbol, interval, limit, testnet));
      return MarketCandlesResult(
        candles: _takeLast(cached.candles, limit),
        source: cached.source,
        fromCache: true,
        savedAt: cached.savedAt,
      );
    }

    try {
      return await _raceSources(symbol, interval, limit, testnet);
    } catch (_) {
      if (allowStaleCache && cached != null) {
        return MarketCandlesResult(
          candles: _takeLast(cached.candles, limit),
          source: cached.source,
          fromCache: true,
          savedAt: cached.savedAt,
        );
      }
      rethrow;
    }
  }

  Future<void> _fetchAndCache(
    String symbol,
    String interval,
    int limit,
    bool testnet,
  ) async {
    try {
      await _raceSources(symbol, interval, limit, testnet);
    } catch (_) {}
  }

  Future<MarketCandlesResult> _raceSources(
    String symbol,
    String interval,
    int limit,
    bool testnet,
  ) async {
    final sources = <_Source>[
      // Coinbase allows browser CORS — preferred for Flutter Web.
      _Source('Coinbase', () => _fromCoinbase(symbol, interval, limit)),
      _Source('OKX', () => _fromOkx(symbol, interval, limit)),
      _Source('Kraken', () => _fromKraken(symbol, interval, limit)),
      _Source(
        'Binance',
        () => _fromBinance(
          'https://data-api.binance.vision',
          symbol,
          interval,
          limit,
        ),
      ),
      _Source(
        'Binance API',
        () => _fromBinance('https://api.binance.com', symbol, interval, limit),
      ),
    ];

    final completer = Completer<MarketCandlesResult>();
    var remaining = sources.length;

    for (final source in sources) {
      scheduleMicrotask(() async {
        try {
          final candles = await source
              .fetch()
              .timeout(const Duration(seconds: 7));
          if (candles.length < 8) throw StateError('${source.name}: too few');
          if (!completer.isCompleted) {
            final trimmed = _takeLast(candles, limit);
            completer.complete(
              MarketCandlesResult(candles: trimmed, source: source.name),
            );
            await _cache?.save(
              symbol: symbol,
              interval: interval,
              candles: trimmed,
              source: source.name,
            );
          }
        } catch (_) {
          remaining--;
          if (remaining == 0 && !completer.isCompleted) {
            completer.completeError(
              const DataError(
                errorCode: ErrorCode.network,
                message:
                    'Нет доступа к рыночным данным. Проверь интернет и Retry.',
              ),
            );
          }
        }
      });
    }

    return completer.future.timeout(
      const Duration(seconds: 9),
      onTimeout: () {
        throw const DataError(
          errorCode: ErrorCode.network,
          message: 'Таймаут рыночных данных. Нажми Retry.',
        );
      },
    );
  }

  Future<List<Candle>> _fromCoinbase(
    String symbol,
    String interval,
    int limit,
  ) async {
    final granularity = _coinbaseGranularity(interval);
    final product = _coinbaseProduct(symbol);
    // Without start/end Coinbase returns the most recent candles (CORS-friendly).
    final response = await _dio.get<List<dynamic>>(
      'https://api.exchange.coinbase.com/products/$product/candles',
      queryParameters: {
        'granularity': granularity,
      },
    );
    final rows = response.data ?? const [];
    if (rows.isEmpty) throw StateError('Coinbase: empty');

    // Coinbase returns newest first: [time, low, high, open, close, volume]
    final candles = rows.map((row) {
      final r = row as List<dynamic>;
      return Candle(
        openTime: DateTime.fromMillisecondsSinceEpoch(
          (r[0] as num).toInt() * 1000,
          isUtc: true,
        ),
        low: (r[1] as num).toDouble(),
        high: (r[2] as num).toDouble(),
        open: (r[3] as num).toDouble(),
        close: (r[4] as num).toDouble(),
        volume: (r[5] as num).toDouble(),
      );
    }).toList()
      ..sort((a, b) => a.openTime.compareTo(b.openTime));

    return _takeLast(candles, limit);
  }

  Future<List<Candle>> _fromKraken(
    String symbol,
    String interval,
    int limit,
  ) async {
    final pair = _krakenPair(symbol);
    final minutes = _intervalMinutes(interval);
    final response = await _dio.get<Map<String, dynamic>>(
      'https://api.kraken.com/0/public/OHLC',
      queryParameters: {'pair': pair, 'interval': minutes},
    );
    final body = response.data ?? const {};
    final errors = body['error'];
    if (errors is List && errors.isNotEmpty) {
      throw StateError('Kraken: ${errors.join(', ')}');
    }
    final result = body['result'];
    if (result is! Map) throw StateError('Kraken: empty');
    List<dynamic>? rows;
    for (final entry in result.entries) {
      if (entry.key == 'last') continue;
      if (entry.value is List) {
        rows = entry.value as List<dynamic>;
        break;
      }
    }
    if (rows == null || rows.isEmpty) throw StateError('Kraken: no OHLC');

    final candles = rows.map((row) {
      final r = row as List<dynamic>;
      return Candle(
        openTime: DateTime.fromMillisecondsSinceEpoch(
          (r[0] as num).toInt() * 1000,
          isUtc: true,
        ),
        open: double.parse(r[1].toString()),
        high: double.parse(r[2].toString()),
        low: double.parse(r[3].toString()),
        close: double.parse(r[4].toString()),
        volume: double.parse(r[6].toString()),
      );
    }).toList();
    return _takeLast(candles, limit);
  }

  Future<List<Candle>> _fromOkx(
    String symbol,
    String interval,
    int limit,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://www.okx.com/api/v5/market/candles',
      queryParameters: {
        'instId': _okxInstId(symbol),
        'bar': _okxBar(interval),
        'limit': '$limit',
      },
    );
    final body = response.data ?? const {};
    if (body['code']?.toString() != '0') {
      throw StateError('OKX: ${body['msg']}');
    }
    final rows = body['data'];
    if (rows is! List || rows.isEmpty) throw StateError('OKX: empty');

    return rows.reversed.map((row) {
      final r = row as List<dynamic>;
      return Candle(
        openTime: DateTime.fromMillisecondsSinceEpoch(
          int.parse(r[0].toString()),
          isUtc: true,
        ),
        open: double.parse(r[1].toString()),
        high: double.parse(r[2].toString()),
        low: double.parse(r[3].toString()),
        close: double.parse(r[4].toString()),
        volume: double.parse(r[5].toString()),
      );
    }).toList(growable: false);
  }

  Future<List<Candle>> _fromBinance(
    String base,
    String symbol,
    String interval,
    int limit,
  ) async {
    final response = await _dio.get<List<dynamic>>(
      '$base/api/v3/klines',
      queryParameters: {
        'symbol': symbol.toUpperCase(),
        'interval': interval,
        'limit': limit,
      },
    );
    final rows = response.data ?? const [];
    if (rows.isEmpty) throw StateError('Binance: empty');
    return rows
        .map((e) => Candle.fromBinance(e as List<dynamic>))
        .toList(growable: false);
  }

  static List<Candle> _takeLast(List<Candle> candles, int limit) {
    if (candles.length <= limit) return candles;
    return candles.sublist(candles.length - limit);
  }

  static String _coinbaseProduct(String symbol) {
    final s = symbol.toUpperCase().replaceAll('/', '').replaceAll('-', '');
    if (s.endsWith('USDT')) return '${s.substring(0, s.length - 4)}-USDT';
    if (s.endsWith('USD')) return '${s.substring(0, s.length - 3)}-USD';
    return s;
  }

  static int _coinbaseGranularity(String interval) {
    switch (interval) {
      case '1m':
        return 60;
      case '5m':
        return 300;
      case '15m':
      case '30m':
        return 900;
      case '1h':
      case '2h':
      case '3h':
        return 3600;
      case '4h':
      case '6h':
      case '8h':
      case '12h':
        return 21600;
      case '1d':
        return 86400;
      default:
        return 900;
    }
  }

  static String _krakenPair(String symbol) {
    final s = symbol.toUpperCase().replaceAll('/', '').replaceAll('-', '');
    if (s.endsWith('USDT')) return '${s.substring(0, s.length - 4)}USDT';
    return s;
  }

  static String _okxInstId(String symbol) {
    final s = symbol.toUpperCase().replaceAll('/', '').replaceAll('-', '');
    if (s.endsWith('USDT')) return '${s.substring(0, s.length - 4)}-USDT';
    if (s.endsWith('USD')) return '${s.substring(0, s.length - 3)}-USD';
    return s;
  }

  static int _intervalMinutes(String interval) {
    switch (interval) {
      case '1m':
        return 1;
      case '5m':
        return 5;
      case '15m':
        return 15;
      case '30m':
        return 30;
      case '1h':
        return 60;
      case '4h':
        return 240;
      case '1d':
        return 1440;
      default:
        return 15;
    }
  }

  static String _okxBar(String interval) {
    switch (interval) {
      case '1m':
      case '3m':
      case '5m':
      case '15m':
      case '30m':
        return interval;
      case '1h':
        return '1H';
      case '2h':
        return '2H';
      case '4h':
        return '4H';
      case '1d':
        return '1D';
      default:
        return '15m';
    }
  }
}

class _Source {
  const _Source(this.name, this.fetch);
  final String name;
  final Future<List<Candle>> Function() fetch;
}
