import '../dto/stats_dto.dart';

class EpochStats {
  const EpochStats({
    required this.epochStartedAt,
    required this.baselineEquity,
    this.baselineNote,
    required this.currentEquity,
    required this.equityPnl,
    required this.equityPnlPct,
    required this.realizedPnl,
    required this.unrealizedPnl,
    required this.totalFills,
    required this.buys,
    required this.sells,
    required this.closedTrades,
    required this.wins,
    required this.losses,
    required this.flats,
    required this.winRatePct,
    required this.tracked,
    required this.includesPreEpochExchangeHistory,
    required this.symbol,
    required this.positionOpen,
    this.updatedAt,
  });

  final String epochStartedAt;
  final String baselineEquity;
  final String? baselineNote;
  final String currentEquity;
  final String equityPnl;
  final String equityPnlPct;
  final String realizedPnl;
  final String unrealizedPnl;
  final int totalFills;
  final int buys;
  final int sells;
  final int closedTrades;
  final int wins;
  final int losses;
  final int flats;
  final String winRatePct;
  final bool tracked;
  final bool includesPreEpochExchangeHistory;
  final String symbol;
  final bool positionOpen;
  final String? updatedAt;

  factory EpochStats.fromDto(StatsDto dto) => EpochStats(
        epochStartedAt: dto.epochStartedAt,
        baselineEquity: dto.baselineEquity,
        baselineNote: dto.baselineNote,
        currentEquity: dto.currentEquity,
        equityPnl: dto.equityPnl,
        equityPnlPct: dto.equityPnlPct,
        realizedPnl: dto.realizedPnl,
        unrealizedPnl: dto.unrealizedPnl,
        totalFills: dto.totalFills,
        buys: dto.buys,
        sells: dto.sells,
        closedTrades: dto.closedTrades,
        wins: dto.wins,
        losses: dto.losses,
        flats: dto.flats,
        winRatePct: dto.winRatePct,
        tracked: dto.tracked,
        includesPreEpochExchangeHistory: dto.includesPreEpochExchangeHistory,
        symbol: dto.symbol,
        positionOpen: dto.positionOpen,
        updatedAt: dto.updatedAt,
      );
}
