/// Bablo Sportsbook — client copy & paths. Backend is the source of truth.
class SportsbookConstants {
  SportsbookConstants._();

  static const permission = 'USE_SPORTSBOOK';

  static const title = 'SPORTSBOOK';
  static const subtitle = 'Ставки на спорт';
  static const intro =
      'NBA, только RSV. Клиент не считает payout и не сеталит ставки — '
      'источник истины backend. Prematch, один исход на матч.';

  static const needAuth = 'Войдите в профиль, чтобы открыть спортбук';
  static const premiumTitle = 'Нужна подписка PREMIUM';
  static const premiumBody =
      'Ставки на спорт открываются на тарифе PREMIUM и PRO.';
  static const premiumCta = 'Оформить Premium';
  static const disabledTitle = 'Спортбук временно выключен';
  static const disabledBody =
      'Приём ставок сейчас недоступен. История и баланс остаются на месте.';

  static const availableRsv = 'Available RSV';
  static const inCopy = 'В Copy';
  static const balanceHint =
      'Ставить можно только с available RSV. Залоченные в Copy недоступны.';
  static const eventsCta = 'Матчи NBA';
  static const historyCta = 'История ставок';
  static const eventsTitle = 'NBA';
  static const eventsEmpty = 'Матчей пока нет — off-season или линии недоступны';
  static const historyTitle = 'История';
  static const historyEmpty = 'Ставок пока нет';
  static const liveBadge = 'Идёт';
  static const scheduledBadge = 'SCHEDULED';
  static const finishedBadge = 'FINISHED';
  static const placeCta = 'Поставить';
  static const confirmCta = 'Подтвердить';
  static const cancel = 'Отмена';
  static const stakeLabel = 'Ставка';
  static const oddsLabel = 'Коэф.';
  static const pickLabel = 'Исход';
  static const previewLabel = 'Возможный выигрыш ≈';
  static const acceptedLabel = 'Принято';
  static const payoutLabel = 'Выплата';
  static const refreshOdds = 'Обновить линию';
  static const sport = 'BASKETBALL';
  static const competition = 'NBA';
  static const currency = 'RSV';
  static const marketWinner = 'MATCH_WINNER';

  static const minStakeRsv = 10.0;
  static const maxStakeRsv = 100.0;
  static const stakeStep = 10.0;
  static const historyLimit = 50;
  static const pollInterval = Duration(seconds: 45);

  static const statusOpen = 'OPEN';
  static const statusWon = 'WON';
  static const statusLost = 'LOST';
  static const statusVoid = 'VOID';
  static const eventScheduled = 'SCHEDULED';
  static const eventLive = 'LIVE';
  static const eventFinished = 'FINISHED';
  static const marketOpen = 'OPEN';

  static const errorPlanRequired = 'Нужна подписка PREMIUM';
  static const errorDisabled = 'Спортбук временно выключен';
  static const errorMinStake = 'Минимум 10 RSV';
  static const errorMaxStake = 'Максимум 100 RSV';
  static const errorInsufficient = 'Недостаточно available RSV';
  static const errorOddsChanged = 'Коэффициент изменился — обнови';
  static const errorEventClosed = 'Ставки на матч закрыты';
  static const errorNotFound = 'Не найдено';
  static const errorIdempotency = 'Повтори с тем же client_request_id';
  static const errorProvider = 'Линии временно недоступны';
  static const errorPickRequired = 'Выбери исход';
  static const errorMarketClosed = 'Рынок закрыт';

  static const confirmTitle = 'Подтвердить ставку';

  static String rsv(num value) => '${plain(value)} RSV';

  static String plain(num value) => _trim(value);

  static String odds(num value) => value.toStringAsFixed(2);

  static String previewPayout({required num stake, required num odds}) =>
      rsv(stake * odds);

  static String confirmBody({
    required String outcome,
    required String stake,
    required String odds,
    required String preview,
  }) {
    return 'Исход: $outcome\n'
        'Ставка: $stake RSV\n'
        'Коэффициент: $odds\n'
        'Возможный выигрыш ≈ $preview RSV';
  }

  static String acceptedBody({
    required String odds,
    required String payout,
  }) {
    return 'Принято @ $odds · потенциал $payout RSV';
  }

  static String _trim(num value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(2);
  }
}
