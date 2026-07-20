import '../dto/trade_dto.dart';

class Trade {
  const Trade({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.price,
    required this.status,
    required this.createdAt,
    this.orderId,
    this.reason,
    this.realizedPnl,
    this.entryPrice,
  });

  final String id;
  final String symbol;
  final String side;
  final String quantity;
  final String price;
  final String status;
  final String createdAt;
  final int? orderId;
  final String? reason;
  final String? realizedPnl;
  final String? entryPrice;

  factory Trade.fromDto(TradeDto dto) => Trade(
        id: dto.id,
        symbol: dto.symbol,
        side: dto.side,
        quantity: dto.quantity,
        price: dto.price,
        status: dto.status,
        createdAt: dto.createdAt,
        orderId: dto.orderId,
        reason: dto.reason,
        realizedPnl: dto.realizedPnl,
        entryPrice: dto.entryPrice,
      );

  bool get isBuy {
    switch (side) {
      case 'BUY':
      case 'LONG':
      case 'OPEN_LONG':
        return true;
      default:
        return side.startsWith('OPEN') && side.contains('LONG');
    }
  }

  bool get isSell {
    switch (side) {
      case 'SELL':
      case 'SHORT':
      case 'CLOSE_LONG':
      case 'CLOSE_SHORT':
      case 'OPEN_SHORT':
        return true;
      default:
        return side.startsWith('CLOSE') || side.startsWith('OPEN_SHORT');
    }
  }

  bool get isClosing =>
      side.startsWith('CLOSE') ||
      side == 'SELL' ||
      side.contains('CLOSE');

  bool get hasPnl => realizedPnl != null && realizedPnl!.isNotEmpty;

  String get sideLabel {
    if (side.isEmpty) return '—';
    return side;
  }
}
