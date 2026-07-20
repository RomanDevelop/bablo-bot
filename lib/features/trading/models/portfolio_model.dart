import '../../../../core/utils/position_side.dart';
import '../dto/portfolio_dto.dart';

class Portfolio {
  const Portfolio({
    this.mode,
    required this.symbol,
    required this.syncStatus,
    required this.syncActions,
    required this.syncNote,
    this.leverage,
    this.marginType,
    required this.botOpen,
    this.botSide,
    required this.botQuantity,
    required this.botEntryPrice,
    this.botEntryTime,
    required this.botUnrealizedPnl,
    this.baseAsset,
    required this.quoteAsset,
    this.baseBalance,
    required this.quoteBalance,
    required this.price,
    required this.equity,
    this.market,
    this.whatCountsAsPosition,
    this.updatedAt,
  });

  final String? mode;
  final String symbol;
  final String syncStatus;
  final List<String> syncActions;
  final String syncNote;
  final int? leverage;
  final String? marginType;
  final bool botOpen;
  final String? botSide;
  final String botQuantity;
  final String botEntryPrice;
  final String? botEntryTime;
  final String botUnrealizedPnl;
  final String? baseAsset;
  final String quoteAsset;
  final String? baseBalance;
  final String quoteBalance;
  final String price;
  final String equity;
  final String? market;
  final String? whatCountsAsPosition;
  final String? updatedAt;

  factory Portfolio.fromDto(PortfolioDto dto) => Portfolio(
        mode: dto.mode,
        symbol: dto.symbol,
        syncStatus: dto.syncStatus,
        syncActions: dto.syncActions,
        syncNote: dto.syncNote,
        leverage: dto.leverage,
        marginType: dto.marginType,
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
        market: dto.wallet.market,
        whatCountsAsPosition: dto.whatCountsAsPosition,
        updatedAt: dto.updatedAt,
      );

  String get botSideLabel =>
      formatPositionSide(botSide, isOpen: botOpen);

  String get leverageLabel {
    if (leverage == null) return '—';
    final margin = marginType ?? '—';
    return '${leverage}x · $margin';
  }
}
