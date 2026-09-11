/// Bablo Community Casino — client-side copy & paths (server is source of truth).
class CasinoConstants {
  CasinoConstants._();

  static const permission = 'USE_CASINO';

  static const title = 'CASINO';
  static const subtitle = 'Bablo Casino';
  static const intro =
      'Слоты Bablo Community. Математика и RNG на сервере — клиент только '
      'проигрывает events. По умолчанию Demo Credits; RSV — тот же available, '
      'что после Copy lock.';

  static const needAuth = 'Войдите в профиль, чтобы открыть Casino';
  static const premiumTitle = 'Нужен доступ Casino';
  static const premiumBody =
      'Казино открывается при наличии права USE_CASINO на тарифе.';
  static const premiumCta = 'Оформить Premium';

  static const availableRsv = 'Available RSV';
  static const inCopy = 'In Copy';
  static const demoCredits = 'Demo Credits';
  static const currencyDemo = 'DEMO';
  static const currencyRsv = 'RSV';
  static const gamesTitle = 'Игры';
  static const historyTitle = 'История спинов';
  static const historyEmpty = 'Спинов пока нет';
  static const statsTitle = 'Статистика';
  static const resetDemo = 'Сбросить Demo';
  static const spinCta = 'Spin';
  static const respinCta = 'Respin';
  static const retryCta = 'Retry';
  static const betLabel = 'Ставка';
  static const turboLabel = 'Turbo';
  static const balanceStripHint =
      'Casino тратит только Available RSV. Locked в Copy недоступны.';
  static const rsvConfirmTitle = 'Ставка RSV';
  static const demoBadge = 'DEMO';
  static const symbolNotWallet =
      'RSV Coin на поле — игровой символ, не зачисление на wallet.';

  static const errorPlanRequired = 'Нужна подписка / право USE_CASINO';
  static const errorInsufficient =
      'Недостаточно available баланса. Попробуй Demo или дождись unlock Copy.';
  static const errorInvalidBet = 'Ставка вне bet_steps';
  static const errorGame = 'Игра недоступна — обнови список';
  static const errorSession = 'Сессия неактивна — начнём заново';
  static const errorBonusRespin = 'Во время bonus нужен Respin';
  static const errorIdempotency = 'Повтори с тем же client_request_id';
  static const errorForcedDisabled = 'Forced scenarios выключены на сервере';

  static const gameClassic = 'bablo_classic';
  static const gameTumble = 'bablo_tumble';
  static const gameHoldAndWin = 'rsv_hold_and_win';

  static const typeClassic = 'CLASSIC_SLOT';
  static const typeTumble = 'TUMBLE_SLOT';
  static const typeHoldAndWin = 'HOLD_AND_WIN';

  static const actionSpin = 'SPIN';
  static const actionRespin = 'RESPIN';

  static const eventSpinStarted = 'SPIN_STARTED';
  static const eventBetAccepted = 'BET_ACCEPTED';
  static const eventBoardGenerated = 'BOARD_GENERATED';
  static const eventWinDetected = 'WIN_DETECTED';
  static const eventNoWin = 'NO_WIN';
  static const eventCascadeStarted = 'CASCADE_STARTED';
  static const eventSymbolsRemoved = 'SYMBOLS_REMOVED';
  static const eventNewSymbolsDropped = 'NEW_SYMBOLS_DROPPED';
  static const eventMultiplierChanged = 'MULTIPLIER_CHANGED';
  static const eventBonusTriggered = 'BONUS_TRIGGERED';
  static const eventRespinStarted = 'RESPIN_STARTED';
  static const eventCoinLocked = 'COIN_LOCKED';
  static const eventRespinsReset = 'RESPINS_RESET';
  static const eventBonusCompleted = 'BONUS_COMPLETED';
  static const eventWinCredited = 'WIN_CREDITED';
  static const eventSpinCompleted = 'SPIN_COMPLETED';

  static const defaultBetSteps = <double>[1, 2, 5, 10, 25, 50, 100];
  static const demoStarting = 10000.0;

  static String amount(num value, {String suffix = ''}) {
    final body = _trim(value);
    return suffix.isEmpty ? body : '$body $suffix';
  }

  static String rsv(num value) => '${_trim(value)} RSV';

  static String demo(num value) => '${_trim(value)} Demo';

  static String netResult(num value) {
    final sign = value > 0 ? '+' : '';
    return '$sign${_trim(value)}';
  }

  static String rsvConfirmBody({
    required String available,
    required String committed,
    required String bet,
  }) {
    return 'Available: $available RSV\n'
        'In Copy (недоступно): $committed RSV\n\n'
        'Ставка: $bet RSV';
  }

  static String _trim(num value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(2);
  }
}
