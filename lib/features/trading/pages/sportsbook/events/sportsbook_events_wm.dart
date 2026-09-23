import 'package:rxdart/rxdart.dart';

import '../../../../../core/auth/auth_session.dart';
import '../../../../../core/errors/data_error.dart';
import '../../../../../core/mwwm/widget_model.dart';
import '../../../models/sportsbook_model.dart';
import '../../../repositories/sportsbook_repository.dart';
import '../navigation/sportsbook_navigator.dart';

class SportsbookEventsState {
  const SportsbookEventsState({
    this.status,
    this.events = const [],
    this.isLoading = true,
    this.error,
    this.needsAuth = false,
    this.planRequired = false,
  });

  final SportsbookStatus? status;
  final List<SportsbookEvent> events;
  final bool isLoading;
  final String? error;
  final bool needsAuth;
  final bool planRequired;

  SportsbookEventsState copyWith({
    SportsbookStatus? status,
    List<SportsbookEvent>? events,
    bool? isLoading,
    String? error,
    bool? needsAuth,
    bool? planRequired,
    bool clearError = false,
  }) {
    return SportsbookEventsState(
      status: status ?? this.status,
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      needsAuth: needsAuth ?? this.needsAuth,
      planRequired: planRequired ?? this.planRequired,
    );
  }
}

class SportsbookEventsWidgetModel extends WidgetModel {
  SportsbookEventsWidgetModel({
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

  final BehaviorSubject<SportsbookEventsState> stateStream =
      BehaviorSubject.seeded(const SportsbookEventsState());

  @override
  void onLoad() {
    super.onLoad();
    load();
  }

  void openSubscriptions() => _navigator.goToSubscriptions();

  void openProfile() => _navigator.goToProfile();

  void openEvent(SportsbookEvent event) => _navigator.goToEvent(event);

  Future<void> load() async {
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

    stateStream.add(
      stateStream.value.copyWith(
        isLoading: stateStream.value.events.isEmpty,
        needsAuth: false,
        clearError: true,
      ),
    );

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
          error: eventsError,
          clearError: eventsError == null,
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

  @override
  void dispose() {
    stateStream.close();
    super.dispose();
  }
}
