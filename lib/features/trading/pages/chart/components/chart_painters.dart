import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../models/candle_model.dart';

class CandleChartPainter extends CustomPainter {
  CandleChartPainter({
    required this.candles,
    required this.markers,
    required this.visibleFrom,
    required this.visibleCount,
  });

  final List<Candle> candles;
  final List<ChartMarker> markers;
  final int visibleFrom;
  final int visibleCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty || visibleCount <= 0) return;
    final end = (visibleFrom + visibleCount).clamp(0, candles.length);
    final start = visibleFrom.clamp(0, end);
    final visible = candles.sublist(start, end);
    if (visible.isEmpty) return;

    var minY = visible.first.low;
    var maxY = visible.first.high;
    for (final c in visible) {
      if (c.low < minY) minY = c.low;
      if (c.high > maxY) maxY = c.high;
    }
    final pad = (maxY - minY) * 0.08;
    minY -= pad;
    maxY += pad;
    if (maxY == minY) {
      maxY += 1;
      minY -= 1;
    }

    final chart = Rect.fromLTWH(48, 8, size.width - 56, size.height - 28);
    _drawGrid(canvas, chart, minY, maxY);
    _drawCandles(canvas, chart, visible, minY, maxY);
    _drawMarkers(canvas, chart, visible, start, minY, maxY);
    _drawPriceAxis(canvas, chart, minY, maxY);
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

  void _drawCandles(
    Canvas canvas,
    Rect chart,
    List<Candle> visible,
    double minY,
    double maxY,
  ) {
    final slot = chart.width / visible.length;
    final bodyW = (slot * 0.62).clamp(2.0, 10.0);

    for (var i = 0; i < visible.length; i++) {
      final c = visible[i];
      final cx = chart.left + slot * i + slot / 2;
      final yHigh = _y(c.high, minY, maxY, chart);
      final yLow = _y(c.low, minY, maxY, chart);
      final yOpen = _y(c.open, minY, maxY, chart);
      final yClose = _y(c.close, minY, maxY, chart);
      final color = c.isBull ? AppColors.buy : AppColors.sell;

      final wick = Paint()
        ..color = color
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(cx, yHigh), Offset(cx, yLow), wick);

      final top = yOpen < yClose ? yOpen : yClose;
      final bottom = yOpen < yClose ? yClose : yOpen;
      final bodyH = (bottom - top).clamp(1.0, chart.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, top + bodyH / 2),
            width: bodyW,
            height: bodyH,
          ),
          const Radius.circular(1),
        ),
        Paint()..color = color,
      );
    }
  }

  void _drawMarkers(
    Canvas canvas,
    Rect chart,
    List<Candle> visible,
    int startIndex,
    double minY,
    double maxY,
  ) {
    if (markers.isEmpty) return;
    final slot = chart.width / visible.length;

    for (final m in markers) {
      var idx = -1;
      for (var i = 0; i < visible.length; i++) {
        if (visible[i].openTime == m.time) {
          idx = i;
          break;
        }
      }
      if (idx < 0) {
        var bestDiff = 1 << 30;
        for (var i = 0; i < visible.length; i++) {
          final diff =
              (visible[i].openTime.difference(m.time)).inMilliseconds.abs();
          if (diff < bestDiff) {
            bestDiff = diff;
            idx = i;
          }
        }
      }
      if (idx < 0) continue;

      final cx = chart.left + slot * idx + slot / 2;
      final isBuy = m.isBuy;
      final anchorPrice = m.price > 0
          ? m.price
          : (isBuy ? visible[idx].low : visible[idx].high);
      final y = isBuy
          ? _y(anchorPrice, minY, maxY, chart) + 12
          : _y(anchorPrice, minY, maxY, chart) - 12;

      final color = isBuy
          ? (m.kind == ChartMarkerKind.buyEntry
              ? AppColors.buy
              : AppColors.primary)
          : (m.kind == ChartMarkerKind.sellExit
              ? AppColors.sell
              : AppColors.hold);

      final path = Path();
      if (isBuy) {
        path.moveTo(cx, y - 7);
        path.lineTo(cx - 6, y + 4);
        path.lineTo(cx + 6, y + 4);
      } else {
        path.moveTo(cx, y + 7);
        path.lineTo(cx - 6, y - 4);
        path.lineTo(cx + 6, y - 4);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = color);

      if (m.kind == ChartMarkerKind.buyEntry ||
          m.kind == ChartMarkerKind.sellExit) {
        canvas.drawCircle(
          Offset(cx, isBuy ? y + 8 : y - 8),
          3.5,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  void _drawPriceAxis(Canvas canvas, Rect chart, double minY, double maxY) {
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i <= 4; i++) {
      final price = maxY - (maxY - minY) * i / 4;
      final y = chart.top + chart.height * i / 4;
      tp.text = TextSpan(
        text: price.toStringAsFixed(2),
        style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
      );
      tp.layout();
      tp.paint(canvas, Offset(4, y - tp.height / 2));
    }
  }

  double _y(double price, double minY, double maxY, Rect chart) {
    final t = (price - minY) / (maxY - minY);
    return chart.bottom - t * chart.height;
  }

  @override
  bool shouldRepaint(covariant CandleChartPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.markers != markers ||
        oldDelegate.visibleFrom != visibleFrom ||
        oldDelegate.visibleCount != visibleCount;
  }
}

class MacdChartPainter extends CustomPainter {
  MacdChartPainter({
    required this.macd,
    required this.visibleFrom,
    required this.visibleCount,
  });

  final List<MacdPoint> macd;
  final int visibleFrom;
  final int visibleCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (macd.isEmpty || visibleCount <= 0) return;
    final end = (visibleFrom + visibleCount).clamp(0, macd.length);
    final start = visibleFrom.clamp(0, end);
    final visible = macd.sublist(start, end);
    if (visible.isEmpty) return;

    final values = <double>[];
    for (final p in visible) {
      if (p.macd != null) values.add(p.macd!);
      if (p.signal != null) values.add(p.signal!);
      if (p.histogram != null) values.add(p.histogram!);
    }
    if (values.isEmpty) return;
    var minY = values.reduce((a, b) => a < b ? a : b);
    var maxY = values.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY).abs() * 0.15 + 1e-6;
    minY -= pad;
    maxY += pad;

    final chart = Rect.fromLTWH(48, 6, size.width - 56, size.height - 20);
    final zeroY = _y(0, minY, maxY, chart);

    // zero line
    canvas.drawLine(
      Offset(chart.left, zeroY),
      Offset(chart.right, zeroY),
      Paint()
        ..color = AppColors.border
        ..strokeWidth = 1,
    );

    final slot = chart.width / visible.length;
    final barW = (slot * 0.55).clamp(1.5, 8.0);

    for (var i = 0; i < visible.length; i++) {
      final h = visible[i].histogram;
      if (h == null) continue;
      final cx = chart.left + slot * i + slot / 2;
      final y = _y(h, minY, maxY, chart);
      final top = h >= 0 ? y : zeroY;
      final bottom = h >= 0 ? zeroY : y;
      canvas.drawRect(
        Rect.fromLTRB(cx - barW / 2, top, cx + barW / 2, bottom),
        Paint()
          ..color = h >= 0
              ? AppColors.buy.withValues(alpha: 0.55)
              : AppColors.sell.withValues(alpha: 0.55),
      );
    }

    _drawLine(canvas, chart, visible, minY, maxY, (p) => p.macd, AppColors.primary);
    _drawLine(canvas, chart, visible, minY, maxY, (p) => p.signal, AppColors.hold);

    final label = TextPainter(
      text: const TextSpan(
        text: 'MACD',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, const Offset(8, 4));
  }

  void _drawLine(
    Canvas canvas,
    Rect chart,
    List<MacdPoint> visible,
    double minY,
    double maxY,
    double? Function(MacdPoint) pick,
    Color color,
  ) {
    final path = Path();
    var started = false;
    final slot = chart.width / visible.length;
    for (var i = 0; i < visible.length; i++) {
      final v = pick(visible[i]);
      if (v == null) {
        started = false;
        continue;
      }
      final x = chart.left + slot * i + slot / 2;
      final y = _y(v, minY, maxY, chart);
      if (!started) {
        path.moveTo(x, y);
        started = true;
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..isAntiAlias = true,
    );
  }

  double _y(double v, double minY, double maxY, Rect chart) {
    final t = (v - minY) / (maxY - minY);
    return chart.bottom - t * chart.height;
  }

  @override
  bool shouldRepaint(covariant MacdChartPainter oldDelegate) {
    return oldDelegate.macd != macd ||
        oldDelegate.visibleFrom != visibleFrom ||
        oldDelegate.visibleCount != visibleCount;
  }
}
