import '../../../core/utils/json_parsers.dart';

class TradeDto {
  const TradeDto({
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

  factory TradeDto.fromJson(Map<String, dynamic> json) {
    return TradeDto(
      id: asString(json['id'] ?? json['trade_id'] ?? json['fill_id'], ''),
      symbol: asString(json['symbol'], '—'),
      side: asString(json['side'] ?? json['position_side'], '').toUpperCase(),
      quantity: asString(json['quantity'] ?? json['qty']),
      price: asString(json['price'] ?? json['avg_price']),
      status: asString(json['status'], 'FILLED'),
      createdAt: asString(
        json['created_at'] ?? json['time'] ?? json['timestamp'],
        '',
      ),
      orderId: json['order_id'] == null ? null : asInt(json['order_id']),
      reason: asNullableString(json['reason'] ?? json['signal_reason']),
      realizedPnl: asNullableString(json['realized_pnl'] ?? json['pnl']),
      entryPrice: asNullableString(json['entry_price']),
    );
  }
}
