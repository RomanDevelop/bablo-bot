import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/data_error.dart';
import '../models/candle_model.dart';
import 'candle_cache.dart';

/// Market candles: prefer bot HTTPS API (web-safe), then public exchanges.
class MarketDataProvider {
  MarketDataProvider({
    Dio? dio,
    CandleCache? cache,
    String? botApiBaseUrl,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 10),
                headers: const {'Accept': 'application/json'},
              ),
            ),
        _cache = cache,
        _botApiBaseUrl = botApiBaseUrl;

  final Dio _dio;
  CandleCache? _cache;
  final String? _botApiBaseUrl;

  static const _freshFor = Duration(minutes: 10);

  void attachCache(CandleCache cache) => _cache = cache;

  Future<MarketCandlesResult> getKlines({
    required String symbol,
    required String interval,
    int limit = 26,
    bool testnet = true,
    bool allowStaleCache = true,
  }) async {
    final cached = _cache?.read(symbol: symbol, interval: interval);

    // Cache-first: show immediately even if a bit old, refresh in background.
    if (cached != null && cached.isFresh(_freshFor)) {
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
      // Any cached candles are better than empty chart (delay OK).
      if (allowStaleCache && cached != null && cached.candles.length >= 8) {
        return MarketCandlesResult(
          candles: _takeLast(cached.candles, limit),
          source: '${cached.source} (кэш)',
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
    // Web: free CORS-friendly APIs only (Binance/Kraken block browser).
    // Native: full race including Binance.
    if (kIsWeb) {
      return _fetchWebCached(symbol, interval, limit);
    }

    final sources = <_Source>[
      if (_botApiBaseUrl != null && _botApiBaseUrl.isNotEmpty)
        _Source('Bot API', () => _fromBotApi(symbol, interval, limit)),
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
          final candles =
              await source.fetch().timeout(const Duration(seconds: 8));
          if (candles.length < 8) {
            throw StateError('${source.name}: too few');
          }
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
      const Duration(seconds: 12),
      onTimeout: () {
        throw const DataError(
          errorCode: ErrorCode.network,
          message: 'Таймаут рыночных данных. Нажми Retry.',
        );
      },
    );
  }

  /// Sequential free APIs for browser (CORS). Cache on success.
  Future<MarketCandlesResult> _fetchWebCached(
    String symbol,
    String interval,
    int limit,
  ) async {
    final attempts = <_Source>[
      _Source('Coinbase', () => _fromCoinbase(symbol, interval, limit)),
      _Source('OKX', () => _fromOkx(symbol, interval, limit)),
      if (_botApiBaseUrl != null && _botApiBaseUrl.isNotEmpty)
        _Source('Bot API', () => _fromBotApi(symbol, interval, limit)),
    ];

    Object? lastError;
    for (final source in attempts) {
      try {
        final candles =
            await source.fetch().timeout(const Duration(seconds: 10));
        if (candles.length < 8) continue;
        final trimmed = _takeLast(candles, limit);
        await _cache?.save(
          symbol: symbol,
          interval: interval,
          candles: trimmed,
          source: source.name,
        );
        return MarketCandlesResult(candles: trimmed, source: source.name);
      } catch (e) {
        lastError = e;
      }
    }

    throw DataError(
      errorCode: ErrorCode.network,
      message:
          'Нет доступа к рыночным данным (${lastError ?? 'сеть'}). Retry позже — покажем кэш, если был.',
    );
  }

  Future<List<Candle>> _fromBotApi(
    String symbol,
    String interval,
    int limit,
  ) async {
    final base = _botApiBaseUrl!.replaceAll(RegExp(r'/$'), '');
    final response = await _dio.get<dynamic>(
      '$base/market/klines',
      queryParameters: {
        'symbol': symbol.toUpperCase(),
        'interval': interval,
        'limit': limit,
      },
    );
    final data = response.data;
    final List<dynamic> rows;
    if (data is List) {
      rows = data;
    } else if (data is Map && data['candles'] is List) {
      rows = data['candles'] as List<dynamic>;
    } else if (data is Map && data['data'] is List) {
      rows = data['data'] as List<dynamic>;
    } else {
      throw StateError('Bot API: unexpected klines payload');
    }
    if (rows.isEmpty) throw StateError('Bot API: empty klines');

    return rows.map((row) {
      if (row is List) return Candle.fromBinance(row);
      if (row is Map) {
        return Candle(
          openTime: DateTime.fromMillisecondsSinceEpoch(
            (row['t'] as num? ?? row['open_time'] as num? ?? 0).toInt(),
            isUtc: true,
          ),
          open: (row['o'] as num? ?? row['open'] as num).toDouble(),
          high: (row['h'] as num? ?? row['high'] as num).toDouble(),
          low: (row['l'] as num? ?? row['low'] as num).toDouble(),
          close: (row['c'] as num? ?? row['close'] as num).toDouble(),
          volume: (row['v'] as num? ?? row['volume'] as num? ?? 0).toDouble(),
        );
      }
      throw StateError('Bot API: bad candle row');
    }).toList(growable: false);
  }

  Future<List<Candle>> _fromCoinbase(
    String symbol,
    String interval,
    int limit,
  ) async {
    final granularity = _coinbaseGranularity(interval);
    Object? lastError;

    for (final product in _coinbaseProducts(symbol)) {
      try {
        final response = await _dio.get<dynamic>(
          'https://api.exchange.coinbase.com/products/$product/candles',
          queryParameters: {'granularity': granularity},
        );
        final rows = response.data;
        if (rows is! List || rows.isEmpty) {
          throw StateError('Coinbase $product: empty');
        }

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
      } catch (e) {
        lastError = e;
      }
    }
    throw StateError('Coinbase failed: $lastError');
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

  static List<String> _coinbaseProducts(String symbol) {
    final s = symbol.toUpperCase().replaceAll('/', '').replaceAll('-', '');
    if (s.endsWith('USDT')) {
      final base = s.substring(0, s.length - 4);
      return ['$base-USDT', '$base-USD'];
    }
    if (s.endsWith('USD')) {
      return ['${s.substring(0, s.length - 3)}-USD'];
    }
    return [s];
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
