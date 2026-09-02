import '../dto/backtest_dto.dart';

class BacktestConfig {
  const BacktestConfig({
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

  factory BacktestConfig.fromDto(BacktestConfigDto dto) => BacktestConfig(
        minDays: dto.minDays,
        maxDays: dto.maxDays,
        dayPresets: dto.dayPresets,
        strategyLabel: dto.strategyLabel,
        interval: dto.interval,
        stopLossNote: dto.stopLossNote,
        takeProfitNote: dto.takeProfitNote,
      );

  String get strategyNote {
    final parts = <String>[strategyLabel, interval];
    if (stopLossNote != null && stopLossNote!.isNotEmpty) {
      parts.add(stopLossNote!);
    }
    if (takeProfitNote != null && takeProfitNote!.isNotEmpty) {
      parts.add(takeProfitNote!);
    }
    return parts.join(' · ');
  }
}

class BacktestResult {
  const BacktestResult({
    required this.symbol,
    required this.days,
    required this.summary,
    required this.trades,
  });

  final String symbol;
  final int days;
  final BacktestSummary summary;
  final List<BacktestTrade> trades;

  factory BacktestResult.fromDto(BacktestRunDto dto) => BacktestResult(
        symbol: dto.symbol,
        days: dto.days,
        summary: BacktestSummary.fromDto(dto.summary),
        trades: dto.trades.map(BacktestTrade.fromDto).toList(growable: false),
      );
}

class BacktestSummary {
  const BacktestSummary({
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

  factory BacktestSummary.fromDto(BacktestSummaryDto dto) => BacktestSummary(
        totalPnlPct: dto.totalPnlPct,
        winRate: dto.winRate,
        trades: dto.trades,
        maxDrawdownPct: dto.maxDrawdownPct,
        wins: dto.wins,
        losses: dto.losses,
        periodStart: dto.periodStart,
        periodEnd: dto.periodEnd,
      );
}

class BacktestTrade {
  const BacktestTrade({
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

  factory BacktestTrade.fromDto(BacktestTradeDto dto) => BacktestTrade(
        side: dto.side,
        pnlPct: dto.pnlPct,
        exitReason: dto.exitReason,
        entryAt: dto.entryAt,
        exitAt: dto.exitAt,
        entryPrice: dto.entryPrice,
        exitPrice: dto.exitPrice,
      );

  bool get isLong =>
      side.toUpperCase().contains('LONG') || side.toUpperCase() == 'BUY';
}
