import '../models/equity_curve.dart';
import '../models/stats_model.dart';
import '../models/trade_model.dart';

/// Recalculates epoch stats from a fixed client-side epoch start.
class EpochStatsCalculator {
  EpochStatsCalculator._();

  /// Fixed display epoch: 8 Aug 2026 00:00 UTC.
  static final DateTime epochStartUtc = DateTime.utc(2026, 8, 8);

  /// Shifts [epoch_started_at] to [epochStartUtc], then rebuilds
  /// Performance + equity metrics from trades after that date.
  static ({EpochStats stats, EquityCurve curve}) recalculate({
    required EpochStats raw,
    required List<Trade> trades,
  }) {
    final originalStart = _parseUtc(raw.epochStartedAt);
    if (originalStart == null) {
      final curve = EquityCurve.fromStatsAndTrades(raw, trades);
      return (stats: raw, curve: curve);
    }

    final cut = epochStartUtc;
    // If API epoch already starts later than our cut — keep API as-is.
    if (!originalStart.isBefore(cut)) {
      final curve = EquityCurve.fromStatsAndTrades(raw, trades);
      return (stats: raw, curve: curve);
    }

    final sorted = _tradesFrom(originalStart, trades);

    final originalBaseline = _asDouble(raw.baselineEquity);
    final currentEquity =
        _asDouble(raw.currentEquity, fallback: originalBaseline);

    var baselineAtCut = originalBaseline;
    for (final trade in sorted) {
      final at = _tradeAt(trade);
      if (at == null || !at.isBefore(cut)) break;
      if (trade.hasPnl) {
        baselineAtCut += _asDouble(trade.realizedPnl);
      }
    }

    final inNewEpoch = sorted.where((t) {
      final at = _tradeAt(t);
      return at != null && !at.isBefore(cut);
    }).toList();

    var realizedSinceCut = 0.0;
    var wins = 0;
    var losses = 0;
    var flats = 0;
    final closed = inNewEpoch.where((t) => t.hasPnl).toList();
    for (final trade in closed) {
      final pnl = _asDouble(trade.realizedPnl);
      realizedSinceCut += pnl;
      if (pnl > 0) {
        wins++;
      } else if (pnl < 0) {
        losses++;
      } else {
        flats++;
      }
    }

    final closedCount = closed.length;
    final equityPnl = currentEquity - baselineAtCut;
    final equityPnlPct =
        baselineAtCut == 0 ? 0.0 : equityPnl / baselineAtCut * 100;
    final unrealized = currentEquity - baselineAtCut - realizedSinceCut;
    final winRate = closedCount == 0 ? 0.0 : wins / closedCount * 100;

    String? lastTradeAt;
    if (inNewEpoch.isNotEmpty) {
      lastTradeAt = inNewEpoch.last.createdAt;
    }

    final adjusted = EpochStats(
      epochStartedAt: cut.toIso8601String(),
      baselineEquity: _fmtMoney(baselineAtCut),
      baselineNote:
          'Эпоха с 8 авг. 2026. Baseline = equity на ${_fmtDate(cut)} '
          '(до этого — предыдущий период с ${_fmtDate(originalStart)}).',
      currentEquity: raw.currentEquity,
      equityPnl: _fmtMoney(equityPnl),
      equityPnlPct: _fmtPct(equityPnlPct),
      realizedPnl: _fmtMoney(realizedSinceCut),
      unrealizedPnl: _fmtMoney(unrealized),
      totalFills: inNewEpoch.length,
      buys: inNewEpoch.where((t) => t.isBuy).length,
      sells: inNewEpoch.where((t) => t.isSell).length,
      closedTrades: closedCount,
      wins: wins,
      losses: losses,
      flats: flats,
      winRatePct: _fmtPct(winRate),
      tracked: raw.tracked,
      includesPreEpochExchangeHistory: raw.includesPreEpochExchangeHistory,
      symbol: raw.symbol,
      positionOpen: raw.positionOpen,
      lastTradeAt: lastTradeAt ?? raw.lastTradeAt,
      updatedAt: raw.updatedAt,
    );

    final curve = EquityCurve.fromStatsAndTrades(adjusted, trades);
    return (stats: adjusted, curve: curve);
  }

  static List<Trade> _tradesFrom(DateTime from, List<Trade> trades) {
    final list = trades.where((t) {
      final at = _tradeAt(t);
      return at != null && !at.isBefore(from);
    }).toList()
      ..sort((a, b) => _tradeAt(a)!.compareTo(_tradeAt(b)!));
    return list;
  }

  static DateTime? _parseUtc(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }

  static DateTime? _tradeAt(Trade trade) =>
      DateTime.tryParse(trade.createdAt)?.toUtc();

  static double _asDouble(String? value, {double fallback = 0}) =>
      double.tryParse(value ?? '') ?? fallback;

  static String _fmtMoney(double v) => v.toStringAsFixed(2);

  static String _fmtPct(double v) => v.toStringAsFixed(2);

  static String _fmtDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'янв.',
      'февр.',
      'мар.',
      'апр.',
      'мая',
      'июн.',
      'июл.',
      'авг.',
      'сент.',
      'окт.',
      'нояб.',
      'дек.',
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}, '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
