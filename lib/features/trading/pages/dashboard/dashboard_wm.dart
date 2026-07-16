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
    this.error,
  });

  final Health? health;
  final BotStatus? status;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  DashboardState copyWith({
    Health? health,
    BotStatus? status,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      health: health ?? this.health,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
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
  static const _pollInterval = Duration(seconds: 8);

  @override
  void onLoad() {
    super.onLoad();
    refresh();
    _pollTimer = Timer.periodic(_pollInterval, (_) => refresh(silent: true));
  }

  Future<void> refresh({bool silent = false}) async {
    final current = stateStream.value;
    if (!silent) {
      stateStream.add(
        current.copyWith(
          isLoading: current.status == null,
          isRefreshing: current.status != null,
          clearError: true,
        ),
      );
    }
    try {
      final results = await Future.wait([
        _repository.getHealth(),
        _repository.getStatus(),
      ]);
      stateStream.add(
        DashboardState(
          health: results[0] as Health,
          status: results[1] as BotStatus,
          isLoading: false,
          isRefreshing: false,
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
