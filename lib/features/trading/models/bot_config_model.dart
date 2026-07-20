import '../dto/bot_config_dto.dart';

class BotConfig {
  const BotConfig({
    this.mode,
    required this.symbol,
    required this.interval,
    required this.macdFast,
    required this.macdSlow,
    required this.macdSignal,
    required this.positionSizePct,
    required this.stopLossPct,
    required this.takeProfitPct,
    required this.maxDailyLossPct,
    required this.tradeCooldownMinutes,
    required this.useCrossoverSignals,
    required this.requireMacdAboveZeroForBuy,
    this.futuresLeverage,
    this.futuresMarginType,
  });

  final String? mode;
  final String symbol;
  final String interval;
  final int macdFast;
  final int macdSlow;
  final int macdSignal;
  final double positionSizePct;
  final double stopLossPct;
  final double takeProfitPct;
  final double maxDailyLossPct;
  final int tradeCooldownMinutes;
  final bool useCrossoverSignals;
  final bool requireMacdAboveZeroForBuy;
  final int? futuresLeverage;
  final String? futuresMarginType;

  factory BotConfig.fromDto(BotConfigDto dto) => BotConfig(
        mode: dto.mode,
        symbol: dto.symbol,
        interval: dto.interval,
        macdFast: dto.macdFast,
        macdSlow: dto.macdSlow,
        macdSignal: dto.macdSignal,
        positionSizePct: dto.positionSizePct,
        stopLossPct: dto.stopLossPct,
        takeProfitPct: dto.takeProfitPct,
        maxDailyLossPct: dto.maxDailyLossPct,
        tradeCooldownMinutes: dto.tradeCooldownMinutes,
        useCrossoverSignals: dto.useCrossoverSignals,
        requireMacdAboveZeroForBuy: dto.requireMacdAboveZeroForBuy,
        futuresLeverage: dto.futuresLeverage,
        futuresMarginType: dto.futuresMarginType,
      );

  BotConfig copyWith({
    String? mode,
    String? symbol,
    String? interval,
    int? macdFast,
    int? macdSlow,
    int? macdSignal,
    double? positionSizePct,
    double? stopLossPct,
    double? takeProfitPct,
    double? maxDailyLossPct,
    int? tradeCooldownMinutes,
    bool? useCrossoverSignals,
    bool? requireMacdAboveZeroForBuy,
    int? futuresLeverage,
    String? futuresMarginType,
  }) {
    return BotConfig(
      mode: mode ?? this.mode,
      symbol: symbol ?? this.symbol,
      interval: interval ?? this.interval,
      macdFast: macdFast ?? this.macdFast,
      macdSlow: macdSlow ?? this.macdSlow,
      macdSignal: macdSignal ?? this.macdSignal,
      positionSizePct: positionSizePct ?? this.positionSizePct,
      stopLossPct: stopLossPct ?? this.stopLossPct,
      takeProfitPct: takeProfitPct ?? this.takeProfitPct,
      maxDailyLossPct: maxDailyLossPct ?? this.maxDailyLossPct,
      tradeCooldownMinutes:
          tradeCooldownMinutes ?? this.tradeCooldownMinutes,
      useCrossoverSignals: useCrossoverSignals ?? this.useCrossoverSignals,
      requireMacdAboveZeroForBuy:
          requireMacdAboveZeroForBuy ?? this.requireMacdAboveZeroForBuy,
      futuresLeverage: futuresLeverage ?? this.futuresLeverage,
      futuresMarginType: futuresMarginType ?? this.futuresMarginType,
    );
  }

  String get futuresLabel {
    if (futuresLeverage == null) return '—';
    final margin = futuresMarginType ?? '—';
    return '${futuresLeverage}x · $margin';
  }
}
