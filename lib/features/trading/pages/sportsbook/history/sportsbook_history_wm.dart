import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../../../../core/auth/auth_session.dart';
import '../../../../../core/constants/sportsbook_constants.dart';
import '../../../../../core/errors/data_error.dart';
import '../../../../../core/mwwm/widget_model.dart';
import '../../../models/sportsbook_model.dart';
import '../../../repositories/sportsbook_repository.dart';
import '../navigation/sportsbook_navigator.dart';

class SportsbookHistoryState {
  const SportsbookHistoryState({
    this.bets = const [],
    this.isLoading = true,
    this.error,
    this.needsAuth = false,
    this.planRequired = false,
  });

  final List<SportsbookBet> bets;
  final bool isLoading;
  final String? error;
  final bool needsAuth;
  final bool planRequired;

  bool get hasOpenBets => bets.any((bet) => bet.isOpen);

  SportsbookHistoryState copyWith({
    List<SportsbookBet>? bets,
    bool? isLoading,
    String? error,
    bool? needsAuth,
    bool? planRequired,
    bool clearError = false,
  }) {
    return SportsbookHistoryState(
      bets: bets ?? this.bets,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      needsAuth: needsAuth ?? this.needsAuth,
      planRequired: planRequired ?? this.planRequired,
    );
  }
}

class SportsbookHistoryWidgetModel extends WidgetModel {
  SportsbookHistoryWidgetModel({
    required AuthSession auth,
    required SportsbookRepository repository,
    required SportsbookNavigator navigator,
  })  : _auth = auth,
        _repository = repository,
        _navigator = navigator,
        super(const WidgetModelDependencies());

  final AuthSession _auth;
  final SportsbookRepository _repository;
  final SportsbookNavigator _navigator;

  final BehaviorSubject<SportsbookHistoryState> stateStream =
      BehaviorSubject.seeded(const SportsbookHistoryState());

  Timer? _pollTimer;

  @override
  void onLoad() {
    super.onLoad();
    load();
  }

  void openSubscriptions() => _navigator.goToSubscriptions();

  void openProfile() => _navigator.goToProfile();

  Future<void> load({bool silent = false}) async {
    if (!_auth.isAuthenticated) {
      _pollTimer?.cancel();
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
          isLoading: stateStream.value.bets.isEmpty,
          needsAuth: false,
          clearError: true,
        ),
      );
    }

    try {
      final bets = await _repository.getBets();
      stateStream.add(
        stateStream.value.copyWith(
          bets: bets,
          isLoading: false,
          planRequired: !_auth.canUseSportsbook,
          clearError: true,
        ),
      );
      _armPoll(bets.any((bet) => bet.isOpen));
    } on DataError catch (e) {
      if (e.apiError == 'plan_required' ||
          (e.errorCode == ErrorCode.forbidden && !_auth.canUseSportsbook)) {
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
          error: SportsbookRepository.mapError(e),
        ),
      );
    } catch (e) {
      stateStream.add(
        stateStream.value.copyWith(
          isLoading: false,
          error: SportsbookRepository.mapError(e),
        ),
      );
    }
  }

  void _armPoll(bool hasOpen) {
    _pollTimer?.cancel();
    if (!hasOpen) return;
    _pollTimer = Timer.periodic(SportsbookConstants.pollInterval, (_) {
      if (isDisposed) return;
      load(silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    stateStream.close();
    super.dispose();
  }
}
