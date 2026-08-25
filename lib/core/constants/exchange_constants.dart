/// RSV currency exchange — UI shell until backend is wired.
class ExchangeConstants {
  ExchangeConstants._();

  static const title = 'CURRENCY EXCHANGE';
  static const subtitle = 'Swap anything into Reserve (RSV)';
  static const intro =
      'Bablo Community exchange desk. Pick a currency, enter an amount, '
      'see how much RSV you get at the cabinet rate. Settlement on-chain '
      'and auto-routing — next sprint.';

  static const rsvTicker = 'RSV';
  static const rsvName = 'Reserve';
  static const rsvUsd = 0.13;

  static const telegramHandle = 'romanklia';

  static const buyNote =
      'Need RSV for Temki, courses or cosmic real estate? '
      'Buy Reserve here in the exchange — rates update from the cabinet. '
      'Backend settlement is coming; for now confirm swaps with support.';

  static const referralTitle = 'Free RSV via Telegram';
  static const referralBody =
      'Bring a friend into Bablo Community Telegram. '
      'When they join through your link, admin Angela auto-credits '
      '+5 RSV to your wallet. No forms, no mercy, just RSV.';

  static const referralRewardRsv = 5;
  static const referralAdmin = 'Angela';

  static const uiOnlyHint =
      'Exchange UI is live. On-chain swap and balance credit — soon. '
      'Tap Exchange to send a pre-filled request in Telegram.';

  static Uri swapUri({
    required String fromCode,
    required String amount,
    required String rsvOut,
  }) {
    return Uri.https('t.me', telegramHandle, {
      'text':
          'Привет! Хочу обменять $amount $fromCode на ~$rsvOut RSV через Bablo Exchange.',
    });
  }

  static double rsvFromUsd(double usd) => usd / rsvUsd;

  static double usdFromAmount(ExchangeCurrency c, double amount) =>
      amount * c.usdRate;
}

class ExchangeCurrency {
  const ExchangeCurrency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.usdRate,
    this.icon = '💱',
  });

  final String code;
  final String name;
  final String symbol;
  final double usdRate;
  final String icon;

  double toRsv(double amount) {
    final usd = amount * usdRate;
    return ExchangeConstants.rsvFromUsd(usd);
  }
}

class ExchangeCatalog {
  ExchangeCatalog._();

  static const currencies = <ExchangeCurrency>[
    ExchangeCurrency(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      usdRate: 1,
      icon: '💵',
    ),
    ExchangeCurrency(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      usdRate: 1.08,
      icon: '💶',
    ),
    ExchangeCurrency(
      code: 'UAH',
      name: 'Ukrainian Hryvnia',
      symbol: '₴',
      usdRate: 0.024,
      icon: '🇺🇦',
    ),
    ExchangeCurrency(
      code: 'USDT',
      name: 'Tether',
      symbol: '₮',
      usdRate: 1,
      icon: '🟢',
    ),
    ExchangeCurrency(
      code: 'BTC',
      name: 'Bitcoin',
      symbol: '₿',
      usdRate: 68000,
      icon: '🟠',
    ),
    ExchangeCurrency(
      code: 'ETH',
      name: 'Ethereum',
      symbol: 'Ξ',
      usdRate: 3400,
      icon: '💎',
    ),
    ExchangeCurrency(
      code: 'RSV',
      name: 'Reserve',
      symbol: 'R',
      usdRate: ExchangeConstants.rsvUsd,
      icon: '🪙',
    ),
  ];

  static ExchangeCurrency byCode(String code) {
    return currencies.firstWhere(
      (c) => c.code == code,
      orElse: () => currencies.first,
    );
  }
}
