import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/models/auth_tokens.dart';
import '../../features/auth/models/bablo_bootstrap.dart';

class TokenStorage {
  TokenStorage._(this._prefs);

  static const _kAccess = 'bablo_access_token';
  static const _kRefresh = 'bablo_refresh_token';
  static const _kExpires = 'bablo_access_expires_at';
  static const _kSession = 'bablo_session_id';
  static const _kBootstrap = 'bablo_bootstrap_json';

  final SharedPreferences _prefs;

  static Future<TokenStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TokenStorage._(prefs);
  }

  AuthTokens? readTokens() {
    final access = _prefs.getString(_kAccess);
    final refresh = _prefs.getString(_kRefresh);
    final expiresRaw = _prefs.getString(_kExpires);
    final session = _prefs.getString(_kSession);
    if (access == null ||
        refresh == null ||
        expiresRaw == null ||
        session == null) {
      return null;
    }
    final expires = DateTime.tryParse(expiresRaw);
    if (expires == null) return null;
    return AuthTokens(
      accessToken: access,
      refreshToken: refresh,
      accessExpiresAt: expires,
      sessionId: session,
    );
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    await _prefs.setString(_kAccess, tokens.accessToken);
    await _prefs.setString(_kRefresh, tokens.refreshToken);
    await _prefs.setString(_kExpires, tokens.accessExpiresAt.toIso8601String());
    await _prefs.setString(_kSession, tokens.sessionId);
  }

  Future<void> clearTokens() async {
    await _prefs.remove(_kAccess);
    await _prefs.remove(_kRefresh);
    await _prefs.remove(_kExpires);
    await _prefs.remove(_kSession);
  }

  BabloBootstrap? readBootstrap() {
    final raw = _prefs.getString(_kBootstrap);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return BabloBootstrap.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBootstrap(BabloBootstrap bootstrap) async {
    await _prefs.setString(_kBootstrap, jsonEncode(bootstrap.toJson()));
  }

  Future<void> clearBootstrap() async {
    await _prefs.remove(_kBootstrap);
  }

  Future<void> clearAll() async {
    await clearTokens();
    await clearBootstrap();
  }
}
