import '../../../core/constants/copy_constants.dart';
import '../dto/copy_dto.dart';

class CopyStake {
  const CopyStake({
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
  final DateTime? startedAt;
  final DateTime? endsAt;
  final int secondsRemaining;
  final bool canComplete;
  final bool canEarlyExit;

  factory CopyStake.fromDto(CopyStakeDto dto) {
    return CopyStake(
      id: dto.id,
      status: dto.status,
      lockedRsv: dto.lockedRsv,
      equityRsv: dto.equityRsv,
      pnlRsv: dto.pnlRsv,
      poolShare: dto.poolShare,
      startedAt: _parseDate(dto.startedAt),
      endsAt: _parseDate(dto.endsAt),
      secondsRemaining: dto.secondsRemaining,
      canComplete: dto.canComplete,
      canEarlyExit: dto.canEarlyExit,
    );
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  bool get pnlPositive => pnlRsv > 0;

  bool get pnlNegative => pnlRsv < 0;

  String get poolShareLabel => CopyConstants.poolSharePct(poolShare);

  int get remainingSeconds {
    if (secondsRemaining > 0) return secondsRemaining;
    final end = endsAt;
    if (end == null) return 0;
    final diff = end.difference(DateTime.now()).inSeconds;
    return diff < 0 ? 0 : diff;
  }
}

class CopyStatus {
  const CopyStatus({
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
  final CopyStake? stake;

  factory CopyStatus.fromDto(CopyStatusDto dto) {
    return CopyStatus(
      eligible: dto.eligible,
      plan: dto.plan,
      minStakeRsv: dto.minStakeRsv,
      lockDays: dto.lockDays,
      earlyExitPenaltyPct: dto.earlyExitPenaltyPct,
      disclaimer: dto.disclaimer,
      availableEarnedRsv: dto.availableEarnedRsv,
      poolEquityRsv: dto.poolEquityRsv,
      stake: dto.stake == null ? null : CopyStake.fromDto(dto.stake!),
    );
  }

  bool get isActive => stake != null;

  bool get canEnable =>
      !isActive && availableEarnedRsv >= minStakeRsv;

  num get maxStakeAmount => availableEarnedRsv;

  String get disclaimerText =>
      disclaimer.trim().isEmpty ? CopyConstants.fallbackDisclaimer : disclaimer;

  num estimatedPenalty(num equity) =>
      equity * earlyExitPenaltyPct / 100;
}

class CopyHistoryItem {
  const CopyHistoryItem({
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
  final DateTime? createdAt;

  factory CopyHistoryItem.fromDto(CopyHistoryItemDto dto) {
    return CopyHistoryItem(
      id: dto.id,
      symbol: dto.symbol,
      action: dto.action,
      deltaRsv: dto.deltaRsv,
      masterPnlPct: dto.masterPnlPct,
      createdAt: _parseDate(dto.createdAt),
    );
  }

  bool get isBuy {
    final a = action.toUpperCase();
    return a.contains('BUY') || a.contains('LONG') || a == 'OPEN';
  }

  bool get isSell {
    final a = action.toUpperCase();
    return a.contains('SELL') || a.contains('SHORT') || a.contains('CLOSE');
  }

  bool get deltaPositive => deltaRsv > 0;

  bool get deltaNegative => deltaRsv < 0;
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}
