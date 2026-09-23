import 'package:shared_preferences/shared_preferences.dart';

import '../core/auth/auth_session.dart';
import '../core/auth/token_storage.dart';
import '../core/constants/api_constants.dart';
import '../core/network/auth_interceptor.dart';
import '../core/network/network_client.dart';
import '../features/auth/repositories/auth_repository.dart';
import '../features/trading/cache/api_cache.dart';
import '../features/trading/data_providers/trading_data_provider.dart';
import '../features/trading/market/candle_cache.dart';
import '../features/trading/market/market_data_provider.dart';
import '../features/trading/repositories/chart_repository.dart';
import '../features/trading/repositories/daily_repository.dart';
import '../features/trading/repositories/trading_repository.dart';
import '../features/trading/data_providers/backtest_data_provider.dart';
import '../features/trading/data_providers/casino_data_provider.dart';
import '../features/trading/data_providers/copy_data_provider.dart';
import '../features/trading/data_providers/sportsbook_data_provider.dart';
import '../features/trading/repositories/backtest_repository.dart';
import '../features/trading/repositories/casino_repository.dart';
import '../features/trading/repositories/copy_repository.dart';
import '../features/trading/repositories/sportsbook_repository.dart';

/// Wires network, auth, and repositories for the app shell.
class AppServices {
  AppServices._({
    required this.dataManager,
    required this.authSession,
    required this.authRepository,
    required this.tokenStorage,
  });

  final DataManager dataManager;
  final AuthSession authSession;
  final AuthRepository authRepository;
  final TokenStorage tokenStorage;

  static Future<AppServices> create() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenStorage = await TokenStorage.create();
    final networkClient = NetworkClient();
    final authRepository = AuthRepository(
      networkClient: networkClient,
      tokenStorage: tokenStorage,
    );

    late AuthSession authSession;
    authSession = await AuthSession.create(
      authRepository: authRepository,
      tokenStorage: tokenStorage,
    );

    networkClient.attachAuthInterceptor(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        dio: networkClient.dio,
        onRefresh: authSession.refreshTokensForInterceptor,
        onSessionExpired: authSession.handleSessionExpired,
      ),
    );

    final apiCache = ApiCache(prefs);
    final candleCache = CandleCache(prefs);
    final tradingDataProvider = TradingDataProvider(
      networkClient: networkClient,
      cache: apiCache,
    );
    final tradingRepository =
        TradingRepository(dataProvider: tradingDataProvider);
    final marketDataProvider = MarketDataProvider(
      cache: candleCache,
      botApiBaseUrl: ApiConstants.baseUrl,
    );
    final chartRepository = ChartRepository(
      tradingRepository: tradingRepository,
      marketDataProvider: marketDataProvider,
    );
    final dailyRepository = DailyRepository(
      networkClient: networkClient,
      prefs: prefs,
    );
    final backtestDataProvider = BacktestDataProvider(
      networkClient: networkClient,
    );
    final backtestRepository = BacktestRepository(
      dataProvider: backtestDataProvider,
    );
    final copyDataProvider = CopyDataProvider(networkClient: networkClient);
    final copyRepository = CopyRepository(dataProvider: copyDataProvider);
    final casinoDataProvider = CasinoDataProvider(networkClient: networkClient);
    final casinoRepository = CasinoRepository(dataProvider: casinoDataProvider);
    final sportsbookDataProvider =
        SportsbookDataProvider(networkClient: networkClient);
    final sportsbookRepository =
        SportsbookRepository(dataProvider: sportsbookDataProvider);

    final dataManager = DataManager._(
      networkClient: networkClient,
      tradingDataProvider: tradingDataProvider,
      tradingRepository: tradingRepository,
      marketDataProvider: marketDataProvider,
      chartRepository: chartRepository,
      dailyRepository: dailyRepository,
      backtestRepository: backtestRepository,
      copyRepository: copyRepository,
      casinoRepository: casinoRepository,
      sportsbookRepository: sportsbookRepository,
    );

    return AppServices._(
      dataManager: dataManager,
      authSession: authSession,
      authRepository: authRepository,
      tokenStorage: tokenStorage,
    );
  }
}

/// Central access to data layer (per ARCHITECTURE_GUIDE DataManager).
class DataManager {
  DataManager._({
    required NetworkClient networkClient,
    required TradingDataProvider tradingDataProvider,
    required this.tradingRepository,
    required this.marketDataProvider,
    required this.chartRepository,
    required this.dailyRepository,
    required this.backtestRepository,
    required this.copyRepository,
    required this.casinoRepository,
    required this.sportsbookRepository,
  })  : _networkClient = networkClient,
        _tradingDataProvider = tradingDataProvider;

  final NetworkClient _networkClient;
  final TradingDataProvider _tradingDataProvider;
  final TradingRepository tradingRepository;
  final MarketDataProvider marketDataProvider;
  final ChartRepository chartRepository;
  final DailyRepository dailyRepository;
  final BacktestRepository backtestRepository;
  final CopyRepository copyRepository;
  final CasinoRepository casinoRepository;
  final SportsbookRepository sportsbookRepository;

  NetworkClient get networkClient => _networkClient;
  TradingDataProvider get tradingDataProvider => _tradingDataProvider;
}
