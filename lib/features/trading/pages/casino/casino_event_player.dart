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
      CasinoConstants.eventRespinStarted => 220,
      CasinoConstants.eventBetAccepted => 140,
      CasinoConstants.eventBoardGenerated => 1280,
      CasinoConstants.eventWinDetected => 720,
      CasinoConstants.eventNoWin => 360,
      CasinoConstants.eventCascadeStarted => 240,
      CasinoConstants.eventSymbolsRemoved => 380,
      CasinoConstants.eventNewSymbolsDropped => 560,
      CasinoConstants.eventMultiplierChanged => 280,
      CasinoConstants.eventBonusTriggered => 900,
      CasinoConstants.eventCoinLocked => 320,
      CasinoConstants.eventRespinsReset => 260,
      CasinoConstants.eventBonusCompleted => 900,
      CasinoConstants.eventWinCredited => 640,
      CasinoConstants.eventSpinCompleted => 240,
      _ => 180,
    };
    final ms = turbo ? (base * 0.45).round() : base;
    return Duration(milliseconds: ms.clamp(40, 1600));
  }
}
