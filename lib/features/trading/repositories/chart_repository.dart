import '../../../core/errors/data_error.dart';
import '../../../core/utils/money_format.dart';
import '../market/alligator_calculator.dart';
import '../market/candle_cache.dart';
import '../market/market_data_provider.dart';
import '../models/bot_config_model.dart';
import '../models/bot_status_model.dart';
import '../models/candle_model.dart';
import '../models/trade_model.dart';
import 'trading_repository.dart';

class ChartSnapshot {
  const ChartSnapshot({
    required this.symbol,
    required this.interval,
    required this.testnet,
    required this.candles,
    required this.alligator,
    required this.markers,
    required this.config,
    this.lastSignal,
    this.lastPrice,
    this.lips,
    this.jaw,
    this.scanMode,
    this.mode,
    this.dataSourceNote,
    this.fromCache = false,
  });

  final String symbol;
  final String interval;
  final bool testnet;
  final List<Candle> candles;
  final List<AlligatorPoint> alligator;
  final List<ChartMarker> markers;
  final BotConfig config;
  final String? lastSignal;
  final String? lastPrice;
  /// API `last_macd` — Lips value for Alligator preset.
  final String? lips;
  /// API `last_signal_line` — Jaw value for Alligator preset.
  final String? jaw;
  final String? scanMode;
  final String? mode;
  final String? dataSourceNote;
  final bool fromCache;
}

class ChartRepository {
  ChartRepository({
    required TradingRepository tradingRepository,
    required MarketDataProvider marketDataProvider,
  })  : _trading = tradingRepository,
        _market = marketDataProvider;

  final TradingRepository _trading;
  final MarketDataProvider _market;

  /// Enough bars for Jaw SMMA(13)+shift(8) and visible window.
  static const candleLimit = 120;

  Future<ChartSnapshot> load({int limit = candleLimit}) async {
    final status = await _trading.getStatus();
    final results = await Future.wait([
      _trading.getConfig(),
      _trading.getHealth(),
      _trading.getTrades(limit: 30),
    ]);
    final config = results[0] as BotConfig;
    final health = results[1] as Health;
    final trades = results[2] as List<Trade>;

    MarketCandlesResult? market;
    String? marketError;
    try {
      market = await _market.getKlines(
        symbol: status.symbol,
        interval: status.interval,
        limit: limit,
        testnet: health.testnet,
      );
    } catch (e) {
      marketError = e is DataError ? e.displayMessage : e.toString();
    }

    final candles = market?.candles ?? const <Candle>[];
    const calc = AlligatorCalculator();
    final alligator =
        candles.isEmpty ? const <AlligatorPoint>[] : calc.compute(candles);
    final markers = candles.isEmpty
        ? const <ChartMarker>[]
        : <ChartMarker>[
            ...calc.crossoverMarkers(candles, alligator),
            ..._tradeMarkers(candles, trades),
            ..._openPositionMarker(candles, status),
          ];

    final cacheNote = market != null && market.fromCache
        ? ' · кеш${market.savedAt != null ? ' ${MoneyFormat.dateTime(market.savedAt!.toIso8601String())}' : ''}'
        : '';

    final note = market == null
        ? 'Свечи недоступны: ${marketError ?? 'сеть'}'
        : 'Свечи: ${market.source}$cacheNote · $limit × ${status.interval} · Alligator';

    return ChartSnapshot(
      symbol: status.symbol,
      interval: status.interval,
      testnet: health.testnet,
      candles: candles,
      alligator: alligator,
      markers: markers,
      config: config,
      lastSignal: status.lastSignal,
      lastPrice: status.lastPrice,
      lips: status.lips,
      jaw: status.jaw,
      scanMode: status.scanMode ?? config.scanMode,
      mode: status.mode ?? config.mode,
      fromCache: market?.fromCache ?? false,
      dataSourceNote: note,
    );
  }

  List<ChartMarker> _openPositionMarker(List<Candle> candles, BotStatus status) {
    if (!status.position.isOpen || candles.isEmpty) return const [];
    final entry = double.tryParse(status.position.entryPrice);
    if (entry == null || entry <= 0) return const [];

    DateTime time = candles.last.openTime;
    if (status.position.entryTime != null) {
      final parsed = DateTime.tryParse(status.position.entryTime!);
      if (parsed != null) {
        final utc = parsed.toUtc();
        var best = candles.first;
        var bestDiff = best.openTime.difference(utc).abs();
        for (final c in candles) {
          final diff = c.openTime.difference(utc).abs();
          if (diff < bestDiff) {
            best = c;
            bestDiff = diff;
          }
        }
        time = best.openTime;
      }
    }

    return [
      ChartMarker(
        time: time,
        price: entry,
        kind: ChartMarkerKind.buyEntry,
        label: 'ENTRY',
      ),
    ];
  }

  List<ChartMarker> _tradeMarkers(List<Candle> candles, List<Trade> trades) {
    if (candles.isEmpty || trades.isEmpty) return const [];
    final markers = <ChartMarker>[];
    for (final trade in trades) {
      final t = DateTime.tryParse(trade.createdAt);
      if (t == null) continue;
      final utc = t.isUtc ? t : t.toUtc();

      var best = candles.first;
      var bestDiff = best.openTime.difference(utc).abs();
      for (final c in candles) {
        final diff = c.openTime.difference(utc).abs();
        if (diff < bestDiff) {
          best = c;
          bestDiff = diff;
        }
      }

      if (trade.isBuy) {
        markers.add(
          ChartMarker(
            time: best.openTime,
            price: best.low,
            kind: ChartMarkerKind.buyEntry,
            label: 'BUY',
          ),
        );
      } else if (trade.isSell) {
        markers.add(
          ChartMarker(
            time: best.openTime,
            price: best.high,
            kind: ChartMarkerKind.sellExit,
            label: 'SELL',
          ),
        );
      }
    }
    return markers;
  }
}
