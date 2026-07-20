import 'stats_model.dart';
import 'trade_model.dart';

/// Point on the epoch equity / return curve.
class EquityCurvePoint {
  const EquityCurvePoint({
    required this.at,
    required this.equity,
    required this.pnl,
    required this.pnlPct,
    this.isCurrent = false,
  });

  final DateTime at;
  final double equity;
  final double pnl;
  final double pnlPct;
  final bool isCurrent;
}

/// Full epoch performance reconstructed from baseline + closed trades + current equity.
class EquityCurve {
  const EquityCurve({
    required this.points,
    required this.baseline,
    required this.currentEquity,
    required this.totalPnl,
    required this.totalPnlPct,
    required this.realizedPnl,
    required this.closedTrades,
    required this.wins,
    required this.losses,
  });

  final List<EquityCurvePoint> points;
  final double baseline;
  final double currentEquity;
  final double totalPnl;
  final double totalPnlPct;
  final double realizedPnl;
  final int closedTrades;
  final int wins;
  final int losses;

  bool get isEmpty => points.length < 2;

  static EquityCurve fromStatsAndTrades(EpochStats stats, List<Trade> trades) {
    final baseline = double.tryParse(stats.baselineEquity) ?? 0;
    final currentEquity = double.tryParse(stats.currentEquity) ?? baseline;
    final totalPnl = double.tryParse(stats.equityPnl) ?? (currentEquity - baseline);
    final totalPnlPct = double.tryParse(stats.equityPnlPct) ??
        (baseline == 0 ? 0 : totalPnl / baseline * 100);
    final statsRealized = double.tryParse(stats.realizedPnl) ?? 0;

    final epochStart =
        DateTime.tryParse(stats.epochStartedAt)?.toUtc() ?? DateTime.now().toUtc();
    final now = DateTime.tryParse(stats.updatedAt ?? '')?.toUtc() ??
        DateTime.now().toUtc();

    final closed = trades.where((t) {
      if (!t.hasPnl) return false;
      final at = DateTime.tryParse(t.createdAt)?.toUtc();
      if (at == null) return false;
      return !at.isBefore(epochStart);
    }).toList()
      ..sort((a, b) {
        final da = DateTime.tryParse(a.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = DateTime.tryParse(b.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return da.compareTo(db);
      });

    final points = <EquityCurvePoint>[
      EquityCurvePoint(
        at: epochStart.toLocal(),
        equity: baseline,
        pnl: 0,
        pnlPct: 0,
      ),
    ];

    var cumRealized = 0.0;
    var wins = 0;
    var losses = 0;

    for (final trade in closed) {
      final pnl = double.tryParse(trade.realizedPnl!) ?? 0;
      cumRealized += pnl;
      if (pnl > 0) {
        wins++;
      } else if (pnl < 0) {
        losses++;
      }
      final equity = baseline + cumRealized;
      final pct = baseline == 0 ? 0.0 : cumRealized / baseline * 100;
      final at = DateTime.tryParse(trade.createdAt)?.toUtc().toLocal() ??
          epochStart.toLocal();
      points.add(
        EquityCurvePoint(
          at: at,
          equity: equity,
          pnl: cumRealized,
          pnlPct: pct,
        ),
      );
    }

    // Without closed trades the curve is flat at baseline — don't fake a dip from
    // account drift (funding/fees) that isn't tied to bot fills.
    if (closed.isEmpty) {
      return EquityCurve(
        points: points,
        baseline: baseline,
        currentEquity: currentEquity,
        totalPnl: totalPnl,
        totalPnlPct: totalPnlPct,
        realizedPnl: statsRealized,
        closedTrades: 0,
        wins: 0,
        losses: 0,
      );
    }

    // Anchor to official current equity (includes unrealized).
    final last = points.last;
    final currentDiffers = (currentEquity - last.equity).abs() > 0.01 ||
        (now.toLocal().difference(last.at).inMinutes).abs() > 0;
    if (currentDiffers) {
      points.add(
        EquityCurvePoint(
          at: now.toLocal(),
          equity: currentEquity,
          pnl: totalPnl,
          pnlPct: totalPnlPct,
          isCurrent: true,
        ),
      );
    } else {
      points[points.length - 1] = EquityCurvePoint(
        at: last.at,
        equity: currentEquity,
        pnl: totalPnl,
        pnlPct: totalPnlPct,
        isCurrent: true,
      );
    }

    return EquityCurve(
      points: points,
      baseline: baseline,
      currentEquity: currentEquity,
      totalPnl: totalPnl,
      totalPnlPct: totalPnlPct,
      realizedPnl: cumRealized != 0 ? cumRealized : statsRealized,
      closedTrades: closed.length,
      wins: wins,
      losses: losses,
    );
  }
}
