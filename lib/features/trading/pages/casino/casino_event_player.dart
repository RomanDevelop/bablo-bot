import '../../../../core/constants/casino_constants.dart';
import '../../models/casino_model.dart';

/// Plays spin `events[]` strictly in order. Does not compute wins.
class CasinoEventPlayer {
  const CasinoEventPlayer();

  Future<void> play({
    required List<CasinoEvent> events,
    required bool turbo,
    required Future<void> Function(CasinoEvent event) onEvent,
  }) async {
    for (final event in events) {
      await onEvent(event);
      await Future<void>.delayed(_delayFor(event.type, turbo: turbo));
    }
  }

  Duration _delayFor(String type, {required bool turbo}) {
    final base = switch (type) {
      CasinoConstants.eventSpinStarted ||
      CasinoConstants.eventRespinStarted =>
        180,
      CasinoConstants.eventBetAccepted => 120,
      CasinoConstants.eventBoardGenerated => 520,
      CasinoConstants.eventWinDetected => 420,
      CasinoConstants.eventNoWin => 280,
      CasinoConstants.eventCascadeStarted => 200,
      CasinoConstants.eventSymbolsRemoved => 320,
      CasinoConstants.eventNewSymbolsDropped => 420,
      CasinoConstants.eventMultiplierChanged => 180,
      CasinoConstants.eventBonusTriggered => 600,
      CasinoConstants.eventCoinLocked => 260,
      CasinoConstants.eventRespinsReset => 220,
      CasinoConstants.eventBonusCompleted => 700,
      CasinoConstants.eventWinCredited => 360,
      CasinoConstants.eventSpinCompleted => 200,
      _ => 160,
    };
    final ms = turbo ? (base * 0.45).round() : base;
    return Duration(milliseconds: ms.clamp(40, 1200));
  }
}
