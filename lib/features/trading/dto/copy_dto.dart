import '../../../core/utils/json_parsers.dart';

class CopyStakeDto {
  const CopyStakeDto({
    required this.id,
    required this.status,
    required this.lockedRsv,
    required this.equityRsv,
    required this.pnlRsv,
    required this.poolShare,
    this.startedAt,
    this.endsAt,
    this.secondsRemaining = 0,
    this.canComplete = false,
    this.canEarlyExit = true,
  });

  final String id;
  final String status;
  final num lockedRsv;
  final num equityRsv;
  final num pnlRsv;
  final num poolShare;
  final String? startedAt;
  final String? endsAt;
  final int secondsRemaining;
  final bool canComplete;
  final bool canEarlyExit;

  factory CopyStakeDto.fromJson(Map<String, dynamic> json) {
    return CopyStakeDto(
      id: asString(json['id'], ''),
      status: asString(json['status'], 'ACTIVE'),
      lockedRsv: asNum(json['locked_rsv']),
      equityRsv: asNum(json['equity_rsv']),
      pnlRsv: asNum(json['pnl_rsv']),
      poolShare: asNum(json['pool_share']),
      startedAt: asNullableString(json['started_at']),
      endsAt: asNullableString(json['ends_at']),
      secondsRemaining: asInt(json['seconds_remaining']),
      canComplete: asBool(json['can_complete']),
      canEarlyExit: json['can_early_exit'] == null
          ? true
          : asBool(json['can_early_exit']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'locked_rsv': lockedRsv,
        'equity_rsv': equityRsv,
        'pnl_rsv': pnlRsv,
        'pool_share': poolShare,
        'started_at': startedAt,
        'ends_at': endsAt,
        'seconds_remaining': secondsRemaining,
        'can_complete': canComplete,
        'can_early_exit': canEarlyExit,
      };
}

class CopyStatusDto {
  const CopyStatusDto({
    this.eligible = false,
    this.plan = 'FREE',
    this.minStakeRsv = 500,
    this.lockDays = 30,
    this.earlyExitPenaltyPct = 14,
    this.disclaimer = '',
    this.availableEarnedRsv = 0,
    this.poolEquityRsv = 0,
    this.stake,
  });

  final bool eligible;
  final String plan;
  final num minStakeRsv;
  final int lockDays;
  final num earlyExitPenaltyPct;
  final String disclaimer;
  final num availableEarnedRsv;
  final num poolEquityRsv;
  final CopyStakeDto? stake;

  factory CopyStatusDto.fromJson(Map<String, dynamic> json) {
    final stakeRaw = json['stake'];
    return CopyStatusDto(
      eligible: asBool(json['eligible']),
      plan: asString(json['plan'], 'FREE'),
      minStakeRsv: asNum(json['min_stake_rsv'], 500),
      lockDays: asInt(json['lock_days'], 30),
      earlyExitPenaltyPct: asNum(json['early_exit_penalty_pct'], 14),
      disclaimer: asString(json['disclaimer'], ''),
      availableEarnedRsv: asNum(json['available_earned_rsv']),
      poolEquityRsv: asNum(json['pool_equity_rsv']),
      stake: stakeRaw == null || stakeRaw is! Map
          ? null
          : CopyStakeDto.fromJson(asMap(stakeRaw)),
    );
  }

  Map<String, dynamic> toJson() => {
        'eligible': eligible,
        'plan': plan,
        'min_stake_rsv': minStakeRsv,
        'lock_days': lockDays,
        'early_exit_penalty_pct': earlyExitPenaltyPct,
        'disclaimer': disclaimer,
        'available_earned_rsv': availableEarnedRsv,
        'pool_equity_rsv': poolEquityRsv,
        'stake': stake?.toJson(),
      };
}

class CopyHistoryItemDto {
  const CopyHistoryItemDto({
    required this.symbol,
    required this.action,
    required this.deltaRsv,
    this.masterPnlPct,
    this.createdAt,
    this.id,
  });

  final String? id;
  final String symbol;
  final String action;
  final num deltaRsv;
  final num? masterPnlPct;
  final String? createdAt;

  factory CopyHistoryItemDto.fromJson(Map<String, dynamic> json) {
    final pnl = json['master_pnl_pct'] ?? json['pnl_pct'];
    return CopyHistoryItemDto(
      id: asNullableString(json['id']),
      symbol: asString(json['symbol'], '—'),
      action: asString(json['action'] ?? json['side'], ''),
      deltaRsv: asNum(json['delta_rsv'] ?? json['rsv_delta']),
      masterPnlPct: pnl == null ? null : asNum(pnl),
      createdAt: asNullableString(
        json['created_at'] ?? json['timestamp'] ?? json['date'] ?? json['at'],
      ),
    );
  }
}
