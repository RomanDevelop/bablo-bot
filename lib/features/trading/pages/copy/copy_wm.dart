import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../../core/constants/copy_constants.dart';
import '../../../../core/errors/data_error.dart';
import '../../../../core/mwwm/widget_model.dart';
import '../../models/copy_model.dart';
import '../../repositories/copy_repository.dart';
import 'navigation/copy_navigator.dart';

class CopyState {
  const CopyState({
    this.status,
    this.history = const [],
    this.isLoading = true,
    this.isMutating = false,
    this.disclaimerAccepted = false,
    this.amountRsv = 500,
    this.countdownSeconds = 0,
    this.error,
    this.message,
    this.needsAuth = false,
    this.planRequired = false,
  });

  final CopyStatus? status;
  final List<CopyHistoryItem> history;
  final bool isLoading;
  final bool isMutating;
  final bool disclaimerAccepted;
  final double amountRsv;
  final int countdownSeconds;
  final String? error;
  final String? message;
  final bool needsAuth;
  final bool planRequired;

  bool get isActive => status?.isActive ?? false;

  CopyState copyWith({
    CopyStatus? status,
    List<CopyHistoryItem>? history,
    bool? isLoading,
    bool? isMutating,
    bool? disclaimerAccepted,
    double? amountRsv,
    int? countdownSeconds,
    String? error,
    String? message,
    bool? needsAuth,
    bool? planRequired,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return CopyState(
      status: status ?? this.status,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      disclaimerAccepted: disclaimerAccepted ?? this.disclaimerAccepted,
      amountRsv: amountRsv ?? this.amountRsv,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
      needsAuth: needsAuth ?? this.needsAuth,
      planRequired: planRequired ?? this.planRequired,
    );
  }
}

class CopyWidgetModel extends WidgetModel {
  CopyWidgetModel({
    required AuthSession auth,
    required CopyRepository repository,
    required CopyNavigator navigator,
  })  : _auth = auth,
        _repository = repository,
        _navigator = navigator,
        super(const WidgetModelDependencies());

  final AuthSession _auth;
  final CopyRepository _repository;
  final CopyNavigator _navigator;

  final BehaviorSubject<CopyState> stateStream =
      BehaviorSubject.seeded(const CopyState());

  Timer? _countdownTimer;

  @override
  void onLoad() {
    super.onLoad();
    _seedFromBootstrap();
    load();
  }

  void setAmount(double value) {
    stateStream.add(stateStream.value.copyWith(amountRsv: _clampAmount(value)));
  }

  void setDisclaimerAccepted(bool value) {
    stateStream.add(stateStream.value.copyWith(disclaimerAccepted: value));
  }

  void clearMessage() {
    stateStream.add(stateStream.value.copyWith(clearMessage: true));
  }

  void openSubscriptions() => _navigator.goToSubscriptions();

  void openProfile() => _navigator.goToProfile();

  Future<void> load({bool silent = false}) async {
    if (!_auth.isAuthenticated) {
      stateStream.add(
        stateStream.value.copyWith(
          isLoading: false,
          needsAuth: true,
          planRequired: false,
          clearError: true,
        ),
      );
      return;
    }

    if (!silent) {
      stateStream.add(
        stateStream.value.copyWith(
          isLoading: stateStream.value.status == null,
          needsAuth: false,
          clearError: true,
        ),
      );
    }

    try {
      final status = await _repository.getStatus();
      await _applyStatus(status, clearHistoryIfInactive: true);
      if (status.isActive) {
        await _loadHistory();
      }
    } on DataError catch (e) {
      if (e.apiError == 'plan_required' ||
          (e.errorCode == ErrorCode.forbidden && !_auth.canUseCopyTrading)) {
        stateStream.add(
          stateStream.value.copyWith(
            isLoading: false,
            planRequired: true,
            needsAuth: false,
            clearError: true,
          ),
        );
        return;
      }
      stateStream.add(
        stateStream.value.copyWith(
          isLoading: false,
          error: CopyRepository.mapError(e),
        ),
      );
    } catch (e) {
      stateStream.add(
        stateStream.value.copyWith(
          isLoading: false,
          error: CopyRepository.mapError(e),
        ),
      );
    }
  }

  Future<void> enable() async {
    final state = stateStream.value;
    final status = state.status;
    if (status == null) return;
    if (!state.disclaimerAccepted) {
      stateStream.add(
        state.copyWith(message: CopyConstants.errorDisclaimer),
      );
      return;
    }
    if (state.amountRsv < status.minStakeRsv) {
      stateStream.add(state.copyWith(message: CopyConstants.errorMinStake));
      return;
    }
    if (state.amountRsv > status.availableEarnedRsv) {
      stateStream.add(
        state.copyWith(message: CopyConstants.errorInsufficient),
      );
      return;
    }

    await _mutate(() async {
      final next = await _repository.enable(
        amountRsv: state.amountRsv,
        acceptDisclaimer: true,
      );
      await _applyStatus(next);
      await _loadHistory();
      await _auth.refreshBootstrap();
      return 'Копирование подключено';
    });
  }

  Future<void> topup() async {
    final status = stateStream.value.status;
    if (status == null || !status.isActive) return;
    final max = status.availableEarnedRsv;
    if (max <= 0) {
      stateStream.add(
        stateStream.value.copyWith(message: CopyConstants.errorInsufficient),
      );
      return;
    }
    final amount = await _navigator.promptTopup(maxAmount: max);
    if (amount == null) return;
    if (amount <= 0) {
      stateStream.add(
        stateStream.value.copyWith(message: CopyConstants.errorInsufficient),
      );
      return;
    }
    await _mutate(() async {
      final next = await _repository.topup(amountRsv: amount);
      await _applyStatus(next);
      await _auth.refreshBootstrap();
      return 'Стейк пополнен. Срок лока не изменился';
    });
  }

  Future<void> exit() async {
    final status = stateStream.value.status;
    final stake = status?.stake;
    if (status == null || stake == null) return;
    final confirmed = await _navigator.confirmEarlyExit(status: status);
    if (!confirmed) return;
    await _mutate(() async {
      final next = await _repository.exit();
      await _applyStatus(next, clearHistoryIfInactive: true);
      await _auth.refreshBootstrap();
      return 'Стейк закрыт. Штраф удержан';
    });
  }

  Future<void> complete() async {
    final stake = stateStream.value.status?.stake;
    if (stake == null || !stake.canComplete) return;
    await _mutate(() async {
      final next = await _repository.complete();
      await _applyStatus(next, clearHistoryIfInactive: true);
      await _auth.refreshBootstrap();
      return 'Копирование завершено. RSV разблокированы';
    });
  }

  void _seedFromBootstrap() {
    final dto = _auth.bootstrap?.copy;
    if (dto == null) return;
    final status = CopyStatus.fromDto(dto);
    stateStream.add(
      stateStream.value.copyWith(
        status: status,
        amountRsv: _defaultAmount(status),
        countdownSeconds: status.stake?.remainingSeconds ?? 0,
        isLoading: true,
        planRequired: !(_auth.canUseCopyTrading || status.eligible),
      ),
    );
    _armCountdown(status);
  }

  Future<void> _applyStatus(
    CopyStatus status, {
    bool clearHistoryIfInactive = false,
  }) async {
    _armCountdown(status);
    stateStream.add(
      stateStream.value.copyWith(
        status: status,
        isLoading: false,
        isMutating: false,
        planRequired: !(status.eligible || _auth.canUseCopyTrading),
        amountRsv: _defaultAmount(status),
        countdownSeconds: status.stake?.remainingSeconds ?? 0,
        disclaimerAccepted: false,
        history: clearHistoryIfInactive && !status.isActive
            ? const []
            : stateStream.value.history,
        clearError: true,
      ),
    );
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _repository.getHistory();
      stateStream.add(stateStream.value.copyWith(history: history));
    } catch (_) {
      // History is secondary — keep the stake dashboard.
    }
  }

  Future<void> _mutate(Future<String> Function() action) async {
    stateStream.add(
      stateStream.value.copyWith(isMutating: true, clearMessage: true),
    );
    try {
      final message = await action();
      stateStream.add(
        stateStream.value.copyWith(isMutating: false, message: message),
      );
    } catch (e) {
      stateStream.add(
        stateStream.value.copyWith(
          isMutating: false,
          message: CopyRepository.mapError(e),
        ),
      );
    }
  }

  void _armCountdown(CopyStatus status) {
    _countdownTimer?.cancel();
    final remaining = status.stake?.remainingSeconds ?? 0;
    if (!status.isActive || remaining <= 0) return;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isDisposed) return;
      final next = stateStream.value.countdownSeconds - 1;
      if (next <= 0) {
        _countdownTimer?.cancel();
        stateStream.add(stateStream.value.copyWith(countdownSeconds: 0));
        load(silent: true);
        return;
      }
      stateStream.add(stateStream.value.copyWith(countdownSeconds: next));
    });
  }

  double _defaultAmount(CopyStatus status) {
    return _clampAmount(status.minStakeRsv.toDouble(), status: status);
  }

  double _clampAmount(double value, {CopyStatus? status}) {
    final current = status ?? stateStream.value.status;
    if (current == null) return value;
    final min = current.minStakeRsv.toDouble();
    final max = current.availableEarnedRsv.toDouble();
    if (max <= min) return min;
    return value.clamp(min, max).toDouble();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    stateStream.close();
    super.dispose();
  }
}
