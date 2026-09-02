import '../../../core/utils/json_parsers.dart';

class BacktestConfigDto {
  const BacktestConfigDto({
    required this.minDays,
    required this.maxDays,
    required this.dayPresets,
    required this.strategyLabel,
    required this.interval,
    this.stopLossNote,
    this.takeProfitNote,
  });

  final int minDays;
  final int maxDays;
  final List<int> dayPresets;
  final String strategyLabel;
  final String interval;
  final String? stopLossNote;
  final String? takeProfitNote;

  factory BacktestConfigDto.fromJson(Map<String, dynamic> json) {
    final limits = asMap(json['limits'] ?? json);
    final presets = asList(json['day_presets'] ?? json['presets']);
    final presetInts = presets.isEmpty
        ? const [30, 90, 180]
        : presets.map((e) => asInt(e)).where((d) => d > 0).toList();

    return BacktestConfigDto(
      minDays: asInt(limits['min_days'] ?? json['min_days'], 7),
      maxDays: asInt(limits['max_days'] ?? json['max_days'], 365),
      dayPresets: presetInts.isEmpty ? const [30, 90, 180] : presetInts,
      strategyLabel: asString(
        json['strategy'] ?? json['strategy_label'] ?? json['mode'],
        'Alligator H1',
      ),
      interval: asString(json['interval'], '1h'),
      stopLossNote: asNullableString(json['stop_loss'] ?? json['sl_note']),
      takeProfitNote: asNullableString(json['take_profit'] ?? json['tp_note']),
    );
  }
}

class BacktestRunDto {
  const BacktestRunDto({
    required this.symbol,
    required this.days,
    required this.summary,
    required this.trades,
  });

  final String symbol;
  final int days;
  final BacktestSummaryDto summary;
  final List<BacktestTradeDto> trades;

  factory BacktestRunDto.fromJson(Map<String, dynamic> json) {
    final summaryRaw = asMap(json['summary'] ?? json);
    final tradesRaw = asList(json['trades'] ?? json['fills']);

    return BacktestRunDto(
      symbol: asString(json['symbol'] ?? summaryRaw['symbol']),
      days: asInt(json['days'] ?? summaryRaw['days'], 90),
      summary: BacktestSummaryDto.fromJson(summaryRaw),
      trades: tradesRaw
          .map((e) => BacktestTradeDto.fromJson(asMap(e)))
          .toList(growable: false),
    );
  }
}

class BacktestSummaryDto {
  const BacktestSummaryDto({
    required this.totalPnlPct,
    required this.winRate,
    required this.trades,
    required this.maxDrawdownPct,
    this.wins,
    this.losses,
    this.periodStart,
    this.periodEnd,
  });

  final String totalPnlPct;
  final String winRate;
  final int trades;
  final String maxDrawdownPct;
  final int? wins;
  final int? losses;
  final String? periodStart;
  final String? periodEnd;

  factory BacktestSummaryDto.fromJson(Map<String, dynamic> json) {
    return BacktestSummaryDto(
      totalPnlPct: asString(
        json['total_pnl_pct'] ?? json['pnl_pct'] ?? json['total_pnl'],
      ),
      winRate: asString(json['win_rate'] ?? json['win_rate_pct']),
      trades: asInt(json['trades'] ?? json['trade_count'] ?? json['total_trades']),
      maxDrawdownPct: asString(
        json['max_drawdown_pct'] ?? json['max_dd'] ?? json['max_drawdown'],
      ),
      wins: json['wins'] == null ? null : asInt(json['wins']),
      losses: json['losses'] == null ? null : asInt(json['losses']),
      periodStart: asNullableString(json['period_start'] ?? json['from']),
      periodEnd: asNullableString(json['period_end'] ?? json['to']),
    );
  }
}

class BacktestTradeDto {
  const BacktestTradeDto({
    required this.side,
    required this.pnlPct,
    required this.exitReason,
    this.entryAt,
    this.exitAt,
    this.entryPrice,
    this.exitPrice,
  });

  final String side;
  final String pnlPct;
  final String exitReason;
  final String? entryAt;
  final String? exitAt;
  final String? entryPrice;
  final String? exitPrice;

  factory BacktestTradeDto.fromJson(Map<String, dynamic> json) {
    return BacktestTradeDto(
      side: asString(json['side']),
      pnlPct: asString(json['pnl_pct'] ?? json['pnl'] ?? json['realized_pnl_pct']),
      exitReason: asString(json['exit_reason'] ?? json['reason']),
      entryAt: asNullableString(json['entry_at'] ?? json['opened_at']),
      exitAt: asNullableString(json['exit_at'] ?? json['closed_at'] ?? json['created_at']),
      entryPrice: asNullableString(json['entry_price']),
      exitPrice: asNullableString(json['exit_price'] ?? json['price']),
    );
  }
}
