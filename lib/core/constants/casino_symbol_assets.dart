/// Casino slot symbol SVG assets mapped from server board codes.
class CasinoSymbolAssets {
  CasinoSymbolAssets._();

  static const _dir = 'assets/casino/symbols';

  static const cherry = '$_dir/cherry.svg';
  static const coin = '$_dir/coin.svg';
  static const bar = '$_dir/bar.svg';
  static const seven = '$_dir/seven.svg';
  static const diamond = '$_dir/diamond.svg';
  static const bablo = '$_dir/bablo.svg';
  static const wild = '$_dir/wild.svg';
  static const rsvCoin = '$_dir/rsv_coin.svg';
  static const idle = '$_dir/idle.svg';

  /// Resolves server symbol code → asset path. Unknown codes fall back to [wild].
  static String pathFor(String symbol, {bool idle = false}) {
    if (idle) return CasinoSymbolAssets.idle;
    final s = symbol.trim().toUpperCase();
    if (s.isEmpty || s == '·' || s == '.' || s == 'EMPTY') {
      return CasinoSymbolAssets.idle;
    }
    return switch (s) {
      'CHERRY' => cherry,
      'COIN' => coin,
      'BAR' => bar,
      'SEVEN' => seven,
      'DIAMOND' => diamond,
      'BABLO' => bablo,
      'WILD' => wild,
      'RSV_COIN' => rsvCoin,
      _ => wild,
    };
  }
}
