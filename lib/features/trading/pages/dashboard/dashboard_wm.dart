import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/data_error.dart';
import '../../../../core/mwwm/widget_model.dart';
import '../../models/bot_status_model.dart';
import '../../repositories/trading_repository.dart';

class DashboardState {
  const DashboardState({
    this.health,
    this.status,
    this.isLoading = true,
    this.isRefreshing = false,
    this.fetchedAt,
    this.error,
  });

  final Health? health;
  final BotStatus? status;
  final bool isLoading;
  final bool isRefreshing;
  final DateTime? fetchedAt;
  final String? error;

  static const _staleAfter = Duration(seconds: 15);

  bool get isDataStale {
    if (fetchedAt == null) return false;
    return DateTime.now().difference(fetchedAt!) > _staleAfter;
  }

  bool get showUpdating =>
      isRefreshing || (status?.isRunning == true && isDataStale);

  DashboardState copyWith({
    Health? health,
    BotStatus? status,
    bool? isLoading,
    bool? isRefreshing,
    DateTime? fetchedAt,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      health: health ?? this.health,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DashboardWidgetModel extends WidgetModel {
  DashboardWidgetModel(this._repository)
      : super(const WidgetModelDependencies());

  final TradingRepository _repository;
  final BehaviorSubject<DashboardState> stateStream =
      BehaviorSubject.seeded(const DashboardState());

  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 15);

  @override
  void onLoad() {
    super.onLoad();
    refresh();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      final running = stateStream.value.status?.isRunning ?? false;
      if (running) refresh(silent: true);
    });
  }

  Future<void> refresh({bool silent = false, bool forceRefresh = false}) async {
    final current = stateStream.value;
    if (!silent) {
      stateStream.add(
        current.copyWith(
          isLoading: current.status == null && !forceRefresh,
          isRefreshing: current.status != null || forceRefresh,
          clearError: true,
        ),
      );
    } else {
      stateStream.add(current.copyWith(isRefreshing: true, clearError: true));
    }
    try {
      final results = await Future.wait([
        _repository.getHealth(forceRefresh: forceRefresh),
        _repository.getStatus(forceRefresh: forceRefresh),
      ]);
      stateStream.add(
        DashboardState(
          health: results[0] as Health,
          status: results[1] as BotStatus,
          isLoading: false,
          isRefreshing: false,
          fetchedAt: DateTime.now(),
        ),
      );
    } catch (e, st) {
      handleError(e, st);
      final message = e is DataError ? e.displayMessage : e.toString();
      stateStream.add(
        current.copyWith(
          isLoading: false,
          isRefreshing: false,
          error: message,
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
