import '../../../core/utils/json_parsers.dart';

class BotConfigDto {
  const BotConfigDto({
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
  });

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

  factory BotConfigDto.fromJson(Map<String, dynamic> json) {
    return BotConfigDto(
      symbol: asString(json['symbol'], 'ETHUSDT'),
      interval: asString(json['interval'], '15m'),
      macdFast: asInt(json['macd_fast'], 5),
      macdSlow: asInt(json['macd_slow'], 13),
      macdSignal: asInt(json['macd_signal'], 2),
      positionSizePct: asDouble(json['position_size_pct'], 25),
      stopLossPct: asDouble(json['stop_loss_pct'], 1.5),
      takeProfitPct: asDouble(json['take_profit_pct'], 2),
      maxDailyLossPct: asDouble(json['max_daily_loss_pct'], 10),
      tradeCooldownMinutes: asInt(json['trade_cooldown_minutes'], 30),
      useCrossoverSignals: asBool(json['use_crossover_signals'], true),
      requireMacdAboveZeroForBuy:
          asBool(json['require_macd_above_zero_for_buy']),
    );
  }

  Map<String, dynamic> toPatchJson({
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
  }) {
    final map = <String, dynamic>{};
    void put(String key, Object? value) {
      if (value != null) map[key] = value;
    }

    put('symbol', symbol);
    put('interval', interval);
    put('macd_fast', macdFast);
    put('macd_slow', macdSlow);
    put('macd_signal', macdSignal);
    put('position_size_pct', positionSizePct);
    put('stop_loss_pct', stopLossPct);
    put('take_profit_pct', takeProfitPct);
    put('max_daily_loss_pct', maxDailyLossPct);
    put('trade_cooldown_minutes', tradeCooldownMinutes);
    put('use_crossover_signals', useCrossoverSignals);
    put('require_macd_above_zero_for_buy', requireMacdAboveZeroForBuy);
    return map;
  }
}
