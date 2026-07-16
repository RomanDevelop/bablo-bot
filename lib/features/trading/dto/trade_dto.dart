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
      id: asString(json['id'], ''),
      symbol: asString(json['symbol'], '—'),
      side: asString(json['side'], '').toUpperCase(),
      quantity: asString(json['quantity']),
      price: asString(json['price']),
      status: asString(json['status'], ''),
      createdAt: asString(json['created_at'], ''),
      orderId: json['order_id'] == null ? null : asInt(json['order_id']),
      reason: asNullableString(json['reason']),
      realizedPnl: asNullableString(json['realized_pnl']),
      entryPrice: asNullableString(json['entry_price']),
    );
  }
}
