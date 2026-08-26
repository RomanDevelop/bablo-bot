/// Trading signals feed + Premium robot account linking.
class SignalsConstants {
  SignalsConstants._();

  static const title = 'SIGNALS';
  static const subtitle = 'Крипто · Спот · US Stocks';
  static const intro =
      'Живые сигналы Bablo по сделкам. Смотри ленту бесплатно — '
      'подключай свой счёт к торговому роботу только с Premium.';

  static const robotsTitle = 'ПОДКЛЮЧЕНИЕ РОБОТОВ';
  static const robotsSubtitle =
      'Прямое подключение биржевого счёта к нашим ботам. '
      'Доступно на тарифе Premium.';

  static const premiumGateTitle = 'Только для Premium';
  static const premiumGateBody =
      'Подключение счёта к торговому роботу доступно только с Premium.\n\n'
      'Оформи подписку — и сможешь привязать Binance / UTEX к ботам Bablo '
      'прямо из этого экрана.';

  static const connectCta = 'Подключить счёт';
  static const upgradeCta = 'Оформить Premium';
  static const connectSoonMessage =
      'Привязка API-ключа появится после бэкенда. Пока — оформите Premium.';

  static const categories = <SignalCategory>[
    SignalCategory(id: '', label: 'Все'),
    SignalCategory(id: 'crypto', label: 'Crypto Futures'),
    SignalCategory(id: 'spot', label: 'Spot'),
    SignalCategory(id: 'us_stocks', label: 'US Stocks'),
  ];

  static const robots = <SignalRobot>[
    SignalRobot(
      id: 'alligator-crypto',
      title: 'Alligator · Crypto Futures',
      subtitle: 'BTC/USDT · H1 · Binance Futures',
      market: 'crypto',
      exchange: 'Binance',
    ),
    SignalRobot(
      id: 'spot-macd',
      title: 'MACD · Spot',
      subtitle: 'ETH/USDT · Spot · Binance',
      market: 'spot',
      exchange: 'Binance',
    ),
    SignalRobot(
      id: 'us-stocks-utex',
      title: 'US Stocks · UTEX',
      subtitle: 'AAPL / TSLA · margin USDT',
      market: 'us_stocks',
      exchange: 'UTEX',
    ),
  ];

  /// Demo feed until live signals API is wired.
  static const demoSignals = <TradeSignalItem>[
    TradeSignalItem(
      id: 's1',
      market: 'crypto',
      marketLabel: 'Crypto Futures',
      pair: 'BTC/USDT',
      side: 'BUY',
      price: '68 420',
      timeframe: 'H1',
      reason: 'Alligator Lips↑ · кросс выше Teeth',
      atLabel: '2 мин назад',
    ),
    TradeSignalItem(
      id: 's2',
      market: 'spot',
      marketLabel: 'Spot',
      pair: 'ETH/USDT',
      side: 'SELL',
      price: '3 412',
      timeframe: 'H4',
      reason: 'MACD / signal кросс вниз',
      atLabel: '18 мин назад',
    ),
    TradeSignalItem(
      id: 's3',
      market: 'us_stocks',
      marketLabel: 'US Stocks',
      pair: 'AAPL',
      side: 'BUY',
      price: '214.50',
      timeframe: 'D1',
      reason: 'Impulse + объём · UTEX',
      atLabel: '41 мин назад',
    ),
    TradeSignalItem(
      id: 's4',
      market: 'crypto',
      marketLabel: 'Crypto Futures',
      pair: 'SOL/USDT',
      side: 'HOLD',
      price: '148.20',
      timeframe: 'H1',
      reason: 'Боковик · ждём Lips',
      atLabel: '1 ч назад',
    ),
    TradeSignalItem(
      id: 's5',
      market: 'spot',
      marketLabel: 'Spot',
      pair: 'BNB/USDT',
      side: 'BUY',
      price: '592.10',
      timeframe: 'H1',
      reason: 'Отскок от Jaw · spot',
      atLabel: '2 ч назад',
    ),
    TradeSignalItem(
      id: 's6',
      market: 'us_stocks',
      marketLabel: 'US Stocks',
      pair: 'TSLA',
      side: 'SELL',
      price: '248.90',
      timeframe: 'H4',
      reason: 'Фиксация после импульса',
      atLabel: '3 ч назад',
    ),
  ];
}

class SignalCategory {
  const SignalCategory({required this.id, required this.label});

  final String id;
  final String label;
}

class SignalRobot {
  const SignalRobot({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.market,
    required this.exchange,
  });

  final String id;
  final String title;
  final String subtitle;
  final String market;
  final String exchange;
}

class TradeSignalItem {
  const TradeSignalItem({
    required this.id,
    required this.market,
    required this.marketLabel,
    required this.pair,
    required this.side,
    required this.price,
    required this.timeframe,
    required this.reason,
    required this.atLabel,
  });

  final String id;
  final String market;
  final String marketLabel;
  final String pair;
  final String side;
  final String price;
  final String timeframe;
  final String reason;
  final String atLabel;
}
