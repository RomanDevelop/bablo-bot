import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../../components/trading_card.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/money_format.dart';
import '../../../models/equity_curve.dart';

class EquityCurveChart extends StatelessWidget {
  const EquityCurveChart({super.key, required this.curve});

  final EquityCurve curve;

  @override
  Widget build(BuildContext context) {
    final positive = curve.totalPnl >= 0;
    final lineColor = positive ? AppColors.buy : AppColors.sell;

    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            'Доходность эпохи',
            trailing: Text(
              MoneyFormat.pct(curve.totalPnlPct.toString()),
              style: context.tradingText.monoMedium.copyWith(
                color: lineColor,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${MoneyFormat.signedUsd(curve.totalPnl.toString())}  ·  '
            '${curve.closedTrades} закрытых · ${curve.wins}W / ${curve.losses}L',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          if (curve.isEmpty)
            const SizedBox(
              height: 160,
              child: Center(
                child: Text(
                  'Пока нет точек для графика',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              width: double.infinity,
              child: CustomPaint(
                painter: EquityCurvePainter(curve: curve),
              ),
            ),
        ],
      ),
    );
  }
}

class EquityCurvePainter extends CustomPainter {
  EquityCurvePainter({required this.curve});

  final EquityCurve curve;

  @override
  void paint(Canvas canvas, Size size) {
    final points = curve.points;
    if (points.length < 2) return;

    final chart = Rect.fromLTWH(44, 8, size.width - 52, size.height - 28);

    var minPct = points.map((p) => p.pnlPct).reduce(math.min);
    var maxPct = points.map((p) => p.pnlPct).reduce(math.max);
    minPct = math.min(minPct, 0);
    maxPct = math.max(maxPct, 0);
    final pad = (maxPct - minPct).abs() * 0.12 + 0.05;
    minPct -= pad;
    maxPct += pad;

    final t0 = points.first.at.millisecondsSinceEpoch.toDouble();
    final t1 = points.last.at.millisecondsSinceEpoch.toDouble();
    final tSpan = (t1 - t0).abs() < 1 ? 1.0 : (t1 - t0);

    Offset toOffset(EquityCurvePoint p) {
      final x = chart.left + (p.at.millisecondsSinceEpoch - t0) / tSpan * chart.width;
      final y = _y(p.pnlPct, minPct, maxPct, chart);
      return Offset(x, y);
    }

    _drawGrid(canvas, chart, minPct, maxPct);
    _drawZeroLine(canvas, chart, minPct, maxPct);

    final path = Path()..moveTo(toOffset(points.first).dx, toOffset(points.first).dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(toOffset(points[i]).dx, toOffset(points[i]).dy);
    }

    final last = toOffset(points.last);
    final first = toOffset(points.first);
    final fill = Path.from(path)
      ..lineTo(last.dx, chart.bottom)
      ..lineTo(first.dx, chart.bottom)
      ..close();

    final positive = curve.totalPnl >= 0;
    final lineColor = positive ? AppColors.buy : AppColors.sell;
    final fillColor = lineColor.withValues(alpha: 0.14);

    canvas.drawPath(fill, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );

    // Dots on trade closes (skip start/current-only if dense).
    final dotPaint = Paint()..color = lineColor;
    final maxDots = 24;
    final step = math.max(1, (points.length / maxDots).ceil());
    for (var i = 0; i < points.length; i += step) {
      final o = toOffset(points[i]);
      canvas.drawCircle(o, i == 0 || points[i].isCurrent ? 3.2 : 2.2, dotPaint);
    }
    if (!points.last.isCurrent || points.length % step != 0) {
      canvas.drawCircle(last, 3.5, dotPaint);
      canvas.drawCircle(last, 5.5, Paint()..color = lineColor.withValues(alpha: 0.25));
    }

    _drawYLabels(canvas, chart, minPct, maxPct);
    _drawXLabels(canvas, chart, points.first.at, points.last.at);
  }

  void _drawGrid(Canvas canvas, Rect chart, double minY, double maxY) {
    final paint = Paint()
      ..color = AppColors.borderSubtle
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = chart.top + chart.height * i / 4;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), paint);
    }
  }

  void _drawZeroLine(Canvas canvas, Rect chart, double minY, double maxY) {
    if (minY > 0 || maxY < 0) return;
    final y = _y(0, minY, maxY, chart);
    canvas.drawLine(
      Offset(chart.left, y),
      Offset(chart.right, y),
      Paint()
        ..color = AppColors.border
        ..strokeWidth = 1.2,
    );
  }

  void _drawYLabels(Canvas canvas, Rect chart, double minY, double maxY) {
    for (var i = 0; i <= 4; i++) {
      final v = maxY - (maxY - minY) * i / 4;
      final y = chart.top + chart.height * i / 4;
      final label = TextPainter(
        text: TextSpan(
          text: '${v >= 0 ? '+' : ''}${v.toStringAsFixed(1)}%',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 42);
      label.paint(canvas, Offset(2, y - label.height / 2));
    }
  }

  void _drawXLabels(Canvas canvas, Rect chart, DateTime start, DateTime end) {
    final fmt = DateFormat('dd MMM', 'ru');
    final left = TextPainter(
      text: TextSpan(
        text: fmt.format(start),
        style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final right = TextPainter(
      text: TextSpan(
        text: fmt.format(end),
        style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    left.paint(canvas, Offset(chart.left, chart.bottom + 6));
    right.paint(canvas, Offset(chart.right - right.width, chart.bottom + 6));
  }

  double _y(double v, double minY, double maxY, Rect chart) {
    final t = (v - minY) / (maxY - minY);
    return chart.bottom - t * chart.height;
  }

  @override
  bool shouldRepaint(covariant EquityCurvePainter oldDelegate) {
    return oldDelegate.curve != curve;
  }
}
