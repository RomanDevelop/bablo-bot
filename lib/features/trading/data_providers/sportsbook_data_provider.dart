import '../../../core/network/network_client.dart';
import '../../../core/utils/json_parsers.dart';
import '../dto/sportsbook_dto.dart';

abstract class SportsbookDataProviderInterface {
  Future<SportsbookStatusDto> getStatus();

  Future<List<SportsbookEventDto>> getEvents();

  Future<SportsbookEventDto> getEvent(String eventId);

  Future<SportsbookMarketsDto> getMarkets(String eventId);

  Future<SportsbookBetDto> placeBet({
    required String eventId,
    required String providerOutcomeId,
    required num stake,
    required num expectedOdds,
    required String clientRequestId,
  });

  Future<List<SportsbookBetDto>> getBets({int limit = 50});

  Future<SportsbookBetDto> getBet(String betId);
}

class SportsbookDataProvider implements SportsbookDataProviderInterface {
  SportsbookDataProvider({required NetworkClient networkClient})
      : _client = networkClient;

  final NetworkClient _client;

  static const _base = '/users/me/sports';

  @override
  Future<SportsbookStatusDto> getStatus() async {
    final data = await _client.get<Map<String, dynamic>>(_base);
    return SportsbookStatusDto.fromJson(data);
  }

  @override
  Future<List<SportsbookEventDto>> getEvents() async {
    final data = await _client.get<dynamic>(
      '$_base/events',
      queryParameters: const {'include_markets': true},
    );
    return _extractList(data)
        .map((e) => SportsbookEventDto.fromJson(asMap(e)))
        .toList(growable: false);
  }

  @override
  Future<SportsbookEventDto> getEvent(String eventId) async {
    final data = await _client.get<dynamic>('$_base/events/${_pathId(eventId)}');
    return SportsbookEventDto.fromJson(asMap(data));
  }

  @override
  Future<SportsbookMarketsDto> getMarkets(String eventId) async {
    final data = await _client.get<dynamic>(
      '$_base/events/${_pathId(eventId)}/markets',
    );
    return SportsbookMarketsDto.fromJson(asMap(data));
  }

  @override
  Future<SportsbookBetDto> placeBet({
    required String eventId,
    required String providerOutcomeId,
    required num stake,
    required num expectedOdds,
    required String clientRequestId,
  }) async {
    final data = await _client.post<dynamic>(
      '$_base/bets',
      data: {
        'event_id': eventId,
        'provider_outcome_id': providerOutcomeId,
        'stake': _jsonAmount(stake),
        'expected_odds': expectedOdds,
        'client_request_id': clientRequestId,
      },
    );
    return SportsbookBetDto.fromJson(_asResponseMap(data));
  }

  @override
  Future<List<SportsbookBetDto>> getBets({int limit = 50}) async {
    final data = await _client.get<dynamic>(
      '$_base/bets',
      queryParameters: {'limit': limit},
    );
    return _extractList(data)
        .map((e) => SportsbookBetDto.fromJson(asMap(e)))
        .toList(growable: false);
  }

  @override
  Future<SportsbookBetDto> getBet(String betId) async {
    final data = await _client.get<dynamic>('$_base/bets/$betId');
    return SportsbookBetDto.fromJson(_asResponseMap(data));
  }

  Map<String, dynamic> _asResponseMap(dynamic data) {
    final map = asMap(data);
    if (map.isEmpty) return map;
    if (map['id'] != null && (map['stake'] != null || map['status'] != null)) {
      return map;
    }
    if (map['bet'] is Map) return asMap(map['bet']);
    if (map['data'] is Map) return asMap(map['data']);
    return map;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in const ['items', 'events', 'bets', 'data']) {
        final value = data[key];
        if (value is List) return value;
        if (value is Map) {
          final nested = _extractList(value);
          if (nested.isNotEmpty) return nested;
        }
      }
    }
    return const [];
  }

  String _pathId(String eventId) {
    final id = eventId.trim();
    final parts = id.split('-');
    final uuidShaped = parts.length == 5 &&
        parts[0].length == 8 &&
        parts[1].length == 4 &&
        parts[2].length == 4 &&
        parts[3].length == 4 &&
        parts[4].length == 12;
    return uuidShaped ? id : Uri.encodeComponent(id);
  }

  num _jsonAmount(num amount) {
    if (amount == amount.roundToDouble()) return amount.round();
    return amount;
  }
}
