import 'dart:async';

import '../../../core/network/network_client.dart';
import '../../../core/utils/json_parsers.dart';
import '../cache/api_cache.dart';
import '../dto/bot_config_dto.dart';
import '../dto/bot_status_dto.dart';
import '../dto/portfolio_dto.dart';
import '../dto/stats_dto.dart';
import '../dto/trade_dto.dart';

abstract class TradingDataProviderInterface {
  Future<HealthDto> getHealth();
  Future<BotStatusDto> getStatus();
  Future<PortfolioDto> getPortfolio();
  Future<StatsDto> getStats();
  Future<List<TradeDto>> getTrades({int limit = 50, String? symbol});
  Future<BotConfigDto> getConfig();
  Future<BotConfigDto> patchConfig(Map<String, dynamic> body);
  Future<Map<String, dynamic>> start({
    required String symbol,
    required String interval,
  });
  Future<Map<String, dynamic>> stop();
  Future<Map<String, dynamic>> emergencyStop();
  Future<Map<String, dynamic>> reconcile();
  Future<Map<String, dynamic>> adopt();
  Future<List<String>> getPairs({String quote = 'USDT'});
}

class TradingDataProvider implements TradingDataProviderInterface {
  TradingDataProvider({
    required NetworkClient networkClient,
    ApiCache? cache,
  })  : _client = networkClient,
        _cache = cache;

  final NetworkClient _client;
  final ApiCache? _cache;

  static const _ttlFast = Duration(seconds: 45);
  static const _ttlSlow = Duration(minutes: 2);

  @override
  Future<HealthDto> getHealth() => _mapCached(
        ApiCacheKeys.health,
        _ttlFast,
        () => _client.get<Map<String, dynamic>>('/bot/health'),
        HealthDto.fromJson,
      );

  @override
  Future<BotStatusDto> getStatus() => _mapCached(
        ApiCacheKeys.status,
        _ttlFast,
        () => _client.get<Map<String, dynamic>>('/bot/status'),
        BotStatusDto.fromJson,
      );

  @override
  Future<PortfolioDto> getPortfolio() => _mapCached(
        ApiCacheKeys.portfolio,
        _ttlFast,
        () => _client.get<Map<String, dynamic>>('/portfolio'),
        PortfolioDto.fromJson,
      );

  @override
  Future<StatsDto> getStats() => _mapCached(
        ApiCacheKeys.stats,
        _ttlSlow,
        () => _client.get<Map<String, dynamic>>('/stats'),
        StatsDto.fromJson,
      );

  @override
  Future<List<TradeDto>> getTrades({int limit = 50, String? symbol}) async {
    final key = '${ApiCacheKeys.trades}_${limit}_${symbol ?? 'all'}';
    return _listCached(
      key,
      _ttlSlow,
      () async {
        final data = await _client.get<List<dynamic>>(
          '/trades',
          queryParameters: {
            'limit': limit,
            if (symbol != null) 'symbol': symbol,
          },
        );
        return data;
      },
      (e) => TradeDto.fromJson(asMap(e)),
    );
  }

  @override
  Future<BotConfigDto> getConfig() => _mapCached(
        ApiCacheKeys.config,
        _ttlSlow,
        () => _client.get<Map<String, dynamic>>('/config'),
        BotConfigDto.fromJson,
      );

  @override
  Future<BotConfigDto> patchConfig(Map<String, dynamic> body) async {
    final data = await _client.patch<Map<String, dynamic>>(
      '/config',
      data: body,
    );
    await _cache?.write(ApiCacheKeys.config, data);
    await _cache?.invalidateAll(const [
      ApiCacheKeys.status,
      ApiCacheKeys.health,
    ]);
    return BotConfigDto.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> start({
    required String symbol,
    required String interval,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/bot/start',
      data: {'symbol': symbol, 'interval': interval},
    );
    await _invalidateBotState();
    return data;
  }

  @override
  Future<Map<String, dynamic>> stop() async {
    final data = await _client.post<Map<String, dynamic>>('/bot/stop');
    await _invalidateBotState();
    return data;
  }

  @override
  Future<Map<String, dynamic>> emergencyStop() async {
    final data =
        await _client.post<Map<String, dynamic>>('/bot/emergency-stop');
    await _invalidateBotState();
    return data;
  }

  @override
  Future<Map<String, dynamic>> reconcile() async {
    final data =
        await _client.post<Map<String, dynamic>>('/portfolio/reconcile');
    await _cache?.invalidateAll(const [
      ApiCacheKeys.portfolio,
      ApiCacheKeys.status,
      ApiCacheKeys.stats,
    ]);
    return data;
  }

  @override
  Future<Map<String, dynamic>> adopt() async {
    final data = await _client.post<Map<String, dynamic>>('/portfolio/adopt');
    await _cache?.invalidateAll(ApiCacheKeys.afterMutation);
    return data;
  }

  @override
  Future<List<String>> getPairs({String quote = 'USDT'}) async {
    final key = 'pairs_$quote';
    final cached = _cache?.read(key);
    if (cached != null && cached.isFresh(const Duration(hours: 6))) {
      final list = cached.data;
      if (list is List) {
        unawaited(_refreshPairs(key, quote));
        return list.map((e) => e.toString()).toList();
      }
    }
    try {
      final pairs = await _fetchPairs(quote);
      await _cache?.write(key, pairs);
      return pairs;
    } catch (_) {
      if (cached?.data is List) {
        return (cached!.data as List).map((e) => e.toString()).toList();
      }
      rethrow;
    }
  }

  Future<void> _invalidateBotState() {
    return _cache?.invalidateAll(ApiCacheKeys.afterMutation) ??
        Future<void>.value();
  }

  Future<T> _mapCached<T>(
    String key,
    Duration ttl,
    Future<Map<String, dynamic>> Function() fetch,
    T Function(Map<String, dynamic>) parse,
  ) async {
    final cached = _cache?.read(key);
    if (cached != null && cached.isFresh(ttl) && cached.data is Map) {
      unawaited(_refreshMap(key, fetch));
      return parse(asMap(cached.data));
    }
    try {
      final data = await fetch();
      await _cache?.write(key, data);
      return parse(data);
    } catch (e) {
      if (cached?.data is Map) return parse(asMap(cached!.data));
      rethrow;
    }
  }

  Future<List<T>> _listCached<T>(
    String key,
    Duration ttl,
    Future<List<dynamic>> Function() fetch,
    T Function(dynamic) parse,
  ) async {
    final cached = _cache?.read(key);
    if (cached != null && cached.isFresh(ttl) && cached.data is List) {
      unawaited(_refreshList(key, fetch));
      return (cached.data as List).map(parse).toList(growable: false);
    }
    try {
      final data = await fetch();
      await _cache?.write(key, data);
      return data.map(parse).toList(growable: false);
    } catch (e) {
      if (cached?.data is List) {
        return (cached!.data as List).map(parse).toList(growable: false);
      }
      rethrow;
    }
  }

  Future<void> _refreshMap(
    String key,
    Future<Map<String, dynamic>> Function() fetch,
  ) async {
    try {
      final data = await fetch();
      await _cache?.write(key, data);
    } catch (_) {}
  }

  Future<void> _refreshList(
    String key,
    Future<List<dynamic>> Function() fetch,
  ) async {
    try {
      final data = await fetch();
      await _cache?.write(key, data);
    } catch (_) {}
  }

  Future<void> _refreshPairs(String key, String quote) async {
    try {
      final pairs = await _fetchPairs(quote);
      await _cache?.write(key, pairs);
    } catch (_) {}
  }

  Future<List<String>> _fetchPairs(String quote) async {
    final data = await _client.get<dynamic>(
      '/pairs',
      queryParameters: {'quote': quote},
    );
    if (data is List) {
      return data.map((e) {
        if (e is String) return e;
        if (e is Map) {
          return asString(e['symbol'] ?? e['pair'] ?? e.toString());
        }
        return e.toString();
      }).toList();
    }
    if (data is Map) {
      final list = asList(data['pairs'] ?? data['symbols'] ?? data['data']);
      return list.map((e) => e.toString()).toList();
    }
    return const [];
  }
}
