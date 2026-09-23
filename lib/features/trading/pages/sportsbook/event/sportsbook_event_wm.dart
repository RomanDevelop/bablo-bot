import 'package:rxdart/rxdart.dart';

import '../../../../../core/auth/auth_session.dart';
import '../../../../../core/constants/sportsbook_constants.dart';
import '../../../../../core/errors/data_error.dart';
import '../../../../../core/mwwm/widget_model.dart';
import '../../../models/sportsbook_model.dart';
import '../../../repositories/sportsbook_repository.dart';
import '../navigation/sportsbook_navigator.dart';
import '../sportsbook_request_id.dart';

class SportsbookEventState {
  const SportsbookEventState({
    this.status,
    this.event,
    this.market,
    this.selectedOutcomeId,
    this.stakeRsv = SportsbookConstants.minStakeRsv,
    this.acceptedBet,
    this.isLoading = true,
    this.isMutating = false,
    this.oddsChanged = false,
    this.error,
    this.message,
    this.needsAuth = false,
    this.planRequired = false,
  });

  final SportsbookStatus? status;
  final SportsbookEvent? event;
  final SportsbookMarket? market;
  final String? selectedOutcomeId;
  final double stakeRsv;
  final SportsbookBet? acceptedBet;
  final bool isLoading;
  final bool isMutating;
  final bool oddsChanged;
  final String? error;
  final String? message;
  final bool needsAuth;
  final bool planRequired;

  SportsbookOutcome? get selectedOutcome =>
      market?.byProviderId(selectedOutcomeId);

  num get previewPayout {
    final odds = selectedOutcome?.odds ?? 0;
    return stakeRsv * odds;
  }

  bool get canSubmit {
    final event = this.event;
    final market = this.market;
    final status = this.status;
    if (event == null || market == null || status == null) return false;
    if (!event.canPlaceBet || !market.isOpen || !status.enabled) return false;
    if (selectedOutcome == null) return false;
    if (!status.canAffordMin) return false;
    if (stakeRsv < status.minStakeRsv) return false;
    if (stakeRsv > status.stakeCeiling) return false;
    if (acceptedBet != null) return false;
    return !isMutating;
  }

  SportsbookEventState copyWith({
    SportsbookStatus? status,
    SportsbookEvent? event,
    SportsbookMarket? market,
    String? selectedOutcomeId,
    double? stakeRsv,
    SportsbookBet? acceptedBet,
    bool? isLoading,
    bool? isMutating,
    bool? oddsChanged,
    String? error,
    String? message,
    bool? needsAuth,
    bool? planRequired,
    bool clearError = false,
    bool clearMessage = false,
    bool clearSelection = false,
    bool clearAccepted = false,
  }) {
    return SportsbookEventState(
      status: status ?? this.status,
      event: event ?? this.event,
      market: market ?? this.market,
      selectedOutcomeId:
          clearSelection ? null : (selectedOutcomeId ?? this.selectedOutcomeId),
      stakeRsv: stakeRsv ?? this.stakeRsv,
      acceptedBet: clearAccepted ? null : (acceptedBet ?? this.acceptedBet),
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      oddsChanged: oddsChanged ?? this.oddsChanged,
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
      needsAuth: needsAuth ?? this.needsAuth,
      planRequired: planRequired ?? this.planRequired,
    );
  }
}

class SportsbookEventWidgetModel extends WidgetModel {
  SportsbookEventWidgetModel({
    required this.eventId,
    this.preview,
    required AuthSession auth,
    required SportsbookRepository repository,
    required SportsbookNavigator navigator,
  })  : _auth = auth,
        _repository = repository,
        _navigator = navigator,
        super(const WidgetModelDependencies());

  final String eventId;
  final SportsbookEvent? preview;
  final AuthSession _auth;
  final SportsbookRepository _repository;
  final SportsbookNavigator _navigator;

  final BehaviorSubject<SportsbookEventState> stateStream =
      BehaviorSubject.seeded(const SportsbookEventState());

  String? _retryRequestId;

  @override
  void onLoad() {
    super.onLoad();
    final seed = preview;
    if (seed != null) {
      stateStream.add(
        stateStream.value.copyWith(
          event: seed,
          market: seed.market,
          isLoading: seed.market == null || seed.market!.outcomes.isEmpty,
        ),
      );
    }
    load();
  }

  void clearMessage() {
    stateStream.add(stateStream.value.copyWith(clearMessage: true));
  }

  void openSubscriptions() => _navigator.goToSubscriptions();

  void openProfile() => _navigator.goToProfile();

  void openHistory() => _navigator.goToHistory();

  void selectOutcome(SportsbookOutcome outcome) {
    stateStream.add(
      stateStream.value.copyWith(
        selectedOutcomeId: outcome.providerOutcomeId,
        oddsChanged: false,
        clearAccepted: true,
      ),
    );
  }

  void setStake(double value) {
    stateStream.add(
      stateStream.value.copyWith(stakeRsv: _clampStake(value)),
    );
  }

  void stepStake(double delta) {
    setStake(stateStream.value.stakeRsv + delta);
  }

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
          isLoading: stateStream.value.event == null,
          needsAuth: false,
          clearError: true,
        ),
      );
    }

    try {
      final status = await _repository.getStatus();
      SportsbookEvent? event = preview ?? stateStream.value.event;
      SportsbookMarket? market = event?.market;
      Object? catalogError;
      final hasLines = market != null && market.outcomes.isNotEmpty;
      try {
        if (hasLines) {
          try {
            final fresh = await _repository.getEvent(event!.id);
            event = fresh;
            market = fresh.market ?? market;
          } catch (_) {
            // List already has MATCH_WINNER — keep it.
          }
        } else {
          final loaded = await _repository.resolveMarkets(
            eventId: eventId,
            preview: event,
          );
          event = loaded.event.id.isEmpty ? event ?? loaded.event : loaded.event;
          market = loaded.market.outcomes.isEmpty ? market : loaded.market;
        }
      } catch (e) {
        catalogError = e;
        event ??= preview;
        market ??= event?.market;
      }

      if (event == null) {
        throw catalogError ??
            const DataError(
              errorCode: ErrorCode.unhandled,
              message: SportsbookConstants.errorNotFound,
            );
      }

      final current = stateStream.value;
      var selected = current.selectedOutcomeId;
      if (selected != null && market?.byProviderId(selected) == null) {
        selected = null;
      }

      final linesError = (market == null || market.outcomes.isEmpty) &&
              catalogError != null
          ? _linesMessage(catalogError, event.id)
          : null;

      stateStream.add(
        current.copyWith(
          status: status,
          event: event,
          market: market,
          selectedOutcomeId: selected,
          stakeRsv: _clampStake(current.stakeRsv, status: status),
          isLoading: false,
          planRequired: !(status.eligible || _auth.canUseSportsbook),
          error: linesError,
          clearError: linesError == null,
          clearSelection: selected == null && current.selectedOutcomeId != null,
        ),
      );
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

  Future<void> refreshMarkets() => load(silent: true);

  Future<void> confirm() async {
    final state = stateStream.value;
    if (state.isMutating || state.acceptedBet != null) return;
    final status = state.status;
    final event = state.event;
    final market = state.market;
    final outcome = state.selectedOutcome;
    if (status == null || event == null || market == null || outcome == null) {
      stateStream.add(
        state.copyWith(message: SportsbookConstants.errorPickRequired),
      );
      return;
    }
    if (!event.canPlaceBet || !market.isOpen) {
      stateStream.add(
        state.copyWith(message: SportsbookConstants.errorEventClosed),
      );
      return;
    }
    if (!status.enabled) {
      stateStream.add(
        state.copyWith(message: SportsbookConstants.errorDisabled),
      );
      return;
    }
    if (state.stakeRsv < status.minStakeRsv) {
      stateStream.add(state.copyWith(message: SportsbookConstants.errorMinStake));
      return;
    }
    if (state.stakeRsv > status.maxStakeRsv) {
      stateStream.add(state.copyWith(message: SportsbookConstants.errorMaxStake));
      return;
    }
    if (state.stakeRsv > status.availableRsv) {
      stateStream.add(
        state.copyWith(message: SportsbookConstants.errorInsufficient),
      );
      return;
    }

    stateStream.add(state.copyWith(clearMessage: true, oddsChanged: false));

    try {
      var liveEvent = event;
      var liveMarket = market;
      var liveOutcome = outcome;
      try {
        final fresh = await _repository.getEvent(event.id);
        final freshMarket = fresh.market;
        final freshOutcome =
            freshMarket?.byProviderId(outcome.providerOutcomeId);
        if (freshMarket != null &&
            freshMarket.outcomes.isNotEmpty &&
            freshOutcome != null) {
          liveEvent = fresh;
          liveMarket = freshMarket;
          liveOutcome = freshOutcome;
        }
      } catch (_) {
        // Catalog lines from the list are enough to place.
      }
      if (!liveEvent.canPlaceBet || !liveMarket.isOpen) {
        stateStream.add(
          stateStream.value.copyWith(
            event: liveEvent,
            market: liveMarket,
            isMutating: false,
            message: SportsbookConstants.errorEventClosed,
          ),
        );
        return;
      }
      if ((liveOutcome.odds - outcome.odds).abs() > 0.05) {
        stateStream.add(
          stateStream.value.copyWith(
            event: liveEvent,
            market: liveMarket,
            isMutating: false,
            oddsChanged: true,
            message: SportsbookConstants.errorOddsChanged,
          ),
        );
        return;
      }

      final confirmed = await _navigator.confirmPlaceBet(
        outcome: liveOutcome.name,
        stake: state.stakeRsv,
        odds: liveOutcome.odds,
      );
      if (!confirmed) {
        stateStream.add(
          stateStream.value.copyWith(
            event: liveEvent,
            market: liveMarket,
            isMutating: false,
          ),
        );
        return;
      }

      stateStream.add(
        stateStream.value.copyWith(
          event: liveEvent,
          market: liveMarket,
          isMutating: true,
        ),
      );

      _retryRequestId = _retryRequestId ?? SportsbookRequestId.next();
      final bet = await _repository.placeBet(
        eventId: liveEvent.id,
        providerOutcomeId: liveOutcome.providerOutcomeId,
        stake: state.stakeRsv,
        expectedOdds: liveOutcome.odds.toDouble(),
        clientRequestId: _retryRequestId!,
      );
      _retryRequestId = null;
      await _auth.refreshBootstrap();
      final nextStatus = await _safeStatus() ??
          status.copyWithBalance(
            available: status.availableRsv - state.stakeRsv,
          );
      stateStream.add(
        stateStream.value.copyWith(
          status: nextStatus,
          event: liveEvent,
          market: liveMarket,
          acceptedBet: bet,
          isMutating: false,
          oddsChanged: false,
          clearError: true,
          clearMessage: true,
        ),
      );
    } on DataError catch (e) {
      if (e.apiError == 'odds_changed') {
        _retryRequestId = null;
        await load(silent: true);
        stateStream.add(
          stateStream.value.copyWith(
            isMutating: false,
            oddsChanged: true,
            message: SportsbookConstants.errorOddsChanged,
          ),
        );
        return;
      }
      if (e.errorCode != ErrorCode.network) {
        _retryRequestId = null;
      }
      stateStream.add(
        stateStream.value.copyWith(
          isMutating: false,
          message: SportsbookRepository.mapError(e),
        ),
      );
    } catch (e) {
      stateStream.add(
        stateStream.value.copyWith(
          isMutating: false,
          message: SportsbookRepository.mapError(e),
        ),
      );
    }
  }

  Future<SportsbookStatus?> _safeStatus() async {
    try {
      return await _repository.getStatus();
    } catch (_) {
      return null;
    }
  }

  String _linesMessage(Object error, String eventId) {
    if (SportsbookRepository.isProviderUnavailable(error)) {
      return SportsbookConstants.errorProvider;
    }
    if (SportsbookRepository.isMissingResource(error)) {
      return SportsbookConstants.errorLinesMissing;
    }
    return SportsbookRepository.mapError(error);
  }

  double _clampStake(double value, {SportsbookStatus? status}) {
    final current = status ?? stateStream.value.status;
    if (current == null) {
      return value.clamp(
        SportsbookConstants.minStakeRsv,
        SportsbookConstants.maxStakeRsv,
      );
    }
    final min = current.minStakeRsv.toDouble();
    final max = current.stakeCeiling.toDouble();
    if (max <= min) return min;
    return value.clamp(min, max).toDouble();
  }

  @override
  void dispose() {
    stateStream.close();
    super.dispose();
  }
}
