/// Asset paths for casino reel symbols (PNG).
class CasinoSymbolAssets {
  CasinoSymbolAssets._();

  static const _dir = 'assets/casino/symbols';

  static const cherry = '$_dir/cherry.png';
  static const coin = '$_dir/coin.png';
  static const bar = '$_dir/bar.png';
  static const seven = '$_dir/seven.png';
  static const diamond = '$_dir/diamond.png';
  static const bablo = '$_dir/bablo.png';
  static const wild = '$_dir/wild.png';
  static const rsvCoin = '$_dir/rsv_coin.png';
  static const idle = '$_dir/idle.png';

  static String pathFor(String symbol, {bool idle = false}) {
    if (idle) return CasinoSymbolAssets.idle;
    final s = symbol.trim().toUpperCase();
    return switch (s) {
      'CHERRY' => cherry,
      'COIN' => coin,
      'BAR' => bar,
      'SEVEN' => seven,
      'DIAMOND' => diamond,
      'BABLO' => bablo,
      'WILD' => wild,
      'RSV_COIN' => rsvCoin,
      '' || '·' || '.' || 'EMPTY' || 'IDLE' => CasinoSymbolAssets.idle,
      _ => CasinoSymbolAssets.idle,
    };
  }
}
