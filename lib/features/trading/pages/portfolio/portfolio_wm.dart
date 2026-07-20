import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/data_error.dart';
import '../../../../core/mwwm/widget_model.dart';
import '../../models/portfolio_model.dart';
import '../../repositories/trading_repository.dart';

class PortfolioState {
  const PortfolioState({
    this.portfolio,
    this.isLoading = true,
    this.isBusy = false,
    this.isRefreshing = false,
    this.error,
    this.message,
  });

  final Portfolio? portfolio;
  final bool isLoading;
  final bool isBusy;
  final bool isRefreshing;
  final String? error;
  final String? message;

  PortfolioState copyWith({
    Portfolio? portfolio,
    bool? isLoading,
    bool? isBusy,
    bool? isRefreshing,
    String? error,
    String? message,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return PortfolioState(
      portfolio: portfolio ?? this.portfolio,
      isLoading: isLoading ?? this.isLoading,
      isBusy: isBusy ?? this.isBusy,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class PortfolioWidgetModel extends WidgetModel {
  PortfolioWidgetModel(this._repository)
      : super(const WidgetModelDependencies());

  final TradingRepository _repository;
  final BehaviorSubject<PortfolioState> stateStream =
      BehaviorSubject.seeded(const PortfolioState());

  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 15);

  @override
  void onLoad() {
    super.onLoad();
    refresh();
    _pollTimer =
        Timer.periodic(_pollInterval, (_) => refresh(silent: true));
  }

  Future<void> refresh({bool silent = false, bool forceRefresh = false}) async {
    final current = stateStream.value;
    if (!silent) {
      stateStream.add(
        current.copyWith(
          isLoading: current.portfolio == null && !forceRefresh,
          isRefreshing: current.portfolio != null || forceRefresh,
          clearError: true,
          clearMessage: true,
        ),
      );
    } else {
      stateStream.add(current.copyWith(isRefreshing: true, clearError: true));
    }
    try {
      final portfolio =
          await _repository.getPortfolio(forceRefresh: forceRefresh);
      stateStream.add(
        PortfolioState(portfolio: portfolio, isLoading: false, isRefreshing: false),
      );
    } catch (e, st) {
      handleError(e, st);
      stateStream.add(
        current.copyWith(
          isLoading: false,
          isRefreshing: false,
          error: e is DataError ? e.displayMessage : e.toString(),
        ),
      );
    }
  }

  Future<void> reconcile() async {
    await _runAction(() => _repository.reconcile(), success: 'Сверка выполнена');
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    required String success,
  }) async {
    final current = stateStream.value;
    stateStream.add(current.copyWith(isBusy: true, clearError: true, clearMessage: true));
    try {
      await action();
      await refresh(silent: true, forceRefresh: true);
      stateStream.add(
        stateStream.value.copyWith(isBusy: false, message: success),
      );
    } catch (e, st) {
      handleError(e, st);
      stateStream.add(
        stateStream.value.copyWith(
          isBusy: false,
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
