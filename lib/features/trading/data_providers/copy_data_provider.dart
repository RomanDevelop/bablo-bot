import '../../../core/network/network_client.dart';
import '../../../core/utils/json_parsers.dart';
import '../dto/copy_dto.dart';

abstract class CopyDataProviderInterface {
  Future<CopyStatusDto> getStatus();

  Future<CopyStatusDto> enable({
    required num amountRsv,
    required bool acceptDisclaimer,
  });

  Future<CopyStatusDto> topup({required num amountRsv});

  Future<CopyStatusDto> exit();

  Future<CopyStatusDto> complete();

  Future<List<CopyHistoryItemDto>> getHistory({int limit = 50});
}

class CopyDataProvider implements CopyDataProviderInterface {
  CopyDataProvider({required NetworkClient networkClient})
      : _client = networkClient;

  final NetworkClient _client;

  static const _statusPath = '/users/me/copy';

  @override
  Future<CopyStatusDto> getStatus() async {
    final data = await _client.get<Map<String, dynamic>>(_statusPath);
    return _parseStatus(data);
  }

  @override
  Future<CopyStatusDto> enable({
    required num amountRsv,
    required bool acceptDisclaimer,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '$_statusPath/enable',
      data: {
        'amount_rsv': _jsonAmount(amountRsv),
        'accept_disclaimer': acceptDisclaimer,
      },
    );
    return _parseStatus(data);
  }

  @override
  Future<CopyStatusDto> topup({required num amountRsv}) async {
    final data = await _client.post<Map<String, dynamic>>(
      '$_statusPath/topup',
      data: {'amount_rsv': _jsonAmount(amountRsv)},
    );
    return _parseStatus(data);
  }

  @override
  Future<CopyStatusDto> exit() async {
    final data = await _client.post<Map<String, dynamic>>('$_statusPath/exit');
    return _parseStatus(data);
  }

  @override
  Future<CopyStatusDto> complete() async {
    final data =
        await _client.post<Map<String, dynamic>>('$_statusPath/complete');
    return _parseStatus(data);
  }

  @override
  Future<List<CopyHistoryItemDto>> getHistory({int limit = 50}) async {
    final data = await _client.get<dynamic>(
      '$_statusPath/history',
      queryParameters: {'limit': limit},
    );
    return _extractList(data)
        .map((e) => CopyHistoryItemDto.fromJson(asMap(e)))
        .toList(growable: false);
  }

  CopyStatusDto _parseStatus(Map<String, dynamic> json) {
    if (json['copy'] is Map) {
      return CopyStatusDto.fromJson(asMap(json['copy']));
    }
    return CopyStatusDto.fromJson(json);
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in const ['items', 'history', 'trades', 'data']) {
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
