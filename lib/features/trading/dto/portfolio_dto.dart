import '../../../core/utils/json_parsers.dart';

class BotPositionDto {
  const BotPositionDto({
    required this.open,
    this.side,
    required this.quantity,
    required this.entryPrice,
    this.entryTime,
    required this.unrealizedPnl,
  });

  final bool open;
  final String? side;
  final String quantity;
  final String entryPrice;
  final String? entryTime;
  final String unrealizedPnl;

  factory BotPositionDto.fromJson(Map<String, dynamic> json) {
    return BotPositionDto(
      open: asBool(json['open']),
      side: asNullableString(json['side']),
      quantity: asString(json['quantity']),
      entryPrice: asString(json['entry_price']),
      entryTime: asNullableString(json['entry_time']),
      unrealizedPnl: asString(json['unrealized_pnl']),
    );
  }
}

class WalletDto {
  const WalletDto({
    this.baseAsset,
    required this.quoteAsset,
    this.baseBalance,
    required this.quoteBalance,
    required this.price,
    required this.equity,
    this.market,
  });

  final String? baseAsset;
  final String quoteAsset;
  final String? baseBalance;
  final String quoteBalance;
  final String price;
  final String equity;
  final String? market;

  factory WalletDto.fromJson(Map<String, dynamic> json) {
    return WalletDto(
      baseAsset: asNullableString(json['base_asset']),
      quoteAsset: asString(json['quote_asset'], 'USDT'),
      baseBalance: asNullableString(json['base_balance']),
      quoteBalance: asString(json['quote_balance']),
      price: asString(json['price']),
      equity: asString(json['equity']),
      market: asNullableString(json['market']),
    );
  }
}

class PortfolioDto {
  const PortfolioDto({
    this.mode,
    required this.symbol,
    required this.syncStatus,
    required this.syncActions,
    required this.syncNote,
    this.leverage,
    this.marginType,
    required this.botPosition,
    required this.wallet,
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
  final BotPositionDto botPosition;
  final WalletDto wallet;
  final String? whatCountsAsPosition;
  final String? updatedAt;

  factory PortfolioDto.fromJson(Map<String, dynamic> json) {
    return PortfolioDto(
      mode: asNullableString(json['mode']),
      symbol: asString(json['symbol'], '—'),
      syncStatus: asString(json['sync_status'], 'ok'),
      syncActions: asList(json['sync_actions']).map((e) => e.toString()).toList(),
      syncNote: asString(json['sync_note'], ''),
      leverage: json['leverage'] != null ? asInt(json['leverage']) : null,
      marginType: asNullableString(json['margin_type']),
      botPosition: BotPositionDto.fromJson(asMap(json['bot_position'])),
      wallet: WalletDto.fromJson(asMap(json['wallet'])),
      whatCountsAsPosition: asNullableString(json['what_counts_as_position']),
      updatedAt: asNullableString(json['updated_at']),
    );
  }
}
