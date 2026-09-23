import 'package:rxdart/rxdart.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../../core/errors/data_error.dart';
import '../../../../core/mwwm/widget_model.dart';
import '../../models/sportsbook_model.dart';
import '../../repositories/sportsbook_repository.dart';
import 'navigation/sportsbook_navigator.dart';

class SportsbookHubState {
  const SportsbookHubState({
    this.status,
    this.events = const [],
    this.isLoading = true,
    this.eventsError,
    this.error,
    this.message,
    this.needsAuth = false,
    this.planRequired = false,
  });

  final SportsbookStatus? status;
  final List<SportsbookEvent> events;
  final bool isLoading;
  final String? eventsError;
  final String? error;
  final String? message;
  final bool needsAuth;
  final bool planRequired;

  bool get isDisabled => status != null && !status!.enabled;

  SportsbookHubState copyWith({
    SportsbookStatus? status,
    List<SportsbookEvent>? events,
    bool? isLoading,
    String? eventsError,
    String? error,
    String? message,
    bool? needsAuth,
    bool? planRequired,
    bool clearError = false,
    bool clearMessage = false,
    bool clearEventsError = false,
  }) {
    return SportsbookHubState(
      status: status ?? this.status,
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      eventsError:
          clearEventsError ? null : (eventsError ?? this.eventsError),
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
      needsAuth: needsAuth ?? this.needsAuth,
      planRequired: planRequired ?? this.planRequired,
    );
  }
}

class SportsbookWidgetModel extends WidgetModel {
  SportsbookWidgetModel({
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

  final BehaviorSubject<SportsbookHubState> stateStream =
      BehaviorSubject.seeded(const SportsbookHubState());

  @override
  void onLoad() {
    super.onLoad();
    _seedFromBootstrap();
    load();
  }

  void clearMessage() {
    stateStream.add(stateStream.value.copyWith(clearMessage: true));
  }

  void openSubscriptions() => _navigator.goToSubscriptions();

  void openProfile() => _navigator.goToProfile();

  void openEvents() => _navigator.goToEvents();

  void openEvent(SportsbookEvent event) => _navigator.goToEvent(event);

  void openHistory() => _navigator.goToHistory();

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
      var events = const <SportsbookEvent>[];
      String? eventsError;
      try {
        events = await _repository.getEvents();
      } catch (e) {
        if (!SportsbookRepository.isMissingResource(e)) {
          eventsError = SportsbookRepository.mapError(e);
        }
      }
      stateStream.add(
        stateStream.value.copyWith(
          status: status,
          events: events,
          isLoading: false,
          planRequired: !(status.eligible || _auth.canUseSportsbook),
          eventsError: eventsError,
          clearError: true,
          clearEventsError: eventsError == null,
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

  void _seedFromBootstrap() {
    final dto = _auth.bootstrap?.sportsbook;
    if (dto == null) {
      stateStream.add(
        stateStream.value.copyWith(
          planRequired: !_auth.canUseSportsbook,
          isLoading: true,
        ),
      );
      return;
    }
    final status = SportsbookStatus.fromDto(dto);
    stateStream.add(
      stateStream.value.copyWith(
        status: status,
        isLoading: true,
        planRequired: !(status.eligible || _auth.canUseSportsbook),
      ),
    );
  }

  @override
  void dispose() {
    stateStream.close();
    super.dispose();
  }
}
