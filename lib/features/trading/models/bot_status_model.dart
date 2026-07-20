import '../../../../core/utils/position_side.dart';
import '../dto/bot_status_dto.dart';

enum SignalType { buy, sell, hold }

class Health {
  const Health({
    required this.status,
    required this.binanceConnected,
    required this.botRunning,
    required this.testnet,
    this.mode,
    this.error,
  });

  final String status;
  final bool binanceConnected;
  final bool botRunning;
  final bool testnet;
  final String? mode;
  final String? error;

  factory Health.fromDto(HealthDto dto) => Health(
        status: dto.status,
        binanceConnected: dto.binanceConnected,
        botRunning: dto.botRunning,
        testnet: dto.testnet,
        mode: dto.mode,
        error: dto.error,
      );

  bool get isOk => status == 'ok' && binanceConnected;
  String get networkLabel => testnet ? 'TESTNET' : 'MAINNET';
  String get modeLabel => mode ?? '—';
}

class BotPosition {
  const BotPosition({
    this.side,
    required this.entryPrice,
    required this.quantity,
    this.entryTime,
    required this.unrealizedPnl,
  });

  final String? side;
  final String entryPrice;
  final String quantity;
  final String? entryTime;
  final String unrealizedPnl;

  factory BotPosition.fromDto(PositionDto dto) => BotPosition(
        side: dto.side,
        entryPrice: dto.entryPrice,
        quantity: dto.quantity,
        entryTime: dto.entryTime,
        unrealizedPnl: dto.unrealizedPnl,
      );

  bool get isOpen => isPositionOpen(side, quantity);

  String get sideLabel => formatPositionSide(side, isOpen: isOpen);
}

class BotStatus {
  const BotStatus({
    required this.isRunning,
    required this.symbol,
    required this.interval,
    required this.candlesLoaded,
    required this.lastSignal,
    required this.lastSignalReason,
    required this.lastMacd,
    required this.lastSignalLine,
    required this.lastPrice,
    required this.position,
    required this.syncStatus,
    required this.syncNote,
    this.leverage,
    this.marginType,
    required this.baseAsset,
    required this.quoteAsset,
    required this.baseBalance,
    required this.quoteBalance,
    required this.price,
    required this.equity,
    this.market,
    required this.isHalted,
    required this.haltReason,
    required this.dailyPnlPct,
    this.mode,
    this.updatedAt,
  });

  final bool isRunning;
  final String symbol;
  final String interval;
  final int candlesLoaded;
  final String lastSignal;
  final String lastSignalReason;
  final String lastMacd;
  final String lastSignalLine;
  final String lastPrice;
  final BotPosition position;
  final String syncStatus;
  final String syncNote;
  final int? leverage;
  final String? marginType;
  final String baseAsset;
  final String quoteAsset;
  final String baseBalance;
  final String quoteBalance;
  final String price;
  final String equity;
  final String? market;
  final bool isHalted;
  final String haltReason;
  final String dailyPnlPct;
  final String? mode;
  final String? updatedAt;

  factory BotStatus.fromDto(BotStatusDto dto) => BotStatus(
        isRunning: dto.isRunning,
        symbol: dto.symbol,
        interval: dto.interval,
        candlesLoaded: dto.candlesLoaded,
        lastSignal: dto.lastSignal,
        lastSignalReason: dto.lastSignalReason,
        lastMacd: dto.lastMacd,
        lastSignalLine: dto.lastSignalLine,
        lastPrice: dto.lastPrice,
        position: BotPosition.fromDto(dto.position),
        syncStatus: dto.portfolio.syncStatus,
        syncNote: dto.portfolio.syncNote,
        leverage: dto.portfolio.leverage,
        marginType: dto.portfolio.marginType,
        baseAsset: dto.balances.baseAsset,
        quoteAsset: dto.balances.quoteAsset,
        baseBalance: dto.balances.baseBalance,
        quoteBalance: dto.balances.quoteBalance,
        price: dto.balances.price,
        equity: dto.balances.equity,
        market: dto.balances.market,
        isHalted: dto.risk.isHalted,
        haltReason: dto.risk.haltReason,
        dailyPnlPct: dto.risk.dailyPnlPct,
        mode: dto.mode,
        updatedAt: dto.updatedAt,
      );

  SignalType get signalType {
    switch (lastSignal.toUpperCase()) {
      case 'BUY':
        return SignalType.buy;
      case 'SELL':
        return SignalType.sell;
      default:
        return SignalType.hold;
    }
  }

  String get leverageLabel {
    if (leverage == null) return '—';
    final margin = marginType ?? '—';
    return '${leverage}x · $margin';
  }
}
