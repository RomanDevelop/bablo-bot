import 'package:rxdart/rxdart.dart';

import '../../../../core/constants/backtest_constants.dart';
import '../../../../core/errors/data_error.dart';
import '../../../../core/mwwm/widget_model.dart';
import '../../models/backtest_model.dart';
import '../../repositories/backtest_repository.dart';

class LabState {
  const LabState({
    this.config,
    this.symbols = const [],
    this.symbolInput = BacktestConstants.defaultSymbol,
    this.days = BacktestConstants.defaultDays,
    this.isBootstrapping = true,
    this.isRunning = false,
    this.result,
    this.error,
    this.message,
  });

  final BacktestConfig? config;
  final List<String> symbols;
  final String symbolInput;
  final int days;
  final bool isBootstrapping;
  final bool isRunning;
  final BacktestResult? result;
  final String? error;
  final String? message;

  List<int> get dayPresets =>
      config?.dayPresets.isNotEmpty == true
          ? config!.dayPresets
          : BacktestConstants.dayPresets;

  String get normalizedSymbol =>
      BacktestConstants.normalizeSymbol(symbolInput);

  List<String> get symbolSuggestions {
    final q = symbolInput.trim().toUpperCase();
    if (q.isEmpty) return symbols.take(12).toList(growable: false);
    return symbols
        .where((s) => s.contains(q))
        .take(12)
        .toList(growable: false);
  }

  LabState copyWith({
    BacktestConfig? config,
    List<String>? symbols,
    String? symbolInput,
    int? days,
    bool? isBootstrapping,
    bool? isRunning,
    BacktestResult? result,
    String? error,
    String? message,
    bool clearError = false,
    bool clearMessage = false,
    bool clearResult = false,
  }) {
    return LabState(
      config: config ?? this.config,
      symbols: symbols ?? this.symbols,
      symbolInput: symbolInput ?? this.symbolInput,
      days: days ?? this.days,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      isRunning: isRunning ?? this.isRunning,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class LabWidgetModel extends WidgetModel {
  LabWidgetModel(this._repository) : super(const WidgetModelDependencies());

  final BacktestRepository _repository;
  final BehaviorSubject<LabState> stateStream =
      BehaviorSubject.seeded(const LabState());

  @override
  void onLoad() {
    super.onLoad();
    bootstrap();
  }

  Future<void> bootstrap() async {
    stateStream.add(
      stateStream.value.copyWith(isBootstrapping: true, clearError: true),
    );
    try {
      final results = await Future.wait([
        _repository.getConfig(),
        _repository.getSymbols(quote: BacktestConstants.defaultQuote),
      ]);
      final config = results[0] as BacktestConfig;
      final symbols = results[1] as List<String>;
      final presets = config.dayPresets;
      final days = presets.contains(stateStream.value.days)
          ? stateStream.value.days
          : (presets.isNotEmpty ? presets.first : BacktestConstants.defaultDays);

      stateStream.add(
        stateStream.value.copyWith(
          config: config,
          symbols: symbols,
          days: days,
          isBootstrapping: false,
          clearError: true,
        ),
      );
    } on DataError catch (e) {
      stateStream.add(
        stateStream.value.copyWith(
          isBootstrapping: false,
          error: e.displayMessage,
        ),
      );
    } catch (_) {
      stateStream.add(
        stateStream.value.copyWith(
          isBootstrapping: false,
          error: 'Не удалось загрузить настройки Lab',
        ),
      );
    }
  }

  void setSymbolInput(String value) {
    stateStream.add(
      stateStream.value.copyWith(symbolInput: value, clearError: true),
    );
  }

  void selectSymbol(String symbol) {
    stateStream.add(
      stateStream.value.copyWith(symbolInput: symbol, clearError: true),
    );
  }

  void selectDays(int days) {
    if (days == stateStream.value.days) return;
    stateStream.add(stateStream.value.copyWith(days: days, clearError: true));
  }

  Future<void> runBacktest() async {
    final state = stateStream.value;
    if (state.isRunning) return;

    final symbol = state.normalizedSymbol;
    stateStream.add(
      state.copyWith(
        isRunning: true,
        clearError: true,
        clearResult: true,
        clearMessage: true,
      ),
    );

    try {
      final result = await _repository.run(symbol: symbol, days: state.days);
      stateStream.add(
        stateStream.value.copyWith(
          isRunning: false,
          result: result,
          symbolInput: result.symbol.isNotEmpty ? result.symbol : symbol,
        ),
      );
    } on DataError catch (e) {
      stateStream.add(
        stateStream.value.copyWith(
          isRunning: false,
          error: _mapError(e),
        ),
      );
    } catch (_) {
      stateStream.add(
        stateStream.value.copyWith(
          isRunning: false,
          error: BacktestConstants.errorMessage(null),
        ),
      );
    }
  }

  void clearMessage() {
    stateStream.add(stateStream.value.copyWith(clearMessage: true));
  }

  String _mapError(DataError error) {
    final data = error.data;
    if (data != null) {
      final detail = data['detail'];
      if (detail is Map) {
        final code = detail['error'] ?? detail['code'];
        if (code is String) {
          return BacktestConstants.errorMessage(code);
        }
      }
      if (detail is String) {
        return BacktestConstants.errorMessage(detail);
      }
    }
    if (error.errorCode == ErrorCode.exchangeUnavailable) {
      return BacktestConstants.errorMessage('binance_unavailable');
    }
    final msg = error.message;
    if (msg != null && msg.isNotEmpty) {
      final mapped = BacktestConstants.errorMessage(msg);
      if (mapped != BacktestConstants.errorMessage(null)) return mapped;
      return msg;
    }
    return error.displayMessage;
  }

  @override
  void dispose() {
    stateStream.close();
    super.dispose();
  }
}
