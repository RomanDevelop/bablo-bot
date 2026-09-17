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
  }) : _auth = auth,
       _repository = repository,
       _navigator = navigator,
       _eventPlayer = eventPlayer,
       super(const WidgetModelDependencies());

  final String gameId;
  final AuthSession _auth;
  final CasinoRepository _repository;
  final CasinoNavigator _navigator;
  final CasinoEventPlayer _eventPlayer;

  final BehaviorSubject<CasinoGameState> stateStream = BehaviorSubject.seeded(
    const CasinoGameState(),
  );

  String? _inFlightRequestId;
  List<List<String>> _pendingBoard = const [];

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
          active.isActive &&
          _isUuid(active.id)) {
        session = active;
      }

      final current = stateStream.value;
      stateStream.add(
        CasinoGameState(
          game: game,
          session: session,
          balance: balance,
          board: _emptyBoard(game),
          currency: session?.currency ?? CasinoConstants.currencyDemo,
          bet:
              session != null && session.isBonusMode
                  ? (session.bonusState?.bet.toDouble() ?? bet)
                  : bet,
          turbo: current.turbo,
          forcedScenario: current.forcedScenario,
          isLoading: false,
          planRequired: !(status.eligible || _auth.canUseCasino),
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
    if (state.busy) {
      stateStream.add(
        state.copyWith(statusLine: 'Busy — wait for current spin'),
      );
      return;
    }
    if (state.game == null) {
      stateStream.add(
        state.copyWith(
          error: 'Игра ещё не загрузилась',
          message: 'Игра ещё не загрузилась',
          statusLine: 'Game not loaded',
        ),
      );
      return;
    }

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

    // Do not pre-create session: POST /spin creates one when session_id is omitted.
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

    final action =
        state.requiresRespin
            ? CasinoConstants.actionRespin
            : CasinoConstants.actionSpin;

    final spinStartedAt = DateTime.now();
    stateStream.add(
      stateStream.value.copyWith(
        isSpinning: true,
        isPlayingEvents: false,
        canRetry: false,
        highlightPositions: const [],
        removedPositions: const [],
        lastWin: 0,
        clearError: true,
        clearMessage: true,
        statusLine:
            action == CasinoConstants.actionRespin ? 'Respin...' : 'Spin...',
      ),
    );

    try {
      // Regular SPIN must not send a stale session_id (404/422, board never
      // arrives). RESPIN keeps the bonus session UUID.
      final rawSessionId = state.session?.id.trim();
      final sessionId =
          action == CasinoConstants.actionRespin &&
                  rawSessionId != null &&
                  _isUuid(rawSessionId)
              ? rawSessionId
              : null;

      final resolvedGameId =
          game.gameId.trim().isEmpty ? gameId : game.gameId.trim();

      stateStream.add(
        stateStream.value.copyWith(statusLine: 'Sending spin...'),
      );

      final result = await _repository.spin(
        gameId: resolvedGameId,
        bet: state.bet,
        currency: state.currency,
        action: action,
        clientRequestId: clientRequestId,
        sessionId: sessionId,
        forcedScenario: kDebugMode ? state.forcedScenario : null,
      );

      if (result.spinId.isEmpty &&
          result.board.isEmpty &&
          result.events.isEmpty) {
        throw DataError(
          errorCode: ErrorCode.unhandled,
          message: 'Пустой ответ spin (нет spin_id/board/events). Проверь API.',
        );
      }

      _inFlightRequestId = null;

      final minMs = stateStream.value.turbo ? 480 : 1050;
      final elapsed = DateTime.now().difference(spinStartedAt).inMilliseconds;
      if (elapsed < minMs && !isDisposed) {
        await Future<void>.delayed(Duration(milliseconds: minMs - elapsed));
      }

      // Snapshot board once — never let later empty event payloads wipe it.
      var spunBoard = result.board
          .map((row) => List<String>.from(row))
          .toList(growable: false);
      if (spunBoard.isEmpty) {
        for (final event in result.events) {
          final fromEvent = event.boardFromData;
          if (fromEvent != null && fromEvent.isNotEmpty) {
            spunBoard = fromEvent
                .map((row) => List<String>.from(row))
                .toList(growable: false);
            break;
          }
        }
      }

      // Balance FIRST — UI must never stay frozen if event playback fails.
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

      final session =
          result.session ??
          (result.sessionId.isEmpty || !_isUuid(result.sessionId)
              ? stateStream.value.session
              : CasinoSession(
                id: result.sessionId,
                gameId: result.gameId,
                currency: result.currency,
                nextAction: result.nextAction,
                bonusState: result.bonusState,
                status: 'ACTIVE',
              ));

      if (isDisposed) return;

      final finalBoard =
          spunBoard.isNotEmpty ? spunBoard : stateStream.value.board;
      _pendingBoard = finalBoard;
      final hasBoardEvent = result.events.any(
        (e) => e.type == CasinoConstants.eventBoardGenerated,
      );

      // Keep reels spinning until BOARD_GENERATED lands them.
      stateStream.add(
        stateStream.value.copyWith(
          isSpinning: true,
          isPlayingEvents: result.events.isNotEmpty,
          canRetry: false,
          balance: nextBalance,
          session: session,
          lastWin: 0,
          multiplier: result.multiplier,
          statusLine: 'Reels...',
          highlightPositions: const [],
          removedPositions: const [],
          clearError: true,
          clearMessage: true,
        ),
      );

      if (!hasBoardEvent) {
        stateStream.add(
          stateStream.value.copyWith(
            isSpinning: false,
            board: finalBoard,
            lastWin: result.totalWin,
            statusLine: _boardStatus(finalBoard, result),
          ),
        );
        final landMs = stateStream.value.turbo ? 420 : 980;
        if (!isDisposed) {
          await Future<void>.delayed(Duration(milliseconds: landMs));
        }
      }

      if (result.events.isNotEmpty) {
        try {
          await _eventPlayer.play(
            events: result.events,
            turbo: stateStream.value.turbo,
            onEvent: _applyEvent,
          );
        } catch (_) {
          // Board/balance already on screen.
        }
      }

      if (isDisposed) return;

      stateStream.add(
        stateStream.value.copyWith(
          isSpinning: false,
          isPlayingEvents: false,
          balance: nextBalance,
          session: session,
          board: finalBoard,
          lastWin: result.totalWin,
          multiplier: result.multiplier,
          statusLine: _boardStatus(finalBoard, result),
          clearError: true,
          clearMessage: true,
        ),
      );

      if (result.currency.toUpperCase() == CasinoConstants.currencyRsv) {
        await _auth.refreshBootstrap();
      }
    } on DataError catch (e) {
      final networkish =
          e.errorCode == ErrorCode.network ||
          e.errorCode == ErrorCode.unhandled;
      final mapped = CasinoRepository.mapError(e);
      stateStream.add(
        stateStream.value.copyWith(
          isSpinning: false,
          isPlayingEvents: false,
          canRetry: networkish && _inFlightRequestId != null,
          error: mapped,
          message: mapped,
          statusLine: mapped,
        ),
      );
      if (e.apiError == 'session_not_found' ||
          e.apiError == 'session_inactive' ||
          mapped.contains('session_id') ||
          mapped.toLowerCase().contains('uuid')) {
        _clearSession();
      }
    } catch (e) {
      final mapped = CasinoRepository.mapError(e);
      stateStream.add(
        stateStream.value.copyWith(
          isSpinning: false,
          isPlayingEvents: false,
          canRetry: _inFlightRequestId != null,
          error: mapped,
          message: mapped,
          statusLine: mapped,
        ),
      );
    }
  }

  void _clearSession() {
    final current = stateStream.value;
    stateStream.add(
      CasinoGameState(
        game: current.game,
        session: null,
        balance: current.balance,
        board: current.board,
        highlightPositions: current.highlightPositions,
        removedPositions: current.removedPositions,
        multiplier: current.multiplier,
        lastWin: current.lastWin,
        statusLine: current.statusLine,
        currency: current.currency,
        bet: current.bet,
        turbo: current.turbo,
        isLoading: current.isLoading,
        isSpinning: current.isSpinning,
        isPlayingEvents: current.isPlayingEvents,
        canRetry: current.canRetry,
        forcedScenario: current.forcedScenario,
        error: current.error,
        message: current.message,
        needsAuth: current.needsAuth,
        planRequired: current.planRequired,
      ),
    );
  }

  static bool _isUuid(String value) {
    if (value.length != 36) return false;
    for (var i = 0; i < 36; i++) {
      final c = value.codeUnitAt(i);
      if (i == 8 || i == 13 || i == 18 || i == 23) {
        if (c != 0x2D) return false;
        continue;
      }
      final hex =
          (c >= 0x30 && c <= 0x39) ||
          (c >= 0x61 && c <= 0x66) ||
          (c >= 0x41 && c <= 0x46);
      if (!hex) return false;
    }
    return true;
  }

  Future<void> _applyEvent(CasinoEvent event) async {
    if (isDisposed) return;
    final type = event.type;
    final data = event.data;

    switch (type) {
      case CasinoConstants.eventBoardGenerated:
      case CasinoConstants.eventNewSymbolsDropped:
        final board = event.boardFromData;
        final nextBoard =
            (board != null && board.isNotEmpty)
                ? board
                : (_pendingBoard.isNotEmpty
                    ? _pendingBoard
                    : stateStream.value.board);
        stateStream.add(
          stateStream.value.copyWith(
            isSpinning: false,
            board: nextBoard,
            removedPositions: const [],
            statusLine:
                type == CasinoConstants.eventNewSymbolsDropped
                    ? 'New symbols'
                    : 'Board ready',
          ),
        );
      case CasinoConstants.eventWinDetected:
        final positions = _positionsFrom(data['positions']);
        stateStream.add(
          stateStream.value.copyWith(
            isSpinning: false,
            highlightPositions: positions,
            lastWin: asNumSafe(data['payout'], stateStream.value.lastWin),
            statusLine:
                'Win line ${data['payline_id'] ?? data['symbol'] ?? ''}',
          ),
        );
      case CasinoConstants.eventNoWin:
        stateStream.add(
          stateStream.value.copyWith(
            isSpinning: false,
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
            multiplier: asNumSafe(
              data['multiplier'],
              stateStream.value.multiplier,
            ),
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
        stateStream.add(stateStream.value.copyWith(statusLine: 'Bet accepted'));
      case CasinoConstants.eventSpinCompleted:
        stateStream.add(
          stateStream.value.copyWith(statusLine: 'Round complete'),
        );
      default:
        stateStream.add(stateStream.value.copyWith(statusLine: type));
    }
  }

  String _boardStatus(List<List<String>> board, CasinoSpinResult result) {
    if (board.isEmpty) return 'No win';
    return result.hasWin
        ? 'Win ${CasinoConstants.amount(result.totalWin)}'
        : 'No win';
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
