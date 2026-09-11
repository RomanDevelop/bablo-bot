import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../core/auth/auth_session.dart';
import '../../../../../core/constants/casino_constants.dart';
import '../../../../../core/errors/data_error.dart';
import '../../../../../core/mwwm/widget_model.dart';
import '../../../models/casino_model.dart';
import '../../../repositories/casino_repository.dart';
import '../casino_event_player.dart';
import '../casino_request_id.dart';
import '../navigation/casino_navigator.dart';

class CasinoGameState {
  const CasinoGameState({
    this.game,
    this.session,
    this.balance,
    this.board = const [],
    this.highlightPositions = const [],
    this.removedPositions = const [],
    this.multiplier = 1,
    this.lastWin = 0,
    this.statusLine,
    this.currency = CasinoConstants.currencyDemo,
    this.bet = 1,
    this.turbo = false,
    this.isLoading = true,
    this.isSpinning = false,
    this.isPlayingEvents = false,
    this.canRetry = false,
    this.forcedScenario,
    this.error,
    this.message,
    this.needsAuth = false,
    this.planRequired = false,
  });

  final CasinoGame? game;
  final CasinoSession? session;
  final CasinoBalance? balance;
  final List<List<String>> board;
  final List<List<int>> highlightPositions;
  final List<List<int>> removedPositions;
  final num multiplier;
  final num lastWin;
  final String? statusLine;
  final String currency;
  final double bet;
  final bool turbo;
  final bool isLoading;
  final bool isSpinning;
  final bool isPlayingEvents;
  final bool canRetry;
  final String? forcedScenario;
  final String? error;
  final String? message;
  final bool needsAuth;
  final bool planRequired;

  bool get busy => isSpinning || isPlayingEvents;

  bool get requiresRespin => session?.requiresRespin ?? false;

  bool get betLocked => session?.isBonusMode ?? false;

  CasinoGameState copyWith({
    CasinoGame? game,
    CasinoSession? session,
    CasinoBalance? balance,
    List<List<String>>? board,
    List<List<int>>? highlightPositions,
    List<List<int>>? removedPositions,
    num? multiplier,
    num? lastWin,
    String? statusLine,
    String? currency,
    double? bet,
    bool? turbo,
    bool? isLoading,
    bool? isSpinning,
    bool? isPlayingEvents,
    bool? canRetry,
    String? forcedScenario,
    String? error,
    String? message,
    bool? needsAuth,
    bool? planRequired,
    bool clearError = false,
    bool clearMessage = false,
    bool clearForced = false,
    bool clearStatus = false,
  }) {
    return CasinoGameState(
      game: game ?? this.game,
      session: session ?? this.session,
      balance: balance ?? this.balance,
      board: board ?? this.board,
      highlightPositions: highlightPositions ?? this.highlightPositions,
      removedPositions: removedPositions ?? this.removedPositions,
      multiplier: multiplier ?? this.multiplier,
      lastWin: lastWin ?? this.lastWin,
      statusLine: clearStatus ? null : (statusLine ?? this.statusLine),
      currency: currency ?? this.currency,
      bet: bet ?? this.bet,
      turbo: turbo ?? this.turbo,
      isLoading: isLoading ?? this.isLoading,
      isSpinning: isSpinning ?? this.isSpinning,
      isPlayingEvents: isPlayingEvents ?? this.isPlayingEvents,
      canRetry: canRetry ?? this.canRetry,
      forcedScenario:
          clearForced ? null : (forcedScenario ?? this.forcedScenario),
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
      needsAuth: needsAuth ?? this.needsAuth,
      planRequired: planRequired ?? this.planRequired,
    );
  }
}

class CasinoGameWidgetModel extends WidgetModel {
  CasinoGameWidgetModel({
    required this.gameId,
    required AuthSession auth,
    required CasinoRepository repository,
    required CasinoNavigator navigator,
    CasinoEventPlayer eventPlayer = const CasinoEventPlayer(),
  })  : _auth = auth,
        _repository = repository,
        _navigator = navigator,
        _eventPlayer = eventPlayer,
        super(const WidgetModelDependencies());

  final String gameId;
  final AuthSession _auth;
  final CasinoRepository _repository;
  final CasinoNavigator _navigator;
  final CasinoEventPlayer _eventPlayer;

  final BehaviorSubject<CasinoGameState> stateStream =
      BehaviorSubject.seeded(const CasinoGameState());

  String? _inFlightRequestId;

  @override
  void onLoad() {
    super.onLoad();
    load();
  }

  void clearMessage() {
    stateStream.add(stateStream.value.copyWith(clearMessage: true));
  }

  void setCurrency(String currency) {
    if (stateStream.value.betLocked || stateStream.value.busy) return;
    stateStream.add(
      stateStream.value.copyWith(
        currency: currency.toUpperCase(),
        session: null,
      ),
    );
  }

  void setBet(double bet) {
    if (stateStream.value.betLocked || stateStream.value.busy) return;
    stateStream.add(stateStream.value.copyWith(bet: bet));
  }

  void setTurbo(bool value) {
    stateStream.add(stateStream.value.copyWith(turbo: value));
  }

  void setForcedScenario(String? scenario) {
    if (!kDebugMode) return;
    stateStream.add(
      stateStream.value.copyWith(
        forcedScenario: scenario,
        clearForced: scenario == null,
      ),
    );
  }

  void openSubscriptions() => _navigator.goToSubscriptions();

  void openProfile() => _navigator.goToProfile();

  Future<void> load() async {
    if (!_auth.isAuthenticated) {
      stateStream.add(
        stateStream.value.copyWith(
          isLoading: false,
          needsAuth: true,
          clearError: true,
        ),
      );
      return;
    }

    stateStream.add(
      stateStream.value.copyWith(isLoading: true, needsAuth: false),
    );

    try {
      final game = await _repository.getGame(gameId);
      final balance = await _repository.getBalance();
      final steps = game.steps;
      final bet = steps.isEmpty ? 1.0 : steps.first.toDouble();

      CasinoSession? session;
      final status = await _repository.getStatus();
      final active = status.activeSession;
      if (active != null &&
          active.gameId == gameId &&
          active.isActive) {
        session = active;
      }

      stateStream.add(
        stateStream.value.copyWith(
          game: game,
          balance: balance,
          session: session,
          currency: session?.currency ?? CasinoConstants.currencyDemo,
          bet: session?.isBonusMode == true
              ? (session?.bonusState?.bet.toDouble() ?? bet)
              : bet,
          board: _emptyBoard(game),
          isLoading: false,
          planRequired: !(status.eligible || _auth.canUseCasino),
          clearError: true,
        ),
      );
    } on DataError catch (e) {
      if (e.apiError == 'plan_required') {
        stateStream.add(
          stateStream.value.copyWith(
            isLoading: false,
            planRequired: true,
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

  Future<void> spinOrRespin() async {
    final state = stateStream.value;
    if (state.busy || state.game == null) return;

    if (state.canRetry && _inFlightRequestId != null) {
      await _executeSpin(clientRequestId: _inFlightRequestId!);
      return;
    }

    final currency = state.currency.toUpperCase();
    if (currency == CasinoConstants.currencyRsv) {
      final balance = state.balance;
      if (balance != null) {
        final ok = await _navigator.confirmRsvBet(
          balance: balance,
          bet: state.bet,
        );
        if (!ok) return;
      }
    }

    _inFlightRequestId = CasinoRequestId.next();
    await _executeSpin(clientRequestId: _inFlightRequestId!);
  }

  Future<void> retrySameRequest() async {
    final id = _inFlightRequestId;
    if (id == null) return;
    await _executeSpin(clientRequestId: id);
  }

  Future<void> _executeSpin({required String clientRequestId}) async {
    final state = stateStream.value;
    final game = state.game;
    if (game == null) return;

    final action = state.requiresRespin
        ? CasinoConstants.actionRespin
        : CasinoConstants.actionSpin;

    stateStream.add(
      stateStream.value.copyWith(
        isSpinning: true,
        canRetry: false,
        highlightPositions: const [],
        removedPositions: const [],
        clearError: true,
        clearMessage: true,
        statusLine: action == CasinoConstants.actionRespin
            ? 'Respin…'
            : 'Spin…',
      ),
    );

    try {
      var sessionId = state.session?.id;
      if (sessionId == null || sessionId.isEmpty) {
        final session = await _repository.startSession(
          gameId: game.gameId,
          currency: state.currency,
        );
        sessionId = session.id;
        stateStream.add(stateStream.value.copyWith(session: session));
      }

      final result = await _repository.spin(
        gameId: game.gameId,
        bet: state.bet,
        currency: state.currency,
        action: action,
        clientRequestId: clientRequestId,
        sessionId: sessionId,
        forcedScenario: kDebugMode ? state.forcedScenario : null,
      );

      _inFlightRequestId = null;

      stateStream.add(
        stateStream.value.copyWith(
          isSpinning: false,
          isPlayingEvents: true,
          canRetry: false,
          session: result.session ??
              stateStream.value.session?.copyWithNext(
                nextAction: result.nextAction,
                bonusState: result.bonusState,
              ),
        ),
      );

      await _eventPlayer.play(
        events: result.events,
        turbo: stateStream.value.turbo,
        onEvent: _applyEvent,
      );

      final balance = stateStream.value.balance;
      CasinoBalance? nextBalance = balance;
      if (balance != null) {
        if (result.currency.toUpperCase() == CasinoConstants.currencyRsv) {
          nextBalance = balance.copyWithAvailable(
            rsvAvailable: result.balanceAfter,
          );
        } else {
          nextBalance = balance.copyWithAvailable(
            demoAvailable: result.balanceAfter,
          );
        }
      }

      final session = result.session ??
          (result.sessionId.isEmpty
              ? stateStream.value.session
              : CasinoSession(
                  id: result.sessionId,
                  gameId: result.gameId,
                  currency: result.currency,
                  nextAction: result.nextAction,
                  bonusState: result.bonusState,
                  status: 'ACTIVE',
                ));

      stateStream.add(
        stateStream.value.copyWith(
          isPlayingEvents: false,
          balance: nextBalance,
          session: session,
          board: result.board.isNotEmpty
              ? result.board
              : stateStream.value.board,
          lastWin: result.totalWin,
          multiplier: result.multiplier,
          statusLine: result.hasWin
              ? 'Win ${CasinoConstants.amount(result.totalWin)}'
              : 'No win',
        ),
      );

      if (result.currency.toUpperCase() == CasinoConstants.currencyRsv) {
        await _auth.refreshBootstrap();
      }
    } on DataError catch (e) {
      final networkish = e.errorCode == ErrorCode.network ||
          e.errorCode == ErrorCode.unhandled;
      stateStream.add(
        stateStream.value.copyWith(
          isSpinning: false,
          isPlayingEvents: false,
          canRetry: networkish && _inFlightRequestId != null,
          message: CasinoRepository.mapError(e),
          statusLine: networkish ? 'Network error — Retry' : null,
        ),
      );
      if (e.apiError == 'session_not_found' ||
          e.apiError == 'session_inactive') {
        stateStream.add(stateStream.value.copyWith(session: null));
      }
    } catch (e) {
      stateStream.add(
        stateStream.value.copyWith(
          isSpinning: false,
          isPlayingEvents: false,
          canRetry: _inFlightRequestId != null,
          message: CasinoRepository.mapError(e),
        ),
      );
    }
  }

  Future<void> _applyEvent(CasinoEvent event) async {
    if (isDisposed) return;
    final type = event.type;
    final data = event.data;

    switch (type) {
      case CasinoConstants.eventBoardGenerated:
      case CasinoConstants.eventNewSymbolsDropped:
        final board = event.boardFromData;
        stateStream.add(
          stateStream.value.copyWith(
            board: board ?? stateStream.value.board,
            removedPositions: const [],
            statusLine: type == CasinoConstants.eventNewSymbolsDropped
                ? 'New symbols'
                : 'Board ready',
          ),
        );
      case CasinoConstants.eventWinDetected:
        final positions = _positionsFrom(data['positions']);
        stateStream.add(
          stateStream.value.copyWith(
            highlightPositions: positions,
            lastWin: asNumSafe(data['payout'], stateStream.value.lastWin),
            statusLine:
                'Win line ${data['payline_id'] ?? data['symbol'] ?? ''}',
          ),
        );
      case CasinoConstants.eventNoWin:
        stateStream.add(
          stateStream.value.copyWith(
            highlightPositions: const [],
            statusLine: 'No win',
          ),
        );
      case CasinoConstants.eventSymbolsRemoved:
        stateStream.add(
          stateStream.value.copyWith(
            removedPositions: _positionsFrom(data['positions']),
            statusLine: 'Cascade remove',
          ),
        );
      case CasinoConstants.eventMultiplierChanged:
        stateStream.add(
          stateStream.value.copyWith(
            multiplier: asNumSafe(data['multiplier'], stateStream.value.multiplier),
            statusLine: '×${data['multiplier'] ?? ''}',
          ),
        );
      case CasinoConstants.eventCascadeStarted:
        stateStream.add(
          stateStream.value.copyWith(
            statusLine: 'Cascade #${data['cascade_index'] ?? ''}',
          ),
        );
      case CasinoConstants.eventBonusTriggered:
        stateStream.add(
          stateStream.value.copyWith(statusLine: 'Hold & Win bonus!'),
        );
      case CasinoConstants.eventCoinLocked:
        stateStream.add(
          stateStream.value.copyWith(
            statusLine: 'Coin locked ${data['value'] ?? ''}',
          ),
        );
      case CasinoConstants.eventRespinsReset:
        stateStream.add(
          stateStream.value.copyWith(statusLine: 'Respins reset'),
        );
      case CasinoConstants.eventBonusCompleted:
        stateStream.add(
          stateStream.value.copyWith(
            statusLine:
                'Bonus done · ${CasinoConstants.amount(asNumSafe(data['payout']))}',
          ),
        );
      case CasinoConstants.eventWinCredited:
        stateStream.add(
          stateStream.value.copyWith(
            statusLine:
                'Credited ${CasinoConstants.amount(asNumSafe(data['amount']))}',
          ),
        );
      case CasinoConstants.eventBetAccepted:
        stateStream.add(
          stateStream.value.copyWith(statusLine: 'Bet accepted'),
        );
      case CasinoConstants.eventSpinCompleted:
        stateStream.add(
          stateStream.value.copyWith(statusLine: 'Round complete'),
        );
      default:
        stateStream.add(
          stateStream.value.copyWith(statusLine: type),
        );
    }
  }

  List<List<String>> _emptyBoard(CasinoGame game) {
    return List.generate(
      game.boardRows,
      (_) => List.filled(game.boardCols, '·'),
    );
  }

  List<List<int>> _positionsFrom(dynamic raw) {
    if (raw is! List) return const [];
    final out = <List<int>>[];
    for (final p in raw) {
      if (p is List && p.length >= 2) {
        out.add([
          int.tryParse(p[0].toString()) ?? 0,
          int.tryParse(p[1].toString()) ?? 0,
        ]);
      }
    }
    return out;
  }

  num asNumSafe(dynamic value, [num fallback = 0]) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? fallback;
    return fallback;
  }

  @override
  void dispose() {
    stateStream.close();
    super.dispose();
  }
}

extension on CasinoSession {
  CasinoSession copyWithNext({
    required String nextAction,
    CasinoBonusState? bonusState,
  }) {
    return CasinoSession(
      id: id,
      gameId: gameId,
      gameVersion: gameVersion,
      currency: currency,
      status: status,
      state: state,
      bonusState: bonusState ?? this.bonusState,
      nextAction: nextAction,
      totalWagered: totalWagered,
      totalWon: totalWon,
      startedAt: startedAt,
      updatedAt: updatedAt,
    );
  }
}
