import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_palette.dart';

/// Paints casino symbols without asset/SVG loading (reliable on Flutter web).
class CasinoSymbolIcon extends StatelessWidget {
  const CasinoSymbolIcon({
    super.key,
    required this.symbol,
    required this.palette,
    this.idle = false,
  });

  final String symbol;
  final AppPalette palette;
  final bool idle;

  @override
  Widget build(BuildContext context) {
    final code = idle ? 'IDLE' : _normalize(symbol);
    return CustomPaint(
      painter: _SymbolPainter(code: code, palette: palette),
      child: const SizedBox.expand(),
    );
  }

  static String _normalize(String raw) {
    final s = raw.trim().toUpperCase();
    if (s.isEmpty || s == '·' || s == '.' || s == 'EMPTY') return 'IDLE';
    return s;
  }
}

class _SymbolPainter extends CustomPainter {
  _SymbolPainter({required this.code, required this.palette});

  final String code;
  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    if (side <= 0) return;
    final origin = Offset((size.width - side) / 2, (size.height - side) / 2);
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(side / 64);

    switch (code) {
      case 'CHERRY':
        _cherry(canvas);
      case 'COIN':
        _coin(canvas);
      case 'BAR':
        _bar(canvas);
      case 'SEVEN':
        _seven(canvas);
      case 'DIAMOND':
        _diamond(canvas);
      case 'BABLO':
        _bablo(canvas);
      case 'WILD':
        _wild(canvas);
      case 'RSV_COIN':
        _rsv(canvas);
      case 'IDLE':
        _idle(canvas);
      default:
        _fallback(canvas);
    }
    canvas.restore();
  }

  void _cherry(Canvas canvas) {
    final stem = Paint()
      ..color = const Color(0xFF5B8C3E)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(const Rect.fromLTWH(24, 8, 16, 20), -1.2, 1.6, false, stem);
    canvas.drawOval(
      const Rect.fromLTWH(10, 24, 24, 28),
      Paint()..color = const Color(0xFFE11D37),
    );
    canvas.drawOval(
      const Rect.fromLTWH(30, 24, 24, 28),
      Paint()..color = const Color(0xFFC4122F),
    );
    canvas.drawOval(
      const Rect.fromLTWH(15, 29, 7, 9),
      Paint()..color = const Color(0xFFFF6B7A),
    );
    canvas.drawCircle(const Offset(28, 28), 2.2, Paint()..color = const Color(0xFF5B8C3E));
    canvas.drawCircle(const Offset(36, 28), 2.2, Paint()..color = const Color(0xFF5B8C3E));
  }

  void _coin(Canvas canvas) {
    canvas.drawCircle(const Offset(32, 32), 22, Paint()..color = const Color(0xFFE8B923));
    canvas.drawCircle(const Offset(32, 32), 18, Paint()..color = const Color(0xFFF5D76E));
    final ring = Paint()
      ..color = const Color(0xFFC4920A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(const Offset(32, 32), 14, ring);
    final line = Paint()
      ..color = const Color(0xFFC4920A)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(32, 20), const Offset(32, 44), line);
    canvas.drawLine(const Offset(24, 26), const Offset(40, 26), line);
    canvas.drawLine(const Offset(24, 38), const Offset(40, 38), line);
    canvas.drawCircle(const Offset(24, 22), 3, Paint()..color = const Color(0xFFFFF6C8));
  }

  void _bar(Canvas canvas) {
    final r = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 18, 48, 28),
      const Radius.circular(5),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0xFF2A3344));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(11, 21, 42, 22),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF445372),
    );
    final block = Paint()..color = const Color(0xFFF4F7FF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(16, 28, 7, 10), const Radius.circular(1.5)),
      block,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(26, 28, 7, 10), const Radius.circular(1.5)),
      block,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(36, 28, 7, 10), const Radius.circular(1.5)),
      block,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(46, 28, 6, 10), const Radius.circular(1.5)),
      block,
    );
  }

  void _seven(Canvas canvas) {
    final path = Path()
      ..moveTo(16, 12)
      ..lineTo(48, 12)
      ..lineTo(48, 19)
      ..lineTo(30, 52)
      ..lineTo(20, 52)
      ..lineTo(40, 19)
      ..lineTo(16, 19)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF2470F5));
    final gloss = Path()
      ..moveTo(18, 14)
      ..lineTo(46, 14)
      ..lineTo(46, 18)
      ..lineTo(29, 50)
      ..lineTo(23, 50)
      ..lineTo(38, 18)
      ..lineTo(18, 18)
      ..close();
    canvas.drawPath(gloss, Paint()..color = const Color(0xFF8EC2FF));
  }

  void _diamond(Canvas canvas) {
    final outer = Path()
      ..moveTo(32, 8)
      ..lineTo(52, 32)
      ..lineTo(32, 56)
      ..lineTo(12, 32)
      ..close();
    canvas.drawPath(outer, Paint()..color = const Color(0xFF00A85A));
    final inner = Path()
      ..moveTo(32, 16)
      ..lineTo(44, 32)
      ..lineTo(32, 48)
      ..lineTo(20, 32)
      ..close();
    canvas.drawPath(inner, Paint()..color = const Color(0xFF7EF0C3));
  }

  void _bablo(Canvas canvas) {
    canvas.drawCircle(const Offset(32, 32), 24, Paint()..color = const Color(0xFF2470F5));
    canvas.drawCircle(
      const Offset(32, 32),
      18,
      Paint()
        ..color = const Color(0xFFD6E8FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final star = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 5;
      final b = a + math.pi / 5;
      final ox = 32 + math.cos(a) * 14;
      final oy = 32 + math.sin(a) * 14;
      final ix = 32 + math.cos(b) * 6;
      final iy = 32 + math.sin(b) * 6;
      if (i == 0) {
        star.moveTo(ox, oy);
      } else {
        star.lineTo(ox, oy);
      }
      star.lineTo(ix, iy);
    }
    star.close();
    canvas.drawPath(star, Paint()..color = const Color(0xFFF4F8FF));
  }

  void _wild(Canvas canvas) {
    final star = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 5;
      final b = a + math.pi / 5;
      final ox = 32 + math.cos(a) * 24;
      final oy = 32 + math.sin(a) * 24;
      final ix = 32 + math.cos(b) * 10;
      final iy = 32 + math.sin(b) * 10;
      if (i == 0) {
        star.moveTo(ox, oy);
      } else {
        star.lineTo(ox, oy);
      }
      star.lineTo(ix, iy);
    }
    star.close();
    canvas.drawPath(star, Paint()..color = const Color(0xFFF59E0B));
    final inner = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 5;
      final b = a + math.pi / 5;
      final ox = 32 + math.cos(a) * 12;
      final oy = 32 + math.sin(a) * 12;
      final ix = 32 + math.cos(b) * 5;
      final iy = 32 + math.sin(b) * 5;
      if (i == 0) {
        inner.moveTo(ox, oy);
      } else {
        inner.lineTo(ox, oy);
      }
      inner.lineTo(ix, iy);
    }
    inner.close();
    canvas.drawPath(inner, Paint()..color = const Color(0xFFFFF4CC));
  }

  void _rsv(Canvas canvas) {
    canvas.drawCircle(const Offset(32, 32), 22, Paint()..color = const Color(0xFF047857));
    canvas.drawCircle(const Offset(32, 32), 17, Paint()..color = const Color(0xFF12C97A));
    canvas.drawCircle(
      const Offset(32, 32),
      12.5,
      Paint()
        ..color = const Color(0xFFB8FFE0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: 'RSV',
        style: TextStyle(
          color: Color(0xFFF4FFF9),
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(32 - tp.width / 2, 32 - tp.height / 2));
  }

  void _idle(Canvas canvas) {
    canvas.drawCircle(
      const Offset(32, 32),
      14,
      Paint()..color = palette.textMuted.withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      const Offset(32, 32),
      8,
      Paint()
        ..color = palette.textMuted.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawLine(
      const Offset(32, 24),
      const Offset(32, 34),
      Paint()
        ..color = palette.textMuted.withValues(alpha: 0.7)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      const Offset(32, 40),
      1.8,
      Paint()..color = palette.textMuted.withValues(alpha: 0.7),
    );
  }

  void _fallback(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(12, 12, 40, 40),
        const Radius.circular(10),
      ),
      Paint()..color = palette.primary.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _SymbolPainter oldDelegate) {
    return oldDelegate.code != code || oldDelegate.palette != palette;
  }
}
