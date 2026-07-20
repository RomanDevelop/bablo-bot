import '../../../core/utils/json_parsers.dart';

class StatsDto {
  const StatsDto({
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
    this.lastTradeAt,
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
  final String? lastTradeAt;
  final String? updatedAt;

  factory StatsDto.fromJson(Map<String, dynamic> json) {
    return StatsDto(
      epochStartedAt: asString(json['epoch_started_at'], ''),
      baselineEquity: asString(json['baseline_equity']),
      baselineNote: asNullableString(json['baseline_note']),
      currentEquity: asString(json['current_equity']),
      equityPnl: asString(json['equity_pnl']),
      equityPnlPct: asString(json['equity_pnl_pct']),
      realizedPnl: asString(json['realized_pnl']),
      unrealizedPnl: asString(json['unrealized_pnl']),
      totalFills: asInt(json['total_fills']),
      buys: asInt(json['buys']),
      sells: asInt(json['sells']),
      closedTrades: asInt(json['closed_trades']),
      wins: asInt(json['wins']),
      losses: asInt(json['losses']),
      flats: asInt(json['flats']),
      winRatePct: asString(json['win_rate_pct']),
      tracked: asBool(json['tracked'], true),
      includesPreEpochExchangeHistory:
          asBool(json['includes_pre_epoch_exchange_history']),
      symbol: asString(json['symbol'], '—'),
      positionOpen: asBool(json['position_open']),
      lastTradeAt: asNullableString(json['last_trade_at']),
      updatedAt: asNullableString(json['updated_at']),
    );
  }
}
