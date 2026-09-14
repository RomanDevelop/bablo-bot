import '../../../core/constants/casino_constants.dart';
import '../dto/casino_dto.dart';

class CasinoRsvBalance {
  const CasinoRsvBalance({
    this.available = 0,
    this.committedCopy = 0,
    this.totalSpendableField = 0,
    this.note = '',
  });

  final num available;
  final num committedCopy;
  final num totalSpendableField;
  final String note;

  factory CasinoRsvBalance.fromDto(CasinoRsvBalanceDto dto) {
    return CasinoRsvBalance(
      available: dto.available,
      committedCopy: dto.committedCopy,
      totalSpendableField: dto.totalSpendableField,
      note: dto.note,
    );
  }
}

class CasinoDemoBalance {
  const CasinoDemoBalance({
    this.available = 0,
    this.startingCredits = 10000,
  });

  final num available;
  final num startingCredits;

  factory CasinoDemoBalance.fromDto(CasinoDemoBalanceDto dto) {
    return CasinoDemoBalance(
      available: dto.available,
      startingCredits: dto.startingCredits,
    );
  }
}

class CasinoBalance {
  const CasinoBalance({
    this.rsv = const CasinoRsvBalance(),
    this.demo = const CasinoDemoBalance(),
    this.supportedCurrencies = const ['RSV', 'DEMO'],
  });

  final CasinoRsvBalance rsv;
  final CasinoDemoBalance demo;
  final List<String> supportedCurrencies;

  factory CasinoBalance.fromDto(CasinoBalanceDto dto) {
    return CasinoBalance(
      rsv: CasinoRsvBalance.fromDto(dto.rsv),
      demo: CasinoDemoBalance.fromDto(dto.demo),
      supportedCurrencies: dto.supportedCurrencies,
    );
  }

  num availableFor(String currency) {
    final c = currency.toUpperCase();
    if (c == CasinoConstants.currencyRsv) return rsv.available;
    return demo.available;
  }

  CasinoBalance copyWithDemo(num available) {
    return CasinoBalance(
      rsv: rsv,
      demo: CasinoDemoBalance(
        available: available,
        startingCredits: demo.startingCredits,
      ),
      supportedCurrencies: supportedCurrencies,
    );
  }

  CasinoBalance copyWithAvailable({num? rsvAvailable, num? demoAvailable}) {
    return CasinoBalance(
      rsv: CasinoRsvBalance(
        available: rsvAvailable ?? rsv.available,
        committedCopy: rsv.committedCopy,
        totalSpendableField: rsv.totalSpendableField,
        note: rsv.note,
      ),
      demo: CasinoDemoBalance(
        available: demoAvailable ?? demo.available,
        startingCredits: demo.startingCredits,
      ),
      supportedCurrencies: supportedCurrencies,
    );
  }
}

class CasinoGame {
  const CasinoGame({
    required this.gameId,
    this.title = '',
    this.description = '',
    this.gameType = '',
    this.version = '1.0.0',
    this.status = 'ACTIVE',
    this.supportedCurrencies = const ['RSV', 'DEMO'],
    this.minBet = 1,
    this.maxBet = 100,
    this.betSteps = const [1.0, 2.0, 5.0, 10.0, 25.0, 50.0, 100.0],
    this.features = const [],
    this.config,
  });

  final String gameId;
  final String title;
  final String description;
  final String gameType;
  final String version;
  final String status;
  final List<String> supportedCurrencies;
  final num minBet;
  final num maxBet;
  final List<num> betSteps;
  final List<String> features;
  final Map<String, dynamic>? config;

  factory CasinoGame.fromDto(CasinoGameDto dto) {
    return CasinoGame(
      gameId: dto.gameId,
      title: dto.title.isEmpty ? dto.gameId : dto.title,
      description: dto.description,
      gameType: dto.gameType,
      version: dto.version,
      status: dto.status,
      supportedCurrencies: dto.supportedCurrencies,
      minBet: dto.minBet,
      maxBet: dto.maxBet,
      betSteps: dto.betSteps,
      features: dto.features,
      config: dto.config,
    );
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  bool get isClassic =>
      gameType == CasinoConstants.typeClassic ||
      gameId == CasinoConstants.gameClassic;

  bool get isTumble =>
      gameType == CasinoConstants.typeTumble ||
      gameId == CasinoConstants.gameTumble;

  bool get isHoldAndWin =>
      gameType == CasinoConstants.typeHoldAndWin ||
      gameId == CasinoConstants.gameHoldAndWin;

  int get boardRows {
    if (isTumble) return 5;
    if (isHoldAndWin) return 3;
    return 3;
  }

  int get boardCols {
    if (isTumble) return 6;
    if (isHoldAndWin) return 5;
    return 3;
  }

  List<num> get steps =>
      betSteps.isEmpty ? CasinoConstants.defaultBetSteps : betSteps;
}

class CasinoLockedCoin {
  const CasinoLockedCoin({
    required this.row,
    required this.col,
    required this.value,
  });

  final int row;
  final int col;
  final num value;

  factory CasinoLockedCoin.fromDto(CasinoLockedCoinDto dto) {
    return CasinoLockedCoin(row: dto.row, col: dto.col, value: dto.value);
  }
}

class CasinoBonusState {
  const CasinoBonusState({
    this.active = false,
    this.remainingRespins = 0,
    this.lockedCoins = const [],
    this.bet = 0,
    this.accumulated = 0,
  });

  final bool active;
  final int remainingRespins;
  final List<CasinoLockedCoin> lockedCoins;
  final num bet;
  final num accumulated;

  factory CasinoBonusState.fromDto(CasinoBonusStateDto dto) {
    return CasinoBonusState(
      active: dto.active,
      remainingRespins: dto.remainingRespins,
      lockedCoins:
          dto.lockedCoins.map(CasinoLockedCoin.fromDto).toList(growable: false),
      bet: dto.bet,
      accumulated: dto.accumulated,
    );
  }
}

class CasinoSession {
  const CasinoSession({
    required this.id,
    required this.gameId,
    this.gameVersion = '1.0.0',
    this.currency = 'DEMO',
    this.status = 'ACTIVE',
    this.state = const {},
    this.bonusState,
    this.nextAction = 'SPIN',
    this.totalWagered = 0,
    this.totalWon = 0,
    this.startedAt,
    this.updatedAt,
  });

  final String id;
  final String gameId;
  final String gameVersion;
  final String currency;
  final String status;
  final Map<String, dynamic> state;
  final CasinoBonusState? bonusState;
  final String nextAction;
  final num totalWagered;
  final num totalWon;
  final DateTime? startedAt;
  final DateTime? updatedAt;

  factory CasinoSession.fromDto(CasinoSessionDto dto) {
    return CasinoSession(
      id: dto.id,
      gameId: dto.gameId,
      gameVersion: dto.gameVersion,
      currency: dto.currency,
      status: dto.status,
      state: dto.state,
      bonusState: dto.bonusState == null
          ? null
          : CasinoBonusState.fromDto(dto.bonusState!),
      nextAction: dto.nextAction.toUpperCase(),
      totalWagered: dto.totalWagered,
      totalWon: dto.totalWon,
      startedAt: _parseDate(dto.startedAt),
      updatedAt: _parseDate(dto.updatedAt),
    );
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  bool get requiresRespin =>
      nextAction.toUpperCase() == CasinoConstants.actionRespin;

  bool get isBonusMode {
    final mode = (state['mode'] ?? '').toString().toUpperCase();
    return mode == 'BONUS' || (bonusState?.active ?? false);
  }
}

class CasinoWinCombo {
  const CasinoWinCombo({
    this.paylineId,
    this.symbol,
    this.positions = const [],
    this.multiplier = 1,
    this.payout = 0,
  });

  final String? paylineId;
  final String? symbol;
  final List<List<int>> positions;
  final num multiplier;
  final num payout;

  factory CasinoWinCombo.fromDto(CasinoWinComboDto dto) {
    return CasinoWinCombo(
      paylineId: dto.paylineId,
      symbol: dto.symbol,
      positions: dto.positions,
      multiplier: dto.multiplier,
      payout: dto.payout,
    );
  }
}

class CasinoEvent {
  const CasinoEvent({
    required this.type,
    this.data = const {},
  });

  final String type;
  final Map<String, dynamic> data;

  factory CasinoEvent.fromDto(CasinoEventDto dto) {
    return CasinoEvent(type: dto.type.toUpperCase(), data: dto.data);
  }

  List<List<String>>? get boardFromData {
    final raw = data['board'];
    if (raw is! List) return null;
    final rows = <List<String>>[];
    for (final row in raw) {
      if (row is List) {
        rows.add(row.map((e) => e.toString()).toList(growable: false));
      }
    }
    // Empty list must be null — otherwise copyWith replaces a good board with [].
    if (rows.isEmpty) return null;
    return List.unmodifiable(rows);
  }
}

class CasinoSpinResult {
  const CasinoSpinResult({
    required this.spinId,
    required this.sessionId,
    required this.gameId,
    this.gameVersion = '1.0.0',
    this.action = 'SPIN',
    this.bet = 0,
    this.betCharged = 0,
    this.currency = 'DEMO',
    this.balanceBefore = 0,
    this.balanceAfter = 0,
    this.totalWin = 0,
    this.netResult = 0,
    this.board = const [],
    this.winningCombinations = const [],
    this.multiplier = 1,
    this.triggeredFeatures = const [],
    this.bonusState,
    this.nextAction = 'SPIN',
    this.roundComplete = true,
    this.events = const [],
    this.gameSpecific = const {},
    this.clientRequestId,
    this.timestamp,
    this.session,
  });

  final String spinId;
  final String sessionId;
  final String gameId;
  final String gameVersion;
  final String action;
  final num bet;
  final num betCharged;
  final String currency;
  final num balanceBefore;
  final num balanceAfter;
  final num totalWin;
  final num netResult;
  final List<List<String>> board;
  final List<CasinoWinCombo> winningCombinations;
  final num multiplier;
  final List<String> triggeredFeatures;
  final CasinoBonusState? bonusState;
  final String nextAction;
  final bool roundComplete;
  final List<CasinoEvent> events;
  final Map<String, dynamic> gameSpecific;
  final String? clientRequestId;
  final DateTime? timestamp;
  final CasinoSession? session;

  factory CasinoSpinResult.fromDto(CasinoSpinResultDto dto) {
    return CasinoSpinResult(
      spinId: dto.spinId,
      sessionId: dto.sessionId,
      gameId: dto.gameId,
      gameVersion: dto.gameVersion,
      action: dto.action,
      bet: dto.bet,
      betCharged: dto.betCharged,
      currency: dto.currency,
      balanceBefore: dto.balanceBefore,
      balanceAfter: dto.balanceAfter,
      totalWin: dto.totalWin,
      netResult: dto.netResult,
      board: dto.board,
      winningCombinations: dto.winningCombinations
          .map(CasinoWinCombo.fromDto)
          .toList(growable: false),
      multiplier: dto.multiplier,
      triggeredFeatures: dto.triggeredFeatures,
      bonusState: dto.bonusState == null
          ? null
          : CasinoBonusState.fromDto(dto.bonusState!),
      nextAction: dto.nextAction.toUpperCase(),
      roundComplete: dto.roundComplete,
      events: dto.events.map(CasinoEvent.fromDto).toList(growable: false),
      gameSpecific: dto.gameSpecific,
      clientRequestId: dto.clientRequestId,
      timestamp: _parseDate(dto.timestamp),
      session:
          dto.session == null ? null : CasinoSession.fromDto(dto.session!),
    );
  }

  bool get hasWin => totalWin > 0;
}

class CasinoHistoryItem {
  const CasinoHistoryItem({
    this.spinId,
    this.gameId,
    this.action,
    this.bet,
    this.totalWin,
    this.currency,
    this.status,
    this.createdAt,
  });

  final String? spinId;
  final String? gameId;
  final String? action;
  final num? bet;
  final num? totalWin;
  final String? currency;
  final String? status;
  final DateTime? createdAt;

  factory CasinoHistoryItem.fromDto(CasinoHistoryItemDto dto) {
    return CasinoHistoryItem(
      spinId: dto.spinId,
      gameId: dto.gameId,
      action: dto.action,
      bet: dto.bet,
      totalWin: dto.totalWin,
      currency: dto.currency,
      status: dto.status,
      createdAt: _parseDate(dto.createdAt),
    );
  }

  bool get isWin => (totalWin ?? 0) > 0;
}

class CasinoStats {
  const CasinoStats({
    this.totalSpins = 0,
    this.totalWagered = 0,
    this.totalWon = 0,
    this.netResult = 0,
  });

  final num totalSpins;
  final num totalWagered;
  final num totalWon;
  final num netResult;

  factory CasinoStats.fromDto(CasinoStatsDto dto) {
    return CasinoStats(
      totalSpins: dto.totalSpins,
      totalWagered: dto.totalWagered,
      totalWon: dto.totalWon,
      netResult: dto.netResult,
    );
  }
}

class CasinoStatus {
  const CasinoStatus({
    this.eligible = true,
    this.plan = 'FREE',
    this.balance,
    this.games = const [],
    this.activeSession,
    this.disclaimer = '',
  });

  final bool eligible;
  final String plan;
  final CasinoBalance? balance;
  final List<CasinoGame> games;
  final CasinoSession? activeSession;
  final String disclaimer;

  factory CasinoStatus.fromDto(CasinoStatusDto dto) {
    return CasinoStatus(
      eligible: dto.eligible,
      plan: dto.plan,
      balance:
          dto.balance == null ? null : CasinoBalance.fromDto(dto.balance!),
      games: dto.games.map(CasinoGame.fromDto).toList(growable: false),
      activeSession: dto.activeSession == null
          ? null
          : CasinoSession.fromDto(dto.activeSession!),
      disclaimer: dto.disclaimer,
    );
  }

  List<CasinoGame> get activeGames =>
      games.where((g) => g.isActive).toList(growable: false);
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}
