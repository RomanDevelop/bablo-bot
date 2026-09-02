/// Backtest Lab — public API, no auth required.
class BacktestConstants {
  BacktestConstants._();

  static const title = 'BACKTEST LAB';
  static const subtitle = 'Test Alligator H1 on any pair';
  static const intro =
      'Run historical simulation on our backend using the same strategy as the '
      'live bot: Alligator on H1, SL 1.5×ATR, TP 3×ATR. One symbol at a time — '
      'not the scanner basket.';

  static const defaultQuote = 'USDT';
  static const defaultSymbol = 'SOLUSDT';
  static const defaultDays = 90;

  static const dayPresets = <int>[30, 90, 180];

  static const disclaimer =
      'Simulation only. No fees or slippage included. Past performance does '
      'not guarantee future results. Strategy matches live Alligator H1 profile.';

  static const runHint =
      'Backtest may take 10–30 seconds depending on period and symbol.';

  static String errorMessage(String? code) {
    return switch (code) {
      'invalid_symbol' => 'Пара не найдена',
      'invalid_symbol_format' => 'Формат: AVAXUSDT',
      'binance_unavailable' => 'Попробуй позже',
      _ => 'Не удалось выполнить бэктест',
    };
  }

  /// User typed "AVAX" → "AVAXUSDT"; already full symbol unchanged.
  static String normalizeSymbol(String raw, {String quote = defaultQuote}) {
    final s = raw.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (s.isEmpty) return defaultSymbol;
    if (s.endsWith(quote)) return s;
    return '$s$quote';
  }
}
