import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/microloans_constants.dart';

/// Local auth / profile stub until Bablo backend login ships.
class AuthSession extends ChangeNotifier {
  AuthSession._(this._prefs);

  static const _kSignedIn = 'bablo_auth_signed_in';
  static const _kDisplayName = 'bablo_auth_display_name';
  static const _kHandle = 'bablo_auth_handle';
  static const _kLoanTierId = 'bablo_microloan_tier_id';
  static const _kLoanAppliedAt = 'bablo_microloan_applied_at';

  final SharedPreferences _prefs;

  bool get isAuthenticated => _prefs.getBool(_kSignedIn) ?? false;

  String get displayName {
    final raw = _prefs.getString(_kDisplayName)?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return 'Bablo Member';
  }

  String get handle {
    final raw = _prefs.getString(_kHandle)?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return '@guest';
  }

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

  /// Demo RSV balance until backend wallet exists.
  int get demoRsvBalance {
    final loan = activeLoanTier;
    if (loan == null) return 0;
    // Advance credited locally after apply (transfer to crypto wallet later).
    return loan.principalRsv;
  }

  static Future<AuthSession> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthSession._(prefs);
  }

  /// UI-only sign-in. Real OAuth / backend tokens come later.
  Future<void> signInStub({
    String displayName = 'Bablo Member',
    String handle = '@bablo_user',
  }) async {
    await _prefs.setBool(_kSignedIn, true);
    await _prefs.setString(_kDisplayName, displayName);
    await _prefs.setString(_kHandle, handle);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _prefs.setBool(_kSignedIn, false);
    notifyListeners();
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
}
