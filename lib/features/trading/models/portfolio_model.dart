import '../dto/portfolio_dto.dart';

class Portfolio {
  const Portfolio({
    required this.symbol,
    required this.syncStatus,
    required this.syncActions,
    required this.syncNote,
    required this.botOpen,
    this.botSide,
    required this.botQuantity,
    required this.botEntryPrice,
    this.botEntryTime,
    required this.botUnrealizedPnl,
    required this.baseAsset,
    required this.quoteAsset,
    required this.baseBalance,
    required this.quoteBalance,
    required this.price,
    required this.equity,
    required this.idleBase,
    this.idleBaseNote,
    this.whatCountsAsPosition,
    this.updatedAt,
  });

  final String symbol;
  final String syncStatus;
  final List<String> syncActions;
  final String syncNote;
  final bool botOpen;
  final String? botSide;
  final String botQuantity;
  final String botEntryPrice;
  final String? botEntryTime;
  final String botUnrealizedPnl;
  final String baseAsset;
  final String quoteAsset;
  final String baseBalance;
  final String quoteBalance;
  final String price;
  final String equity;
  final String idleBase;
  final String? idleBaseNote;
  final String? whatCountsAsPosition;
  final String? updatedAt;

  factory Portfolio.fromDto(PortfolioDto dto) => Portfolio(
        symbol: dto.symbol,
        syncStatus: dto.syncStatus,
        syncActions: dto.syncActions,
        syncNote: dto.syncNote,
        botOpen: dto.botPosition.open,
        botSide: dto.botPosition.side,
        botQuantity: dto.botPosition.quantity,
        botEntryPrice: dto.botPosition.entryPrice,
        botEntryTime: dto.botPosition.entryTime,
        botUnrealizedPnl: dto.botPosition.unrealizedPnl,
        baseAsset: dto.wallet.baseAsset,
        quoteAsset: dto.wallet.quoteAsset,
        baseBalance: dto.wallet.baseBalance,
        quoteBalance: dto.wallet.quoteBalance,
        price: dto.wallet.price,
        equity: dto.wallet.equity,
        idleBase: dto.wallet.idleBase,
        idleBaseNote: dto.wallet.idleBaseNote,
        whatCountsAsPosition: dto.whatCountsAsPosition,
        updatedAt: dto.updatedAt,
      );

  bool get hasIdle {
    final idle = double.tryParse(idleBase) ?? 0;
    return idle > 0;
  }
}
