/// Subscription / support product catalog (Stripe price IDs filled from backend later).
class SubscriptionConstants {
  SubscriptionConstants._();

  /// Stripe Checkout / PaymentIntent is created on API; client opens returned URL.
  static const checkoutReady = false;

  static const _rsvRewardsFeature =
      'RSV Rewards — при отрицательном месяце начисляются RSV как награда '
      'за участие, а не как денежная компенсация';
  static const _dexFeature =
      'DEX — после листинга пользователь сможет вывести RSV на Polygon '
      'и обменять их через QuickSwap';

  static const List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      id: SubscriptionPlanId.tips,
      title: 'Сиськи',
      tagline: 'Микро-поддержка проекта',
      priceLabel: '\$1',
      billingLabel: 'разово',
      accent: SubscriptionAccent.mint,
      features: [
        'Поддержка развития бота',
        'Бейдж «Сиськи» в профиле',
        'Доступ к закрытому чату донатеров',
      ],
      ctaLabel: 'Закинуть \$1',
      stripePriceId: String.fromEnvironment('STRIPE_PRICE_TIPS'),
    ),
    SubscriptionPlan(
      id: SubscriptionPlanId.fund,
      title: 'Инвестиция в фонд',
      tagline: 'Вы сами задаёте сумму',
      priceLabel: 'своя сумма',
      billingLabel: 'разово',
      accent: SubscriptionAccent.gold,
      features: [
        'Доля в общем торговом фонде',
        'Прозрачная отчётность по PnL',
        'Вывод по правилам фонда',
        _rsvRewardsFeature,
        _dexFeature,
      ],
      ctaLabel: 'Инвестировать',
      allowsCustomAmount: true,
      minAmountUsd: 10,
      suggestedAmountsUsd: [50, 100, 250, 500, 1000],
      stripePriceId: String.fromEnvironment('STRIPE_PRICE_FUND'),
    ),
    SubscriptionPlan(
      id: SubscriptionPlanId.premium,
      title: 'Premium',
      tagline: 'Фонд + Сиськи + сделки live',
      priceLabel: '\$49',
      billingLabel: '/ мес',
      accent: SubscriptionAccent.teal,
      isPopular: true,
      features: [
        'Всё из «Сиськи»',
        'Участие в фонде (инвестиция)',
        'Сделки и сигналы в реальном времени',
        'Расширенная статистика',
        _rsvRewardsFeature,
        _dexFeature,
      ],
      ctaLabel: 'Оформить Premium',
      stripePriceId: String.fromEnvironment('STRIPE_PRICE_PREMIUM'),
    ),
    SubscriptionPlan(
      id: SubscriptionPlanId.pro,
      title: 'Pro',
      tagline: 'Робот на вашем счёте',
      priceLabel: '\$100',
      billingLabel: '/ мес',
      accent: SubscriptionAccent.pro,
      features: [
        'Всё из Premium',
        'Подключение робота к вашему Binance',
        'Прямое управление на вашем балансе',
        'Приоритетная поддержка 24/7',
        _rsvRewardsFeature,
        _dexFeature,
      ],
      ctaLabel: 'Подключить Pro',
      stripePriceId: String.fromEnvironment('STRIPE_PRICE_PRO'),
    ),
  ];
}

enum SubscriptionPlanId { tips, fund, premium, pro }

enum SubscriptionAccent { mint, gold, teal, pro }

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.tagline,
    required this.priceLabel,
    required this.billingLabel,
    required this.accent,
    required this.features,
    required this.ctaLabel,
    this.stripePriceId = '',
    this.isPopular = false,
    this.allowsCustomAmount = false,
    this.minAmountUsd = 0,
    this.suggestedAmountsUsd = const [],
  });

  final SubscriptionPlanId id;
  final String title;
  final String tagline;
  final String priceLabel;
  final String billingLabel;
  final SubscriptionAccent accent;
  final List<String> features;
  final String ctaLabel;
  final String stripePriceId;
  final bool isPopular;
  final bool allowsCustomAmount;
  final double minAmountUsd;
  final List<int> suggestedAmountsUsd;
}
