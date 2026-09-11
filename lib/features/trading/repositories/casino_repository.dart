import '../../../core/constants/casino_constants.dart';
import '../../../core/errors/data_error.dart';
import '../data_providers/casino_data_provider.dart';
import '../models/casino_model.dart';

class CasinoRepository {
  CasinoRepository({required CasinoDataProviderInterface dataProvider})
      : _dataProvider = dataProvider;

  final CasinoDataProviderInterface _dataProvider;

  Future<CasinoStatus> getStatus() async {
    final dto = await _dataProvider.getStatus();
    return CasinoStatus.fromDto(dto);
  }

  Future<CasinoBalance> getBalance() async {
    final dto = await _dataProvider.getBalance();
    return CasinoBalance.fromDto(dto);
  }

  Future<num> resetDemo() => _dataProvider.resetDemo();

  Future<List<CasinoGame>> getGames() async {
    final dtos = await _dataProvider.getGames();
    return dtos.map(CasinoGame.fromDto).toList(growable: false);
  }

  Future<CasinoGame> getGame(String gameId) async {
    final dto = await _dataProvider.getGame(gameId);
    return CasinoGame.fromDto(dto);
  }

  Future<CasinoSession> startSession({
    required String gameId,
    required String currency,
  }) async {
    final dto = await _dataProvider.startSession(
      gameId: gameId,
      currency: currency,
    );
    return CasinoSession.fromDto(dto);
  }

  Future<CasinoSession> getSession(String sessionId) async {
    final dto = await _dataProvider.getSession(sessionId);
    return CasinoSession.fromDto(dto);
  }

  Future<CasinoSpinResult> spin({
    required String gameId,
    required num bet,
    required String currency,
    required String action,
    required String clientRequestId,
    String? sessionId,
    String? forcedScenario,
  }) async {
    final dto = await _dataProvider.spin(
      gameId: gameId,
      bet: bet,
      currency: currency,
      action: action,
      clientRequestId: clientRequestId,
      sessionId: sessionId,
      forcedScenario: forcedScenario,
    );
    return CasinoSpinResult.fromDto(dto);
  }

  Future<CasinoSpinResult> getSpin(String spinId) async {
    final dto = await _dataProvider.getSpin(spinId);
    return CasinoSpinResult.fromDto(dto);
  }

  Future<List<CasinoHistoryItem>> getHistory({int limit = 50}) async {
    final dtos = await _dataProvider.getHistory(limit: limit);
    return dtos.map(CasinoHistoryItem.fromDto).toList(growable: false);
  }

  Future<CasinoStats> getStats() async {
    final dto = await _dataProvider.getStats();
    return CasinoStats.fromDto(dto);
  }

  static String mapError(Object error) {
    if (error is DataError) {
      switch (error.apiError) {
        case 'plan_required':
          return CasinoConstants.errorPlanRequired;
        case 'insufficient_balance':
          return CasinoConstants.errorInsufficient;
        case 'invalid_bet':
        case 'invalid_bet_step':
          return CasinoConstants.errorInvalidBet;
        case 'game_not_found':
        case 'game_inactive':
          return CasinoConstants.errorGame;
        case 'session_not_found':
        case 'session_inactive':
          return CasinoConstants.errorSession;
        case 'bonus_requires_respin':
          return CasinoConstants.errorBonusRespin;
        case 'invalid_idempotency':
          return CasinoConstants.errorIdempotency;
        case 'forced_scenarios_disabled':
          return CasinoConstants.errorForcedDisabled;
      }
      return error.displayMessage;
    }
    return error.toString();
  }
}
