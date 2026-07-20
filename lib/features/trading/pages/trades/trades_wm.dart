import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/data_error.dart';
import '../../../../core/mwwm/widget_model.dart';
import '../../models/bot_status_model.dart';
import '../../models/stats_model.dart';
import '../../models/trade_model.dart';
import '../../repositories/trading_repository.dart';

class TradesState {
  const TradesState({
    this.trades = const [],
    this.stats,
    this.status,
    this.isLoading = true,
    this.error,
  });

  final List<Trade> trades;
  final EpochStats? stats;
  final BotStatus? status;
  final bool isLoading;
  final String? error;

  bool get hasUnloggedActivity {
    if (trades.isNotEmpty) return false;
    final stats = this.stats;
    if (stats == null) return false;
    if (stats.totalFills > 0) return true;

    final pnl = double.tryParse(stats.equityPnl) ?? 0;
    return pnl.abs() > 0.01;
  }

  TradesState copyWith({
    List<Trade>? trades,
    EpochStats? stats,
    BotStatus? status,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TradesState(
      trades: trades ?? this.trades,
      stats: stats ?? this.stats,
      status: status ?? this.status,
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
    _pollTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => refresh(silent: true));
  }

  Future<void> refresh({bool silent = false, bool forceRefresh = false}) async {
    final current = stateStream.value;
    if (!silent) {
      stateStream.add(
        current.copyWith(isLoading: current.trades.isEmpty, clearError: true),
      );
    }
    try {
      final results = await Future.wait([
        _repository.getTrades(limit: 50, forceRefresh: forceRefresh),
        _repository.getStats(forceRefresh: forceRefresh),
        _repository.getStatus(forceRefresh: forceRefresh),
      ]);
      stateStream.add(
        TradesState(
          trades: results[0] as List<Trade>,
          stats: results[1] as EpochStats,
          status: results[2] as BotStatus,
          isLoading: false,
        ),
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
