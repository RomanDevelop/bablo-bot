import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/data_error.dart';
import '../../../../core/mwwm/widget_model.dart';
import '../../models/trade_model.dart';
import '../../repositories/trading_repository.dart';

class TradesState {
  const TradesState({
    this.trades = const [],
    this.isLoading = true,
    this.error,
  });

  final List<Trade> trades;
  final bool isLoading;
  final String? error;

  TradesState copyWith({
    List<Trade>? trades,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TradesState(
      trades: trades ?? this.trades,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TradesWidgetModel extends WidgetModel {
  TradesWidgetModel(this._repository)
      : super(const WidgetModelDependencies());

  final TradingRepository _repository;
  final BehaviorSubject<TradesState> stateStream =
      BehaviorSubject.seeded(const TradesState());
  Timer? _pollTimer;

  @override
  void onLoad() {
    super.onLoad();
    refresh();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => refresh(silent: true));
  }

  Future<void> refresh({bool silent = false}) async {
    final current = stateStream.value;
    if (!silent) {
      stateStream.add(
        current.copyWith(isLoading: current.trades.isEmpty, clearError: true),
      );
    }
    try {
      final trades = await _repository.getTrades(limit: 50);
      stateStream.add(TradesState(trades: trades, isLoading: false));
    } catch (e, st) {
      handleError(e, st);
      stateStream.add(
        current.copyWith(
          isLoading: false,
          error: e is DataError ? e.displayMessage : e.toString(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    stateStream.close();
    super.dispose();
  }
}
