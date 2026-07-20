import '../data_providers/trading_data_provider.dart';
import '../dto/bot_config_dto.dart';
import '../models/bot_config_model.dart';
import '../models/bot_status_model.dart';
import '../models/portfolio_model.dart';
import '../models/stats_model.dart';
import '../models/trade_model.dart';

class TradingRepository {
  TradingRepository({required TradingDataProviderInterface dataProvider})
      : _dataProvider = dataProvider;

  final TradingDataProviderInterface _dataProvider;

  Future<Health> getHealth({bool forceRefresh = false}) async {
    final dto = await _dataProvider.getHealth(forceRefresh: forceRefresh);
    return Health.fromDto(dto);
  }

  Future<BotStatus> getStatus({bool forceRefresh = false}) async {
    final dto = await _dataProvider.getStatus(forceRefresh: forceRefresh);
    return BotStatus.fromDto(dto);
  }

  Future<Portfolio> getPortfolio({bool forceRefresh = false}) async {
    final dto = await _dataProvider.getPortfolio(forceRefresh: forceRefresh);
    return Portfolio.fromDto(dto);
  }

  Future<EpochStats> getStats({bool forceRefresh = false}) async {
    final dto = await _dataProvider.getStats(forceRefresh: forceRefresh);
    return EpochStats.fromDto(dto);
  }

  Future<List<Trade>> getTrades({
    int limit = 50,
    String? symbol,
    bool forceRefresh = false,
  }) async {
    final dtos = await _dataProvider.getTrades(
      limit: limit,
      symbol: symbol,
      forceRefresh: forceRefresh,
    );
    return dtos.map(Trade.fromDto).toList(growable: false);
  }

  Future<BotConfig> getConfig({bool forceRefresh = false}) async {
    final dto = await _dataProvider.getConfig(forceRefresh: forceRefresh);
    return BotConfig.fromDto(dto);
  }

  Future<BotConfig> patchConfig(Map<String, dynamic> body) async {
    final dto = await _dataProvider.patchConfig(body);
    return BotConfig.fromDto(dto);
  }

  Future<BotConfig> saveConfig(BotConfig config, BotConfig original) async {
    final body = BotConfigDto(
      symbol: config.symbol,
      interval: config.interval,
      macdFast: config.macdFast,
      macdSlow: config.macdSlow,
      macdSignal: config.macdSignal,
      positionSizePct: config.positionSizePct,
      stopLossPct: config.stopLossPct,
      takeProfitPct: config.takeProfitPct,
      maxDailyLossPct: config.maxDailyLossPct,
      tradeCooldownMinutes: config.tradeCooldownMinutes,
      useCrossoverSignals: config.useCrossoverSignals,
      requireMacdAboveZeroForBuy: config.requireMacdAboveZeroForBuy,
    ).toPatchJson(
      symbol: config.symbol != original.symbol ? config.symbol : null,
      interval: config.interval != original.interval ? config.interval : null,
      macdFast: config.macdFast != original.macdFast ? config.macdFast : null,
      macdSlow: config.macdSlow != original.macdSlow ? config.macdSlow : null,
      macdSignal:
          config.macdSignal != original.macdSignal ? config.macdSignal : null,
      positionSizePct: config.positionSizePct != original.positionSizePct
          ? config.positionSizePct
          : null,
      stopLossPct:
          config.stopLossPct != original.stopLossPct ? config.stopLossPct : null,
      takeProfitPct: config.takeProfitPct != original.takeProfitPct
          ? config.takeProfitPct
          : null,
      maxDailyLossPct: config.maxDailyLossPct != original.maxDailyLossPct
          ? config.maxDailyLossPct
          : null,
      tradeCooldownMinutes:
          config.tradeCooldownMinutes != original.tradeCooldownMinutes
              ? config.tradeCooldownMinutes
              : null,
      useCrossoverSignals:
          config.useCrossoverSignals != original.useCrossoverSignals
              ? config.useCrossoverSignals
              : null,
      requireMacdAboveZeroForBuy: config.requireMacdAboveZeroForBuy !=
              original.requireMacdAboveZeroForBuy
          ? config.requireMacdAboveZeroForBuy
          : null,
    );
    if (body.isEmpty) return config;
    return patchConfig(body);
  }

  Future<void> start({required String symbol, required String interval}) async {
    await _dataProvider.start(symbol: symbol, interval: interval);
  }

  Future<void> stop() async {
    await _dataProvider.stop();
  }

  Future<void> emergencyStop() async {
    await _dataProvider.emergencyStop();
  }

  Future<void> reconcile() async {
    await _dataProvider.reconcile();
  }

  Future<void> adopt() async {
    await _dataProvider.adopt();
  }

  Future<void> invalidateCache() => _dataProvider.invalidateCache();

  Future<List<String>> getPairs({String quote = 'USDT'}) {
    return _dataProvider.getPairs(quote: quote);
  }
}
