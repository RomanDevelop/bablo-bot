import '../../../core/utils/json_parsers.dart';

class CasinoRsvBalanceDto {
  const CasinoRsvBalanceDto({
    this.available = 0,
    this.committedCopy = 0,
    this.totalSpendableField = 0,
    this.note = '',
  });

  final num available;
  final num committedCopy;
  final num totalSpendableField;
  final String note;

  factory CasinoRsvBalanceDto.fromJson(Map<String, dynamic> json) {
    return CasinoRsvBalanceDto(
      available: asNum(json['available']),
      committedCopy: asNum(json['committed_copy']),
      totalSpendableField: asNum(json['total_spendable_field']),
      note: asString(json['note'], ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'available': available,
        'committed_copy': committedCopy,
        'total_spendable_field': totalSpendableField,
        'note': note,
      };
}

class CasinoDemoBalanceDto {
  const CasinoDemoBalanceDto({
    this.available = 0,
    this.startingCredits = 10000,
  });

  final num available;
  final num startingCredits;

  factory CasinoDemoBalanceDto.fromJson(Map<String, dynamic> json) {
    return CasinoDemoBalanceDto(
      available: asNum(json['available']),
      startingCredits: asNum(json['starting_credits'], 10000),
    );
  }

  Map<String, dynamic> toJson() => {
        'available': available,
        'starting_credits': startingCredits,
      };
}

class CasinoBalanceDto {
  const CasinoBalanceDto({
    this.rsv = const CasinoRsvBalanceDto(),
    this.demo = const CasinoDemoBalanceDto(),
    this.supportedCurrencies = const ['RSV', 'DEMO'],
  });

  final CasinoRsvBalanceDto rsv;
  final CasinoDemoBalanceDto demo;
  final List<String> supportedCurrencies;

  factory CasinoBalanceDto.fromJson(Map<String, dynamic> json) {
    return CasinoBalanceDto(
      rsv: CasinoRsvBalanceDto.fromJson(asMap(json['rsv'])),
      demo: CasinoDemoBalanceDto.fromJson(asMap(json['demo'])),
      supportedCurrencies: _stringList(
        json['supported_currencies'],
        fallback: const ['RSV', 'DEMO'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'rsv': rsv.toJson(),
        'demo': demo.toJson(),
        'supported_currencies': supportedCurrencies,
      };
}

class CasinoGameDto {
  const CasinoGameDto({
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

  factory CasinoGameDto.fromJson(Map<String, dynamic> json) {
    final stepsRaw = json['bet_steps'];
    final steps = <num>[];
    if (stepsRaw is List) {
      for (final e in stepsRaw) {
        steps.add(asNum(e));
      }
    }
    return CasinoGameDto(
      gameId: asString(json['game_id'], ''),
      title: asString(json['title'], asString(json['game_id'], 'Game')),
      description: asString(json['description'], ''),
      gameType: asString(json['game_type'], ''),
      version: asString(json['version'], '1.0.0'),
      status: asString(json['status'], 'ACTIVE'),
      supportedCurrencies: _stringList(
        json['supported_currencies'],
        fallback: const ['RSV', 'DEMO'],
      ),
      minBet: asNum(json['min_bet'], 1),
      maxBet: asNum(json['max_bet'], 100),
      betSteps: steps.isEmpty
          ? const [1.0, 2.0, 5.0, 10.0, 25.0, 50.0, 100.0]
          : List<num>.unmodifiable(steps),
      features: _stringList(json['features']),
      config: json['config'] is Map ? asMap(json['config']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'game_id': gameId,
        'title': title,
        'description': description,
        'game_type': gameType,
        'version': version,
        'status': status,
        'supported_currencies': supportedCurrencies,
        'min_bet': minBet,
        'max_bet': maxBet,
        'bet_steps': betSteps,
        'features': features,
        'config': config,
      };
}

class CasinoLockedCoinDto {
  const CasinoLockedCoinDto({
    required this.row,
    required this.col,
    required this.value,
  });

  final int row;
  final int col;
  final num value;

  factory CasinoLockedCoinDto.fromJson(Map<String, dynamic> json) {
    return CasinoLockedCoinDto(
      row: asInt(json['row']),
      col: asInt(json['col']),
      value: asNum(json['value']),
    );
  }

  Map<String, dynamic> toJson() => {
        'row': row,
        'col': col,
        'value': value,
      };
}

class CasinoBonusStateDto {
  const CasinoBonusStateDto({
    this.active = false,
    this.remainingRespins = 0,
    this.lockedCoins = const [],
    this.bet = 0,
    this.accumulated = 0,
  });

  final bool active;
  final int remainingRespins;
  final List<CasinoLockedCoinDto> lockedCoins;
  final num bet;
  final num accumulated;

  factory CasinoBonusStateDto.fromJson(Map<String, dynamic> json) {
    final coinsRaw = json['locked_coins'];
    final coins = <CasinoLockedCoinDto>[];
    if (coinsRaw is List) {
      for (final e in coinsRaw) {
        coins.add(CasinoLockedCoinDto.fromJson(asMap(e)));
      }
    }
    return CasinoBonusStateDto(
      active: asBool(json['active']),
      remainingRespins: asInt(json['remaining_respins']),
      lockedCoins: List.unmodifiable(coins),
      bet: asNum(json['bet']),
      accumulated: asNum(json['accumulated']),
    );
  }

  Map<String, dynamic> toJson() => {
        'active': active,
        'remaining_respins': remainingRespins,
        'locked_coins': lockedCoins.map((e) => e.toJson()).toList(),
        'bet': bet,
        'accumulated': accumulated,
      };
}

class CasinoSessionDto {
  const CasinoSessionDto({
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
  final CasinoBonusStateDto? bonusState;
  final String nextAction;
  final num totalWagered;
  final num totalWon;
  final String? startedAt;
  final String? updatedAt;

  factory CasinoSessionDto.fromJson(Map<String, dynamic> json) {
    final bonusRaw = json['bonus_state'];
    CasinoBonusStateDto? bonus;
    if (bonusRaw is Map) {
      bonus = CasinoBonusStateDto.fromJson(asMap(bonusRaw));
    } else {
      final stateBonus = asMap(json['state'])['bonus'];
      if (stateBonus is Map) {
        bonus = CasinoBonusStateDto.fromJson(asMap(stateBonus));
      }
    }
    final state = asMap(json['state']);
    final next = asString(
      json['next_action'] ?? state['next_action'],
      'SPIN',
    );
    return CasinoSessionDto(
      id: asString(json['id'] ?? json['session_id'], ''),
      gameId: asString(json['game_id'], ''),
      gameVersion: asString(json['game_version'], '1.0.0'),
      currency: asString(json['currency'], 'DEMO'),
      status: asString(json['status'], 'ACTIVE'),
      state: state,
      bonusState: bonus,
      nextAction: next,
      totalWagered: asNum(json['total_wagered']),
      totalWon: asNum(json['total_won']),
      startedAt: asNullableString(json['started_at']),
      updatedAt: asNullableString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'game_id': gameId,
        'game_version': gameVersion,
        'currency': currency,
        'status': status,
        'state': state,
        'bonus_state': bonusState?.toJson(),
        'next_action': nextAction,
        'total_wagered': totalWagered,
        'total_won': totalWon,
        'started_at': startedAt,
        'updated_at': updatedAt,
      };
}

class CasinoWinComboDto {
  const CasinoWinComboDto({
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

  factory CasinoWinComboDto.fromJson(Map<String, dynamic> json) {
    final positions = <List<int>>[];
    final raw = json['positions'];
    if (raw is List) {
      for (final p in raw) {
        if (p is List && p.length >= 2) {
          positions.add([asInt(p[0]), asInt(p[1])]);
        }
      }
    }
    return CasinoWinComboDto(
      paylineId: asNullableString(json['payline_id']),
      symbol: asNullableString(json['symbol']),
      positions: List.unmodifiable(positions),
      multiplier: asNum(json['multiplier'], 1),
      payout: asNum(json['payout']),
    );
  }
}

class CasinoEventDto {
  const CasinoEventDto({
    required this.type,
    this.data = const {},
  });

  final String type;
  final Map<String, dynamic> data;

  factory CasinoEventDto.fromJson(Map<String, dynamic> json) {
    return CasinoEventDto(
      type: asString(json['type'], ''),
      data: asMap(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
      };
}

class CasinoSpinResultDto {
  const CasinoSpinResultDto({
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
  final List<CasinoWinComboDto> winningCombinations;
  final num multiplier;
  final List<String> triggeredFeatures;
  final CasinoBonusStateDto? bonusState;
  final String nextAction;
  final bool roundComplete;
  final List<CasinoEventDto> events;
  final Map<String, dynamic> gameSpecific;
  final String? clientRequestId;
  final String? timestamp;
  final CasinoSessionDto? session;

  factory CasinoSpinResultDto.fromJson(Map<String, dynamic> json) {
    final events = <CasinoEventDto>[];
    final eventsRaw = json['events'];
    if (eventsRaw is List) {
      for (final e in eventsRaw) {
        events.add(CasinoEventDto.fromJson(asMap(e)));
      }
    }
    final combos = <CasinoWinComboDto>[];
    final combosRaw = json['winning_combinations'];
    if (combosRaw is List) {
      for (final e in combosRaw) {
        combos.add(CasinoWinComboDto.fromJson(asMap(e)));
      }
    }
    final bonusRaw = json['bonus_state'];
    final sessionRaw = json['session'];
    return CasinoSpinResultDto(
      spinId: asString(json['spin_id'], ''),
      sessionId: asString(json['session_id'], ''),
      gameId: asString(json['game_id'], ''),
      gameVersion: asString(json['game_version'], '1.0.0'),
      action: asString(json['action'], 'SPIN'),
      bet: asNum(json['bet']),
      betCharged: asNum(json['bet_charged']),
      currency: asString(json['currency'], 'DEMO'),
      balanceBefore: asNum(json['balance_before']),
      balanceAfter: asNum(json['balance_after']),
      totalWin: asNum(json['total_win']),
      netResult: asNum(json['net_result']),
      board: _parseBoard(json['board']),
      winningCombinations: List.unmodifiable(combos),
      multiplier: asNum(json['multiplier'], 1),
      triggeredFeatures: _stringList(json['triggered_features']),
      bonusState: bonusRaw is Map
          ? CasinoBonusStateDto.fromJson(asMap(bonusRaw))
          : null,
      nextAction: asString(json['next_action'], 'SPIN'),
      roundComplete: json['round_complete'] == null
          ? true
          : asBool(json['round_complete']),
      events: List.unmodifiable(events),
      gameSpecific: asMap(json['game_specific']),
      clientRequestId: asNullableString(json['client_request_id']),
      timestamp: asNullableString(json['timestamp']),
      session: sessionRaw is Map
          ? CasinoSessionDto.fromJson(asMap(sessionRaw))
          : null,
    );
  }
}

class CasinoHistoryItemDto {
  const CasinoHistoryItemDto({
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
  final String? createdAt;

  factory CasinoHistoryItemDto.fromJson(Map<String, dynamic> json) {
    return CasinoHistoryItemDto(
      spinId: asNullableString(json['spin_id'] ?? json['id']),
      gameId: asNullableString(json['game_id']),
      action: asNullableString(json['action']),
      bet: json['bet'] == null ? null : asNum(json['bet']),
      totalWin: json['total_win'] == null
          ? (json['win'] == null ? null : asNum(json['win']))
          : asNum(json['total_win']),
      currency: asNullableString(json['currency']),
      status: asNullableString(json['status']),
      createdAt: asNullableString(
        json['created_at'] ?? json['timestamp'] ?? json['at'],
      ),
    );
  }
}

class CasinoStatsDto {
  const CasinoStatsDto({
    this.totalSpins = 0,
    this.totalWagered = 0,
    this.totalWon = 0,
    this.netResult = 0,
    this.raw = const {},
  });

  final num totalSpins;
  final num totalWagered;
  final num totalWon;
  final num netResult;
  final Map<String, dynamic> raw;

  factory CasinoStatsDto.fromJson(Map<String, dynamic> json) {
    return CasinoStatsDto(
      totalSpins: asNum(json['total_spins'] ?? json['spins']),
      totalWagered: asNum(json['total_wagered'] ?? json['wagered']),
      totalWon: asNum(json['total_won'] ?? json['won']),
      netResult: asNum(json['net_result'] ?? json['net']),
      raw: json,
    );
  }
}

class CasinoStatusDto {
  const CasinoStatusDto({
    this.eligible = true,
    this.plan = 'FREE',
    this.balance,
    this.games = const [],
    this.activeSession,
    this.disclaimer = '',
  });

  final bool eligible;
  final String plan;
  final CasinoBalanceDto? balance;
  final List<CasinoGameDto> games;
  final CasinoSessionDto? activeSession;
  final String disclaimer;

  factory CasinoStatusDto.fromJson(Map<String, dynamic> json) {
    final games = <CasinoGameDto>[];
    final gamesRaw = json['games'] ?? json['items'];
    if (gamesRaw is List) {
      for (final e in gamesRaw) {
        games.add(CasinoGameDto.fromJson(asMap(e)));
      }
    }
    final balanceRaw = json['balance'] ?? json['balances'];
    final sessionRaw =
        json['active_session'] ?? json['session'] ?? json['activeSession'];
    return CasinoStatusDto(
      eligible: json['eligible'] == null ? true : asBool(json['eligible']),
      plan: asString(json['plan'], 'FREE'),
      balance: balanceRaw is Map
          ? CasinoBalanceDto.fromJson(asMap(balanceRaw))
          : (json['rsv'] is Map || json['demo'] is Map
              ? CasinoBalanceDto.fromJson(json)
              : null),
      games: List.unmodifiable(games),
      activeSession:
          sessionRaw is Map ? CasinoSessionDto.fromJson(asMap(sessionRaw)) : null,
      disclaimer: asString(json['disclaimer'], ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'eligible': eligible,
        'plan': plan,
        'balance': balance?.toJson(),
        'games': games.map((e) => e.toJson()).toList(),
        'active_session': activeSession?.toJson(),
        'disclaimer': disclaimer,
      };
}

List<String> _stringList(dynamic value, {List<String> fallback = const []}) {
  if (value is! List) return fallback;
  return value.map((e) => e.toString()).toList(growable: false);
}

List<List<String>> _parseBoard(dynamic raw) {
  if (raw is! List) return const [];
  final rows = <List<String>>[];
  for (final row in raw) {
    if (row is List) {
      rows.add(row.map((e) => e.toString()).toList(growable: false));
    }
  }
  return List.unmodifiable(rows);
}
