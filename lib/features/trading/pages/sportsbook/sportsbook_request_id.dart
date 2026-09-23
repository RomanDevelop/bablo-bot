import 'dart:math';

/// Idempotent `client_request_id` (1–100 chars). Safe on Flutter web JS ints.
class SportsbookRequestId {
  SportsbookRequestId._();

  static final Random _random = Random();

  static String next() {
    final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final id = 'fl-sb-$ts-${_chunk()}${_chunk()}';
    return id.length > 100 ? id.substring(0, 100) : id;
  }

  static String _chunk() {
    return _random.nextInt(0x7fffffff).toRadixString(36);
  }
}
