import '../data_providers/backtest_data_provider.dart';
import '../models/backtest_model.dart';

class BacktestRepository {
  BacktestRepository({required BacktestDataProviderInterface dataProvider})
      : _dataProvider = dataProvider;

  final BacktestDataProviderInterface _dataProvider;

  Future<BacktestConfig> getConfig() async {
    final dto = await _dataProvider.getConfig();
    return BacktestConfig.fromDto(dto);
  }

  Future<List<String>> getSymbols({String quote = 'USDT'}) =>
      _dataProvider.getSymbols(quote: quote);

  Future<BacktestResult> run({
    required String symbol,
    required int days,
  }) async {
    final dto = await _dataProvider.run(symbol: symbol, days: days);
    return BacktestResult.fromDto(dto);
  }
}
