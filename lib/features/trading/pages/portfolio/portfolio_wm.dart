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
    this.error,
    this.message,
  });

  final Portfolio? portfolio;
  final bool isLoading;
  final bool isBusy;
  final String? error;
  final String? message;

  PortfolioState copyWith({
    Portfolio? portfolio,
    bool? isLoading,
    bool? isBusy,
    String? error,
    String? message,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return PortfolioState(
      portfolio: portfolio ?? this.portfolio,
      isLoading: isLoading ?? this.isLoading,
      isBusy: isBusy ?? this.isBusy,
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

  @override
  void onLoad() {
    super.onLoad();
    refresh();
    _pollTimer = Timer.periodic(const Duration(seconds: 12), (_) => refresh(silent: true));
  }

  Future<void> refresh({bool silent = false}) async {
    final current = stateStream.value;
    if (!silent) {
      stateStream.add(
        current.copyWith(
          isLoading: current.portfolio == null,
          clearError: true,
          clearMessage: true,
        ),
      );
    }
    try {
      final portfolio = await _repository.getPortfolio();
      stateStream.add(
        PortfolioState(portfolio: portfolio, isLoading: false),
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

  Future<void> reconcile() async {
    await _runAction(() => _repository.reconcile(), success: 'Сверка выполнена');
  }

  Future<void> adopt() async {
    await _runAction(() => _repository.adopt(), success: 'Idle принят в позицию бота');
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    required String success,
  }) async {
    final current = stateStream.value;
    stateStream.add(current.copyWith(isBusy: true, clearError: true, clearMessage: true));
    try {
      await action();
      await refresh(silent: true);
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
