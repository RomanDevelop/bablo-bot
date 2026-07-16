import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CachedJson {
  const CachedJson({required this.data, required this.savedAt});

  final Object data;
  final DateTime savedAt;

  bool isFresh(Duration maxAge) =>
      DateTime.now().difference(savedAt) <= maxAge;
}

/// Shared JSON cache for bot API screens (Home / Portfolio / Trades / Stats / Admin).
class ApiCache {
  ApiCache(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'api_cache_';

  CachedJson? read(String key) {
    final raw = _prefs.getString('$_prefix$key');
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = DateTime.tryParse(map['saved_at'] as String? ?? '');
      if (savedAt == null || map['data'] == null) return null;
      return CachedJson(data: map['data'] as Object, savedAt: savedAt.toLocal());
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, Object data) async {
    final payload = jsonEncode({
      'saved_at': DateTime.now().toUtc().toIso8601String(),
      'data': data,
    });
    await _prefs.setString('$_prefix$key', payload);
  }

  Future<void> invalidate(String key) => _prefs.remove('$_prefix$key');

  Future<void> invalidatePrefix(String keyPrefix) async {
    final fullPrefix = '$_prefix$keyPrefix';
    final toRemove = _prefs
        .getKeys()
        .where((k) => k == fullPrefix || k.startsWith('${fullPrefix}_'))
        .toList();
    for (final k in toRemove) {
      await _prefs.remove(k);
    }
  }

  Future<void> invalidateAll(Iterable<String> keys) async {
    for (final key in keys) {
      if (key == ApiCacheKeys.trades) {
        await invalidatePrefix(key);
      } else {
        await invalidate(key);
      }
    }
  }
}

class ApiCacheKeys {
  static const health = 'bot_health';
  static const status = 'bot_status';
  static const portfolio = 'portfolio';
  static const stats = 'stats';
  static const trades = 'trades';
  static const config = 'config';

  static const afterMutation = [
    health,
    status,
    portfolio,
    stats,
    trades,
    config,
  ];
}
