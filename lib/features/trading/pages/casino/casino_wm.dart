import 'package:rxdart/rxdart.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../../core/constants/casino_constants.dart';
import '../../../../core/errors/data_error.dart';
import '../../../../core/mwwm/widget_model.dart';
import '../../models/casino_model.dart';
import '../../repositories/casino_repository.dart';
import 'navigation/casino_navigator.dart';

class CasinoHomeState {
  const CasinoHomeState({
    this.status,
    this.balance,
    this.games = const [],
    this.history = const [],
    this.stats,
    this.currency = CasinoConstants.currencyDemo,
    this.isLoading = true,
    this.isMutating = false,
    this.error,
    this.message,
    this.needsAuth = false,
    this.planRequired = false,
  });

  final CasinoStatus? status;
  final CasinoBalance? balance;
  final List<CasinoGame> games;
  final List<CasinoHistoryItem> history;
  final CasinoStats? stats;
  final String currency;
  final bool isLoading;
  final bool isMutating;
  final String? error;
  final String? message;
  final bool needsAuth;
  final bool planRequired;

  CasinoHomeState copyWith({
    CasinoStatus? status,
    CasinoBalance? balance,
    List<CasinoGame>? games,
    List<CasinoHistoryItem>? history,
    CasinoStats? stats,
    String? currency,
    bool? isLoading,
    bool? isMutating,
    String? error,
    String? message,
    bool? needsAuth,
    bool? planRequired,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return CasinoHomeState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      games: games ?? this.games,
      history: history ?? this.history,
      stats: stats ?? this.stats,
      currency: currency ?? this.currency,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
      needsAuth: needsAuth ?? this.needsAuth,
      planRequired: planRequired ?? this.planRequired,
    );
  }
}

class CasinoWidgetModel extends WidgetModel {
  CasinoWidgetModel({
    required AuthSession auth,
    required CasinoRepository repository,
    required CasinoNavigator navigator,
  })  : _auth = auth,
        _repository = repository,
        _navigator = navigator,
        super(const WidgetModelDependencies());

  final AuthSession _auth;
  final CasinoRepository _repository;
  final CasinoNavigator _navigator;

  final BehaviorSubject<CasinoHomeState> stateStream =
      BehaviorSubject.seeded(const CasinoHomeState());

  @override
  void onLoad() {
    super.onLoad();
    _seedFromBootstrap();
    load();
  }

  void clearMessage() {
    stateStream.add(stateStream.value.copyWith(clearMessage: true));
  }

  void setCurrency(String currency) {
    stateStream.add(
      stateStream.value.copyWith(currency: currency.toUpperCase()),
    );
  }

  void openSubscriptions() => _navigator.goToSubscriptions();

  void openProfile() => _navigator.goToProfile();

  void openGame(CasinoGame game) => _navigator.openGame(game.gameId);

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
      var balance = status.balance;
      balance ??= await _repository.getBalance();
      var games = status.activeGames;
      if (games.isEmpty) {
        games = (await _repository.getGames())
            .where((g) => g.isActive)
            .toList(growable: false);
      }

      CasinoStats? stats;
      List<CasinoHistoryItem> history = stateStream.value.history;
      try {
        stats = await _repository.getStats();
        history = await _repository.getHistory();
      } catch (_) {}

      stateStream.add(
        stateStream.value.copyWith(
          status: status,
          balance: balance,
          games: games,
          stats: stats,
          history: history,
          isLoading: false,
          planRequired: !(status.eligible || _auth.canUseCasino),
          clearError: true,
        ),
      );
    } on DataError catch (e) {
      if (e.apiError == 'plan_required' ||
          (e.errorCode == ErrorCode.forbidden && !_auth.canUseCasino)) {
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
          error: CasinoRepository.mapError(e),
        ),
      );
    } catch (e) {
      stateStream.add(
        stateStream.value.copyWith(
          isLoading: false,
          error: CasinoRepository.mapError(e),
        ),
      );
    }
  }

  Future<void> resetDemo() async {
    stateStream.add(
      stateStream.value.copyWith(isMutating: true, clearMessage: true),
    );
    try {
      final credits = await _repository.resetDemo();
      final balance = stateStream.value.balance?.copyWithDemo(credits) ??
          CasinoBalance(
            demo: CasinoDemoBalance(available: credits),
          );
      stateStream.add(
        stateStream.value.copyWith(
          balance: balance,
          isMutating: false,
          message: 'Demo сброшен до ${CasinoConstants.demo(credits)}',
        ),
      );
    } catch (e) {
      stateStream.add(
        stateStream.value.copyWith(
          isMutating: false,
          message: CasinoRepository.mapError(e),
        ),
      );
    }
  }

  void _seedFromBootstrap() {
    final dto = _auth.bootstrap?.casino;
    if (dto == null) {
      stateStream.add(
        stateStream.value.copyWith(
          planRequired: !_auth.canUseCasino,
          isLoading: true,
        ),
      );
      return;
    }
    final status = CasinoStatus.fromDto(dto);
    stateStream.add(
      stateStream.value.copyWith(
        status: status,
        balance: status.balance,
        games: status.activeGames,
        isLoading: true,
        planRequired: !(status.eligible || _auth.canUseCasino),
      ),
    );
  }

  @override
  void dispose() {
    stateStream.close();
    super.dispose();
  }
}
