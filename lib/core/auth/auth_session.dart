import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/microloans_constants.dart';
import '../errors/data_error.dart';
import '../telegram/telegram_web_app.dart';
import '../../features/auth/models/auth_tokens.dart';
import '../../features/auth/models/bablo_bootstrap.dart';
import '../../features/auth/repositories/auth_repository.dart';
import 'token_storage.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Telegram Mini App session — tokens, bootstrap, microloan local state.
class AuthSession extends ChangeNotifier {
  AuthSession({
    required AuthRepository authRepository,
    required TokenStorage tokenStorage,
    required SharedPreferences prefs,
  })  : _auth = authRepository,
        _tokens = tokenStorage,
        _prefs = prefs;

  final AuthRepository _auth;
  final TokenStorage _tokens;
  final SharedPreferences _prefs;

  static const _kLoanTierId = 'bablo_microloan_tier_id';
  static const _kLoanAppliedAt = 'bablo_microloan_applied_at';

  AuthStatus status = AuthStatus.initial;
  BabloBootstrap? bootstrap;
  String? errorMessage;
  Timer? _refreshTimer;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading =>
      status == AuthStatus.initial || status == AuthStatus.loading;
  bool get isInTelegram => telegramWebApp.isAvailable;

  String get displayName =>
      bootstrap?.user.displayName ?? 'Bablo Member';

  String get handle => bootstrap?.telegram.handle ?? '@guest';

  num get rsvBalance => bootstrap?.rewards.paidRsv ?? 0;

  num get earnedRsv => bootstrap?.rewards.earnedRsv ?? 0;

  bool get canUseCopyTrading => bootstrap?.canUseCopyTrading ?? false;

  bool get hasActiveCopyStake => bootstrap?.copy?.stake != null;

  bool get canUseCasino => bootstrap?.canUseCasino ?? false;

  String? get activeLoanTierId => _prefs.getString(_kLoanTierId);

  MicroloanTier? get activeLoanTier {
    final id = activeLoanTierId;
    if (id == null) return null;
    return MicroloansConstants.byId(id);
  }

  DateTime? get loanAppliedAt {
    final ms = _prefs.getInt(_kLoanAppliedAt);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Legacy alias used by microloans UI.
  int get demoRsvBalance => rsvBalance.round();

  static Future<AuthSession> create({
    required AuthRepository authRepository,
    required TokenStorage tokenStorage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return AuthSession(
      authRepository: authRepository,
      tokenStorage: tokenStorage,
      prefs: prefs,
    );
  }

  /// Splash flow: Telegram ready → refresh or initData login.
  Future<void> initialize() async {
    if (status == AuthStatus.loading) return;
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    telegramWebApp.ready();
    telegramWebApp.expand();

    bootstrap = _tokens.readBootstrap();

    try {
      final tokens = _tokens.readTokens();
      if (tokens != null) {
        try {
          await _ensureValidAccess(tokens);
          bootstrap = await _auth.fetchBootstrap();
          status = AuthStatus.authenticated;
        } catch (_) {
          await _loginWithInitData();
        }
      } else {
        await _loginWithInitData();
      }
    } on DataError catch (e) {
      status = AuthStatus.error;
      errorMessage = e.displayMessage;
    } catch (e) {
      status = AuthStatus.unauthenticated;
      errorMessage = e.toString();
    }

    _scheduleProactiveRefresh();
    notifyListeners();
  }

  Future<void> login() async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      await _loginWithInitData();
    } on DataError catch (e) {
      status = AuthStatus.error;
      errorMessage = e.displayMessage;
    } catch (e) {
      status = AuthStatus.unauthenticated;
      errorMessage = e.toString();
    }
    _scheduleProactiveRefresh();
    notifyListeners();
  }

  Future<void> logout() async {
    _refreshTimer?.cancel();
    await _auth.logout();
    bootstrap = null;
    status = AuthStatus.unauthenticated;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshBootstrap() async {
    if (!isAuthenticated && _tokens.readTokens() == null) return;
    try {
      bootstrap = await _auth.fetchBootstrap();
      status = AuthStatus.authenticated;
      notifyListeners();
    } catch (_) {
      // Keep cached bootstrap on transient errors.
    }
  }

  void handleSessionExpired() {
    Future.microtask(() async {
      await _tokens.clearTokens();
      bootstrap = _tokens.readBootstrap();
      status = AuthStatus.unauthenticated;
      errorMessage = 'Session expired. Open in Telegram to sign in again.';
      notifyListeners();
    });
  }

  Future<AuthTokens?> refreshTokensForInterceptor() async {
    try {
      return await _auth.refreshTokens();
    } catch (_) {
      return null;
    }
  }

  Future<void> applyMicroloan(String tierId) async {
    await _prefs.setString(_kLoanTierId, tierId);
    await _prefs.setInt(
      _kLoanAppliedAt,
      DateTime.now().millisecondsSinceEpoch,
    );
    notifyListeners();
  }

  Future<void> clearMicroloan() async {
    await _prefs.remove(_kLoanTierId);
    await _prefs.remove(_kLoanAppliedAt);
    notifyListeners();
  }

  Future<void> _ensureValidAccess(AuthTokens tokens) async {
    if (tokens.isAccessExpired || tokens.shouldRefreshProactively) {
      await _auth.refreshTokens();
    }
  }

  Future<void> _loginWithInitData() async {
    final initData = _auth.readTelegramInitData();
    if (initData == null || initData.isEmpty) {
      status = AuthStatus.unauthenticated;
      return;
    }
    final response = await _auth.loginWithTelegram(initData: initData);
    bootstrap = BabloBootstrap.fromJson(response.bootstrap);
    status = AuthStatus.authenticated;
  }

  void _scheduleProactiveRefresh() {
    _refreshTimer?.cancel();
    final tokens = _tokens.readTokens();
    if (tokens == null) return;
    final delay = tokens.accessExpiresAt
        .subtract(const Duration(minutes: 2))
        .difference(DateTime.now());
    if (delay.isNegative) return;
    _refreshTimer = Timer(delay, () async {
      try {
        await _auth.refreshTokens();
        _scheduleProactiveRefresh();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
