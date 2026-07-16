import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/data_error.dart';
import '../../../../core/mwwm/widget_model.dart';
import '../../models/equity_curve.dart';
import '../../models/stats_model.dart';
import '../../models/trade_model.dart';
import '../../repositories/trading_repository.dart';

class StatsState {
  const StatsState({
    this.stats,
    this.equityCurve,
    this.isLoading = true,
    this.error,
  });

  final EpochStats? stats;
  final EquityCurve? equityCurve;
  final bool isLoading;
  final String? error;

  StatsState copyWith({
    EpochStats? stats,
    EquityCurve? equityCurve,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return StatsState(
      stats: stats ?? this.stats,
      equityCurve: equityCurve ?? this.equityCurve,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class StatsWidgetModel extends WidgetModel {
  StatsWidgetModel(this._repository) : super(const WidgetModelDependencies());

  final TradingRepository _repository;
  final BehaviorSubject<StatsState> stateStream =
      BehaviorSubject.seeded(const StatsState());
  Timer? _pollTimer;

  @override
  void onLoad() {
    super.onLoad();
    refresh();
    _pollTimer =
        Timer.periodic(const Duration(seconds: 20), (_) => refresh(silent: true));
  }

  Future<void> refresh({bool silent = false}) async {
    final current = stateStream.value;
    if (!silent) {
      stateStream.add(
        current.copyWith(isLoading: current.stats == null, clearError: true),
      );
    }
    try {
      final results = await Future.wait([
        _repository.getStats(),
        _repository.getTrades(limit: 500),
      ]);
      final stats = results[0] as EpochStats;
      final trades = results[1] as List<Trade>;
      final curve = EquityCurve.fromStatsAndTrades(stats, trades);
      stateStream.add(
        StatsState(stats: stats, equityCurve: curve, isLoading: false),
      );
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
