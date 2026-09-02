import '../../../core/network/network_client.dart';
import '../../../core/utils/json_parsers.dart';
import '../dto/backtest_dto.dart';

abstract class BacktestDataProviderInterface {
  Future<BacktestConfigDto> getConfig();
  Future<List<String>> getSymbols({String quote = 'USDT'});
  Future<BacktestRunDto> run({required String symbol, required int days});
}

class BacktestDataProvider implements BacktestDataProviderInterface {
  BacktestDataProvider({required NetworkClient networkClient})
      : _client = networkClient;

  final NetworkClient _client;

  @override
  Future<BacktestConfigDto> getConfig() async {
    final data = await _client.get<Map<String, dynamic>>(
      '/backtest/config',
      skipAuth: true,
    );
    return BacktestConfigDto.fromJson(data);
  }

  @override
  Future<List<String>> getSymbols({String quote = 'USDT'}) async {
    final data = await _client.get<dynamic>(
      '/backtest/symbols',
      queryParameters: {'quote': quote},
      skipAuth: true,
    );
    if (data is List) {
      return data.map((e) {
        if (e is String) return e;
        if (e is Map) return asString(e['symbol'] ?? e['pair']);
        return e.toString();
      }).toList(growable: false);
    }
    if (data is Map) {
      final list = asList(data['symbols'] ?? data['pairs'] ?? data['data']);
      return list.map((e) {
        if (e is String) return e;
        if (e is Map) return asString(e['symbol'] ?? e['pair']);
        return e.toString();
      }).toList(growable: false);
    }
    return const [];
  }

  @override
  Future<BacktestRunDto> run({
    required String symbol,
    required int days,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/backtest/run',
      data: {'symbol': symbol, 'days': days},
      skipAuth: true,
      receiveTimeout: const Duration(seconds: 90),
    );
    return BacktestRunDto.fromJson(data);
  }
}
