import '../../../core/network/network_client.dart';
import '../../../core/utils/json_parsers.dart';
import '../dto/casino_dto.dart';

abstract class CasinoDataProviderInterface {
  Future<CasinoStatusDto> getStatus();

  Future<CasinoBalanceDto> getBalance();

  Future<num> resetDemo();

  Future<List<CasinoGameDto>> getGames();

  Future<CasinoGameDto> getGame(String gameId);

  Future<CasinoSessionDto> startSession({
    required String gameId,
    required String currency,
  });

  Future<CasinoSessionDto> getSession(String sessionId);

  Future<CasinoSpinResultDto> spin({
    required String gameId,
    required num bet,
    required String currency,
    required String action,
    required String clientRequestId,
    String? sessionId,
    String? forcedScenario,
  });

  Future<CasinoSpinResultDto> getSpin(String spinId);

  Future<List<CasinoHistoryItemDto>> getHistory({int limit = 50});

  Future<CasinoStatsDto> getStats();
}

class CasinoDataProvider implements CasinoDataProviderInterface {
  CasinoDataProvider({required NetworkClient networkClient})
      : _client = networkClient;

  final NetworkClient _client;

  static const _base = '/users/me/casino';

  @override
  Future<CasinoStatusDto> getStatus() async {
    final data = await _client.get<Map<String, dynamic>>(_base);
    return _parseStatus(data);
  }

  @override
  Future<CasinoBalanceDto> getBalance() async {
    final data = await _client.get<Map<String, dynamic>>('$_base/balance');
    return CasinoBalanceDto.fromJson(data);
  }

  @override
  Future<num> resetDemo() async {
    final data =
        await _client.post<Map<String, dynamic>>('$_base/demo/reset');
    return asNum(data['demo_credits'] ?? data['available'], 10000);
  }

  @override
  Future<List<CasinoGameDto>> getGames() async {
    final data = await _client.get<dynamic>('$_base/games');
    return _extractList(data)
        .map((e) => CasinoGameDto.fromJson(asMap(e)))
        .toList(growable: false);
  }

  @override
  Future<CasinoGameDto> getGame(String gameId) async {
    final data = await _client
        .get<Map<String, dynamic>>('$_base/games/$gameId');
    return CasinoGameDto.fromJson(data);
  }

  @override
  Future<CasinoSessionDto> startSession({
    required String gameId,
    required String currency,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '$_base/sessions',
      data: {
        'game_id': gameId,
        'currency': currency,
      },
    );
    return CasinoSessionDto.fromJson(data);
  }

  @override
  Future<CasinoSessionDto> getSession(String sessionId) async {
    final data = await _client
        .get<Map<String, dynamic>>('$_base/sessions/$sessionId');
    return CasinoSessionDto.fromJson(data);
  }

  @override
  Future<CasinoSpinResultDto> spin({
    required String gameId,
    required num bet,
    required String currency,
    required String action,
    required String clientRequestId,
    String? sessionId,
    String? forcedScenario,
  }) async {
    final body = <String, dynamic>{
      'game_id': gameId,
      'bet': _jsonAmount(bet),
      'currency': currency,
      'action': action,
      'client_request_id': clientRequestId,
      'session_id': sessionId,
      'forced_scenario': forcedScenario,
    };
    final data = await _client.post<Map<String, dynamic>>(
      '$_base/spin',
      data: body,
    );
    return CasinoSpinResultDto.fromJson(data);
  }

  @override
  Future<CasinoSpinResultDto> getSpin(String spinId) async {
    final data =
        await _client.get<Map<String, dynamic>>('$_base/spins/$spinId');
    return CasinoSpinResultDto.fromJson(data);
  }

  @override
  Future<List<CasinoHistoryItemDto>> getHistory({int limit = 50}) async {
    final data = await _client.get<dynamic>(
      '$_base/history',
      queryParameters: {'limit': limit},
    );
    return _extractList(data)
        .map((e) => CasinoHistoryItemDto.fromJson(asMap(e)))
        .toList(growable: false);
  }

  @override
  Future<CasinoStatsDto> getStats() async {
    final data = await _client.get<Map<String, dynamic>>('$_base/stats');
    return CasinoStatsDto.fromJson(data);
  }

  CasinoStatusDto _parseStatus(Map<String, dynamic> json) {
    if (json['casino'] is Map) {
      return CasinoStatusDto.fromJson(asMap(json['casino']));
    }
    return CasinoStatusDto.fromJson(json);
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in const ['items', 'history', 'spins', 'games', 'data']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  num _jsonAmount(num amount) {
    if (amount == amount.roundToDouble()) return amount.round();
    return amount;
  }
}
