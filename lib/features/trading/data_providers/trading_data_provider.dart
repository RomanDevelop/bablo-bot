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
  Future<HealthDto> getHealth({bool forceRefresh = false});
  Future<BotStatusDto> getStatus({bool forceRefresh = false});
  Future<PortfolioDto> getPortfolio({bool forceRefresh = false});
  Future<StatsDto> getStats({bool forceRefresh = false});
  Future<List<TradeDto>> getTrades({
    int limit = 50,
    String? symbol,
    bool forceRefresh = false,
  });
  Future<BotConfigDto> getConfig({bool forceRefresh = false});
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
  Future<void> invalidateCache();
}

class TradingDataProvider implements TradingDataProviderInterface {
  TradingDataProvider({
    required NetworkClient networkClient,
    ApiCache? cache,
  })  : _client = networkClient,
        _cache = cache;

  final NetworkClient _client;
  final ApiCache? _cache;

  static const _ttlHealth = Duration(seconds: 10);
  static const _ttlLive = Duration(seconds: 15);
  static const _ttlSlow = Duration(seconds: 45);
  static const _pairsTtl = Duration(hours: 6);

  @override
  Future<HealthDto> getHealth({bool forceRefresh = false}) => _mapCached(
        ApiCacheKeys.health,
        _ttlHealth,
        () => _client.get<Map<String, dynamic>>('/bot/health'),
        HealthDto.fromJson,
        allowStale: false,
        forceRefresh: forceRefresh,
      );

  @override
  Future<BotStatusDto> getStatus({bool forceRefresh = false}) => _mapCached(
        ApiCacheKeys.status,
        _ttlLive,
        () => _client.get<Map<String, dynamic>>('/bot/status'),
        BotStatusDto.fromJson,
        allowStale: false,
        forceRefresh: forceRefresh,
      );

  @override
  Future<PortfolioDto> getPortfolio({bool forceRefresh = false}) =>
      _mapCached(
        ApiCacheKeys.portfolio,
        _ttlLive,
        () => _client.get<Map<String, dynamic>>('/portfolio'),
        PortfolioDto.fromJson,
        allowStale: false,
        forceRefresh: forceRefresh,
      );

  @override
  Future<StatsDto> getStats({bool forceRefresh = false}) => _mapCached(
        ApiCacheKeys.stats,
        _ttlSlow,
        () => _client.get<Map<String, dynamic>>('/stats'),
        StatsDto.fromJson,
        forceRefresh: forceRefresh,
      );

  @override
  Future<List<TradeDto>> getTrades({
    int limit = 50,
    String? symbol,
    bool forceRefresh = false,
  }) {
    final key = symbol == null || symbol.isEmpty
        ? '${ApiCacheKeys.trades}_$limit'
        : '${ApiCacheKeys.trades}_${symbol}_$limit';
    return _listCached(
      key,
      _ttlSlow,
      () async => _fetchTradesRaw(limit: limit, symbol: symbol),
      (e) => TradeDto.fromJson(asMap(e)),
      forceRefresh: forceRefresh,
    );
  }

  Future<List<dynamic>> _fetchTradesRaw({
    required int limit,
    String? symbol,
  }) async {
    final data = await _client.get<dynamic>(
      '/trades',
      queryParameters: {
        'limit': limit,
        if (symbol != null && symbol.isNotEmpty) 'symbol': symbol,
      },
    );
    if (data is List) return data;
    if (data is Map) {
      final list = data['trades'] ?? data['items'] ?? data['data'] ?? data['fills'];
      if (list is List) return list;
    }
    return const [];
  }

  @override
  Future<BotConfigDto> getConfig({bool forceRefresh = false}) => _mapCached(
        ApiCacheKeys.config,
        _ttlSlow,
        () => _client.get<Map<String, dynamic>>('/config'),
        BotConfigDto.fromJson,
        allowStale: false,
        forceRefresh: forceRefresh,
      );

  @override
  Future<BotConfigDto> patchConfig(Map<String, dynamic> body) async {
    final data = await _client.patch<Map<String, dynamic>>('/config', data: body);
    await _cache?.write(ApiCacheKeys.config, data);
    await _cache?.invalidateAll(ApiCacheKeys.afterMutation);
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
    await _cache?.invalidateAll(ApiCacheKeys.afterMutation);
    return data;
  }

  @override
  Future<Map<String, dynamic>> stop() async {
    final data = await _client.post<Map<String, dynamic>>('/bot/stop');
    await _cache?.invalidateAll(ApiCacheKeys.afterMutation);
    return data;
  }

  @override
  Future<Map<String, dynamic>> emergencyStop() async {
    final data =
        await _client.post<Map<String, dynamic>>('/bot/emergency-stop');
    await _cache?.invalidateAll(ApiCacheKeys.afterMutation);
    return data;
  }

  @override
  Future<Map<String, dynamic>> reconcile() async {
    final data =
        await _client.post<Map<String, dynamic>>('/portfolio/reconcile');
    await _cache?.invalidateAll(ApiCacheKeys.afterMutation);
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
    if (cached != null && cached.isFresh(_pairsTtl) && cached.data is List) {
      unawaited(_refreshPairs(key, quote));
      return (cached.data as List).map((e) => e.toString()).toList();
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

  @override
  Future<void> invalidateCache() =>
      _cache?.invalidateAll(ApiCacheKeys.afterMutation) ?? Future.value();

  Future<T> _mapCached<T>(
    String key,
    Duration ttl,
    Future<Map<String, dynamic>> Function() fetch,
    T Function(Map<String, dynamic>) parse, {
    bool allowStale = true,
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      await _cache?.invalidate(key);
    }

    final cached = _cache?.read(key);
    if (!forceRefresh && cached != null && cached.data is Map) {
      if (cached.isFresh(ttl)) {
        return parse(asMap(cached.data));
      }
      if (allowStale) {
        unawaited(_refreshMap(key, fetch));
        return parse(asMap(cached.data));
      }
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
    T Function(dynamic) parse, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      await _cache?.invalidate(key);
    }

    final cached = _cache?.read(key);
    if (!forceRefresh && cached != null && cached.isFresh(ttl) && cached.data is List) {
      unawaited(_refreshList(key, fetch));
      return (cached.data as List).map(parse).toList(growable: false);
    }
    if (!forceRefresh && cached != null && cached.data is List) {
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
      '/market/pairs',
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
