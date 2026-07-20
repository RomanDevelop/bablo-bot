import '../../../core/utils/json_parsers.dart';

class HealthDto {
  const HealthDto({
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

  factory HealthDto.fromJson(Map<String, dynamic> json) {
    return HealthDto(
      status: asString(json['status'], 'unknown'),
      binanceConnected: asBool(json['binance_connected']),
      botRunning: asBool(json['bot_running']),
      testnet: asBool(json['testnet'], true),
      mode: asNullableString(json['mode']),
      error: asNullableString(json['error']),
    );
  }
}

class PositionDto {
  const PositionDto({
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

  factory PositionDto.fromJson(Map<String, dynamic> json) {
    return PositionDto(
      side: asNullableString(json['side']),
      entryPrice: asString(json['entry_price']),
      quantity: asString(json['quantity']),
      entryTime: asNullableString(json['entry_time']),
      unrealizedPnl: asString(json['unrealized_pnl']),
    );
  }
}

class PortfolioSnapshotDto {
  const PortfolioSnapshotDto({
    required this.syncStatus,
    required this.syncNote,
    this.leverage,
    this.marginType,
  });

  final String syncStatus;
  final String syncNote;
  final int? leverage;
  final String? marginType;

  factory PortfolioSnapshotDto.fromJson(Map<String, dynamic> json) {
    return PortfolioSnapshotDto(
      syncStatus: asString(json['sync_status'], 'ok'),
      syncNote: asString(json['sync_note'], ''),
      leverage: json['leverage'] != null ? asInt(json['leverage']) : null,
      marginType: asNullableString(json['margin_type']),
    );
  }
}

class BalancesDto {
  const BalancesDto({
    required this.baseAsset,
    required this.quoteAsset,
    required this.baseBalance,
    required this.quoteBalance,
    required this.price,
    required this.equity,
    this.symbol,
    this.market,
  });

  final String? symbol;
  final String baseAsset;
  final String quoteAsset;
  final String baseBalance;
  final String quoteBalance;
  final String price;
  final String equity;
  final String? market;

  factory BalancesDto.fromJson(Map<String, dynamic> json) {
    return BalancesDto(
      symbol: asNullableString(json['symbol']),
      baseAsset: asString(json['base_asset'], 'BASE'),
      quoteAsset: asString(json['quote_asset'], 'USDT'),
      baseBalance: asString(json['base_balance']),
      quoteBalance: asString(json['quote_balance']),
      price: asString(json['price']),
      equity: asString(json['equity']),
      market: asNullableString(json['market']),
    );
  }
}

class RiskDto {
  const RiskDto({
    required this.isHalted,
    required this.haltReason,
    required this.dailyPnlPct,
    this.lastTradeAt,
  });

  final bool isHalted;
  final String haltReason;
  final String dailyPnlPct;
  final String? lastTradeAt;

  factory RiskDto.fromJson(Map<String, dynamic> json) {
    return RiskDto(
      isHalted: asBool(json['is_halted']),
      haltReason: asString(json['halt_reason'], ''),
      dailyPnlPct: asString(json['daily_pnl_pct']),
      lastTradeAt: asNullableString(json['last_trade_at']),
    );
  }
}

class BotStatusDto {
  const BotStatusDto({
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
    required this.portfolio,
    required this.balances,
    required this.risk,
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
  final PositionDto position;
  final PortfolioSnapshotDto portfolio;
  final BalancesDto balances;
  final RiskDto risk;
  final String? mode;
  final String? updatedAt;

  factory BotStatusDto.fromJson(Map<String, dynamic> json) {
    return BotStatusDto(
      isRunning: asBool(json['is_running']),
      symbol: asString(json['symbol'], '—'),
      interval: asString(json['interval'], '—'),
      candlesLoaded: asInt(json['candles_loaded']),
      lastSignal: asString(json['last_signal'], 'HOLD').toUpperCase(),
      lastSignalReason: asString(json['last_signal_reason'], ''),
      lastMacd: asString(json['last_macd']),
      lastSignalLine: asString(json['last_signal_line']),
      lastPrice: asString(json['last_price']),
      position: PositionDto.fromJson(asMap(json['position'])),
      portfolio: PortfolioSnapshotDto.fromJson(asMap(json['portfolio'])),
      balances: BalancesDto.fromJson(asMap(json['balances'])),
      risk: RiskDto.fromJson(asMap(json['risk'])),
      mode: asNullableString(json['mode']),
      updatedAt: asNullableString(json['updated_at']),
    );
  }
}
