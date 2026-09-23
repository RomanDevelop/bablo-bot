import '../navigation/app_routes.dart';

/// External / promo services shown in Right Side Menu (not trading logic).
class ExternalServicesConfig {
  ExternalServicesConfig._();

  static const premiumBadge = 'Premium';

  static const premiumGateTitle = 'Только для Premium';
  static const premiumGateBody =
      '«{title}» доступен только на тарифе Premium.\n\n'
      'С Premium открываются ставки, PokerStars, Casino и другие '
      'закрытые сервисы Bablo Community. Оформи подписку — и двери откроются.';

  static const pokerStars = ExternalServiceLink(
    id: 'pokerstars',
    title: 'PokerStars',
    subtitle: 'Покер · внешний сервис',
    url: String.fromEnvironment('POKERSTARS_URL', defaultValue: ''),
    enabled: true,
    badge: premiumBadge,
    requiresPremium: true,
  );

  static const casino = ExternalServiceLink(
    id: 'casino',
    title: 'Casino',
    subtitle: 'Казино · Bablo Community',
    url: '',
    enabled: true,
    internalRoute: AppRoutes.casino,
  );

  static const sportsBetting = ExternalServiceLink(
    id: 'sports_betting',
    title: 'Ставки на спорт',
    subtitle: 'NBA · Bablo Community',
    url: '',
    enabled: true,
    internalRoute: AppRoutes.sportsbook,
  );

  static const temkiMutki = ExternalServiceLink(
    id: 'temki_mutki',
    title: 'Темки, мутки',
    subtitle: 'Марс · Луна · космолёты · RSV',
    url: '',
    enabled: true,
    internalRoute: AppRoutes.temki,
  );

  static const telegramCommunity = ExternalServiceLink(
    id: 'telegram_community',
    title: 'Telegram Community',
    subtitle: 'Новости и чат',
    url: String.fromEnvironment(
      'TELEGRAM_COMMUNITY_URL',
      defaultValue: 'https://t.me/',
    ),
    enabled: true,
  );

  static const List<ExternalServiceLink> leisure = [
    sportsBetting,
    pokerStars,
    casino,
    temkiMutki,
  ];

  static String premiumGateMessage(String title) =>
      premiumGateBody.replaceAll('{title}', title);
}

class ExternalServiceLink {
  const ExternalServiceLink({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.url,
    this.enabled = true,
    this.badge,
    this.internalRoute,
    this.requiresPremium = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String url;
  final bool enabled;
  final String? badge;
  final String? internalRoute;
  final bool requiresPremium;

  bool get hasUrl => url.trim().isNotEmpty && url != 'https://t.me/';
  bool get isInternal => internalRoute != null && internalRoute!.isNotEmpty;
}
