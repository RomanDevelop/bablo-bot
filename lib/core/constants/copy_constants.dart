/// Copy Pool — virtual copy-trading of the master bot (off-chain API).
class CopyConstants {
  CopyConstants._();

  static const permission = 'USE_COPY_TRADING';

  static const title = 'COPY TRADING';
  static const subtitle = 'Копирование бота';
  static const intro =
      'PREMIUM+ может залочить Earned RSV на 30 дней и виртуально копировать '
      'сделки master-бота Bablo. Это не реальный Binance-счёт: PnL крутит '
      'equity стейка.';

  static const notBinance = 'Виртуально · не Binance';
  static const fallbackDisclaimer =
      'Виртуальное копирование сделок master-бота. Средства не выводятся '
      'на биржу. Досрочный выход уменьшает equity на штраф.';

  static const connectCta = 'Подключить';
  static const topupCta = 'Докинуть RSV';
  static const exitCta = 'Досрочный выход';
  static const completeCta = 'Завершить';
  static const acceptDisclaimer = 'Принимаю условия';
  static const availableLabel = 'Доступно Earned RSV';
  static const amountLabel = 'Сумма стейка';
  static const historyTitle = 'История зеркал';
  static const historyEmpty = 'Зеркальных сделок пока нет';
  static const topupHint = 'Срок лока не продлевается';
  static const needAuth = 'Войдите в профиль, чтобы подключить копирование';
  static const premiumTitle = 'Доступно с PREMIUM';
  static const premiumBody =
      'Копирование бота открывается на тарифе PREMIUM и выше.';
  static const premiumCta = 'Оформить Premium';
  static const insufficientForMin = 'Недостаточно Earned RSV для минимума';
  static const topupTitle = 'Докинуть RSV';
  static const topupBody = 'Срок лока не сдвигается. Сумма списывается с Earned RSV.';
  static const exitTitle = 'Досрочный выход';
  static const cancel = 'Отмена';
  static const confirm = 'Подтвердить';
  static const virtualBadge = 'VIRTUAL';

  static const errorPlanRequired = 'Нужна подписка PREMIUM';
  static const errorDisclaimer = 'Прими условия';
  static const errorMinStake = 'Минимум 500 RSV';
  static const errorInsufficient = 'Недостаточно Earned RSV';
  static const errorAlreadyActive = 'Уже подключено';
  static const errorNoStake = 'Нет активного копирования';
  static const errorLockActive =
      'Срок ещё не истёк — досрочный выход или жди';

  static String exitConfirmBody({
    required String penaltyPct,
    required String equity,
    required String burned,
  }) {
    return 'Сгорит $penaltyPct% от equity ($equity RSV) ≈ $burned RSV. '
        'Остаток вернётся в Earned RSV.';
  }

  static String minRule(num value) => 'Мин. ${_trim(value)} RSV';
  static String lockRule(int days) => 'Лок $days дней';
  static String penaltyRule(num pct) => 'Штраф −${_trim(pct)}%';

  static String rsv(num value) => '${plain(value)} RSV';

  static String plain(num value) => _trim(value);

  static String poolSharePct(num share) {
    final pct = share <= 1 ? share * 100 : share;
    return '${pct.toStringAsFixed(2)}%';
  }

  static String countdown(int seconds) {
    if (seconds <= 0) return 'Срок истёк';
    final d = seconds ~/ 86400;
    final h = (seconds % 86400) ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (d > 0) return '${d}д ${h}ч ${m}м';
    if (h > 0) return '${h}ч ${m}м ${s}с';
    if (m > 0) return '${m}м ${s}с';
    return '${s}с';
  }

  static String _trim(num value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(2);
  }
}
