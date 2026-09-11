import 'dart:math';

/// Generates idempotent client_request_id values (1–100 chars).
class CasinoRequestId {
  CasinoRequestId._();

  static final Random _random = Random();

  /// New id for a user-initiated spin/respin.
  static String next() {
    final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final a = _random.nextInt(1 << 32).toRadixString(36);
    final b = _random.nextInt(1 << 32).toRadixString(36);
    final id = 'fl-$ts-$a$b';
    return id.length > 100 ? id.substring(0, 100) : id;
  }
}
