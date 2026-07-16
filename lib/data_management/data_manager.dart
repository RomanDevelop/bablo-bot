import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/network_client.dart';
import '../features/trading/cache/api_cache.dart';
import '../features/trading/data_providers/trading_data_provider.dart';
import '../features/trading/market/candle_cache.dart';
import '../features/trading/market/market_data_provider.dart';
import '../features/trading/repositories/chart_repository.dart';
import '../features/trading/repositories/trading_repository.dart';

/// Central access to data layer (per ARCHITECTURE_GUIDE DataManager).
class DataManager {
  DataManager._({
    required NetworkClient networkClient,
    required TradingDataProvider tradingDataProvider,
    required this.tradingRepository,
    required this.marketDataProvider,
    required this.chartRepository,
  })  : _networkClient = networkClient,
        _tradingDataProvider = tradingDataProvider;

  final NetworkClient _networkClient;
  final TradingDataProvider _tradingDataProvider;
  final TradingRepository tradingRepository;
  final MarketDataProvider marketDataProvider;
  final ChartRepository chartRepository;

  NetworkClient get networkClient => _networkClient;
  TradingDataProvider get tradingDataProvider => _tradingDataProvider;

  static Future<DataManager> create() async {
    final prefs = await SharedPreferences.getInstance();
    final apiCache = ApiCache(prefs);
    final candleCache = CandleCache(prefs);
    final networkClient = NetworkClient();
    final tradingDataProvider = TradingDataProvider(
      networkClient: networkClient,
      cache: apiCache,
    );
    final tradingRepository =
        TradingRepository(dataProvider: tradingDataProvider);
    final marketDataProvider = MarketDataProvider(cache: candleCache);
    final chartRepository = ChartRepository(
      tradingRepository: tradingRepository,
      marketDataProvider: marketDataProvider,
    );
    return DataManager._(
      networkClient: networkClient,
      tradingDataProvider: tradingDataProvider,
      tradingRepository: tradingRepository,
      marketDataProvider: marketDataProvider,
      chartRepository: chartRepository,
    );
  }
}
