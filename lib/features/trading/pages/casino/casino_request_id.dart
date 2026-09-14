import 'dart:math';

/// Generates idempotent client_request_id values (1–100 chars).
///
/// Flutter web compiles shifts with JS 32-bit ints: `1 << 32 == 0`,
/// and `Random.nextInt(0)` throws RangeError — spin never reached the API.
class CasinoRequestId {
  CasinoRequestId._();

  static final Random _random = Random();

  /// New id for a user-initiated spin/respin.
  static String next() {
    final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final a = _chunk();
    final b = _chunk();
    final id = 'fl-$ts-$a$b';
    return id.length > 100 ? id.substring(0, 100) : id;
  }

  static String _chunk() {
    // nextInt max must be 1..2^32 inclusive; 2^31-1 is safe on JS and VM.
    return _random.nextInt(0x7fffffff).toRadixString(36);
  }
}
