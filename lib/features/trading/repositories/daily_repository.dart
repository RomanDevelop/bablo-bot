import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/daily_constants.dart';
import '../../../core/network/network_client.dart';
import '../../../core/utils/json_parsers.dart';
import '../models/daily_article.dart';

/// Memory + disk list cache. Carousel paints last issues immediately.
class DailyRepository {
  DailyRepository({
    required NetworkClient networkClient,
    required SharedPreferences prefs,
  })  : _client = networkClient,
        _prefs = prefs;

  final NetworkClient _client;
  final SharedPreferences _prefs;

  final Map<String, List<DailyArticle>> _listCache = {};
  final Map<String, DailyArticle> _byId = {};

  DailyArticle? cachedById(String id) => _byId[id];

  List<DailyArticle> peekArticles({String? category}) {
    final key = category ?? '';
    final memory = _listCache[key];
    if (memory != null) return memory;
    final disk = _readDisk(key);
    if (disk == null) return const [];
    _hydrate(key, disk);
    return disk;
  }

  Future<List<DailyArticle>> getArticles({
    String? category,
    int limit = DailyConstants.listLimit,
    bool forceRefresh = false,
  }) async {
    final key = category ?? '';
    if (!forceRefresh) {
      final cached = peekArticles(category: key);
      if (cached.isNotEmpty) return cached;
    }

    final data = await _client.get<Map<String, dynamic>>(
      '/articles',
      queryParameters: {
        'limit': limit,
        if (key.isNotEmpty) 'category': key,
      },
    );
    final items = asList(data['items'])
        .map((e) => DailyArticle.fromJson(asMap(e)))
        .where((e) => e.id.isNotEmpty)
        .toList(growable: false);

    _hydrate(key, items);
    await _writeDisk(key, items);
    return items;
  }

  Future<DailyArticle> getArticle(String id) async {
    final cached = _byId[id];
    if (cached != null && cached.hasBody) return cached;

    final data = await _client.get<Map<String, dynamic>>('/articles/$id');
    final article = DailyArticle.fromJson(data);
    _put(article);
    return _byId[id] ?? article;
  }

  Future<DailyArticle> getLatest() async {
    final data = await _client.get<Map<String, dynamic>>('/articles/latest');
    final article = DailyArticle.fromJson(data);
    _put(article);
    return _byId[article.id] ?? article;
  }

  Future<DailyArticle> postReaction({
    required String id,
    required String type,
  }) async {
    final userId = await _reactorId();
    final data = await _client.post<Map<String, dynamic>>(
      '/articles/$id/reaction',
      data: {'type': type, 'userId': userId},
    );

    DailyReactions reactions;
    if (data.containsKey('reactions')) {
      reactions = DailyReactions.fromJson(asMap(data['reactions']));
    } else if (data.containsKey('dig') || data.containsKey('shit')) {
      reactions = DailyReactions.fromJson(data);
    } else {
      final current = _byId[id]?.reactions ?? const DailyReactions();
      reactions = current.incremented(type);
    }

    final base = _byId[id];
    if (base == null) {
      return getArticle(id);
    }
    final updated = base.copyWith(reactions: reactions);
    _put(updated);
    return updated;
  }

  void _hydrate(String key, List<DailyArticle> items) {
    _listCache[key] = items;
    for (final item in items) {
      _put(item);
    }
  }

  String _diskKey(String category) =>
      '${DailyConstants.listCachePrefix}${category.isEmpty ? 'all' : category}';

  List<DailyArticle>? _readDisk(String key) {
    final raw = _prefs.getString(_diskKey(key));
    if (raw == null || raw.isEmpty) return null;
    try {
      final items = asList(jsonDecode(raw))
          .map((e) => DailyArticle.fromJson(asMap(e)))
          .where((e) => e.id.isNotEmpty)
          .toList(growable: false);
      return items.isEmpty ? null : items;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeDisk(String key, List<DailyArticle> items) {
    return _prefs.setString(
      _diskKey(key),
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  void _put(DailyArticle article) {
    final existing = _byId[article.id];
    _byId[article.id] = existing == null ? article : existing.merge(article);
  }

  Future<String> _reactorId() async {
    final stored = _prefs.getString(DailyConstants.reactorIdKey);
    if (stored != null && stored.isNotEmpty) return stored;
    final rand = Random.secure();
    final id = List.generate(
      16,
      (_) => rand.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await _prefs.setString(DailyConstants.reactorIdKey, id);
    return id;
  }
}
