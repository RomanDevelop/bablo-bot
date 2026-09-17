import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/constants/casino_symbol_assets.dart';
import '../../../../../core/theme/app_palette.dart';

/// Premium collage crops on the reel; CustomPaint only if an asset fails.
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
    final asset = CasinoSymbolAssets.pathFor(symbol, idle: idle);
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final size = side.isFinite && side > 0 ? side : 48.0;
        final box = size * ((idle || code == 'IDLE') ? 0.72 : 0.94);
        return Center(
          child: Opacity(
            opacity: (idle || code == 'IDLE') ? 0.55 : 1,
            child: SizedBox(
              width: box,
              height: box,
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return CustomPaint(
                    size: Size.square(box),
                    painter: _SymbolPainter(code: code, palette: palette),
                  );
                },
              ),
            ),
          ),
        );
      },
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
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
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
        _fallback(canvas, code);
    }
    canvas.restore();
  }

  void _cherry(Canvas canvas) {
    final stem = Paint()
      ..color = const Color(0xFF7CFF6B)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(const Rect.fromLTWH(22, 4, 20, 24), -1.35, 1.8, false, stem);
    canvas.drawArc(const Rect.fromLTWH(28, 4, 16, 20), -0.4, 1.2, false, stem);
    canvas.drawOval(
      const Rect.fromLTWH(6, 24, 28, 32),
      Paint()..color = const Color(0xFFFF1A6D),
    );
    canvas.drawOval(
      const Rect.fromLTWH(30, 22, 28, 34),
      Paint()..color = const Color(0xFFC4004A),
    );
    canvas.drawOval(
      const Rect.fromLTWH(12, 30, 9, 11),
      Paint()..color = const Color(0xFFFF8FB8),
    );
    canvas.drawOval(
      const Rect.fromLTWH(36, 28, 8, 10),
      Paint()..color = const Color(0xFFFF5A93),
    );
  }

  void _coin(Canvas canvas) {
    canvas.drawCircle(const Offset(32, 32), 25, Paint()..color = const Color(0xFFFF2D78));
    canvas.drawCircle(const Offset(32, 32), 22, Paint()..color = const Color(0xFFFFD54A));
    canvas.drawCircle(const Offset(32, 32), 17, Paint()..color = const Color(0xFFFFF0A8));
    canvas.drawCircle(
      const Offset(32, 32),
      13,
      Paint()
        ..color = const Color(0xFFC47A00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    final heart = Path()
      ..moveTo(32, 42)
      ..cubicTo(18, 32, 20, 22, 32, 26)
      ..cubicTo(44, 22, 46, 32, 32, 42);
    canvas.drawPath(heart, Paint()..color = const Color(0xFFFF1A6D));
  }

  void _bar(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(4, 16, 56, 32),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF3A0518),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(7, 19, 50, 26),
        const Radius.circular(3),
      ),
      Paint()
        ..color = const Color(0xFFFF2D78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: 'BAR',
        style: TextStyle(
          color: Color(0xFFFFF1F6),
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(32 - tp.width / 2, 32 - tp.height / 2));
  }

  void _seven(Canvas canvas) {
    final glow = Path()
      ..moveTo(12, 10)
      ..lineTo(52, 10)
      ..lineTo(52, 20)
      ..lineTo(28, 54)
      ..lineTo(14, 54)
      ..lineTo(38, 20)
      ..lineTo(12, 20)
      ..close();
    canvas.drawPath(glow, Paint()..color = const Color(0xFFFF4D9A));
    canvas.drawPath(
      glow,
      Paint()
        ..color = const Color(0xFFFFD0E6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  void _diamond(Canvas canvas) {
    final outer = Path()
      ..moveTo(32, 6)
      ..lineTo(54, 26)
      ..lineTo(32, 58)
      ..lineTo(10, 26)
      ..close();
    canvas.drawPath(outer, Paint()..color = const Color(0xFFFF4DA6));
    final facet = Path()
      ..moveTo(32, 6)
      ..lineTo(44, 26)
      ..lineTo(32, 26)
      ..close();
    canvas.drawPath(facet, Paint()..color = const Color(0xFFFFB7DC));
    final inner = Path()
      ..moveTo(32, 26)
      ..lineTo(44, 26)
      ..lineTo(32, 58)
      ..close();
    canvas.drawPath(inner, Paint()..color = const Color(0xFFE01478));
  }

  void _bablo(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(7, 7, 50, 50),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xFFFF2D78),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(13, 13, 38, 38),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFF1A0510),
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: 'B',
        style: TextStyle(
          color: Color(0xFFFFD54A),
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(32 - tp.width / 2, 32 - tp.height / 2));
  }

  void _wild(Canvas canvas) {
    // Lipstick kiss — vulgar club mark, not anatomy.
    final lips = Path()
      ..moveTo(12, 30)
      ..cubicTo(16, 18, 28, 16, 32, 24)
      ..cubicTo(36, 16, 48, 18, 52, 30)
      ..cubicTo(48, 38, 38, 48, 32, 50)
      ..cubicTo(26, 48, 16, 38, 12, 30)
      ..close();
    canvas.drawPath(lips, Paint()..color = const Color(0xFFFF1A4D));
    canvas.drawPath(
      Path()
        ..moveTo(16, 30)
        ..cubicTo(24, 36, 40, 36, 48, 30),
      Paint()
        ..color = const Color(0xFF8A0028)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      const Rect.fromLTWH(22, 24, 8, 5),
      Paint()..color = const Color(0xFFFF8AA8),
    );
  }

  void _rsv(Canvas canvas) {
    canvas.drawCircle(const Offset(32, 32), 24, Paint()..color = const Color(0xFFFF2D78));
    canvas.drawCircle(const Offset(32, 32), 19, Paint()..color = const Color(0xFF12C97A));
    final tp = TextPainter(
      text: const TextSpan(
        text: 'RSV',
        style: TextStyle(
          color: Color(0xFFF4FFF9),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(32 - tp.width / 2, 32 - tp.height / 2));
  }

  void _idle(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 8, 48, 48),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFF1C0A14),
    );
    canvas.drawCircle(
      const Offset(32, 32),
      7,
      Paint()..color = const Color(0xFFFF2D78).withValues(alpha: 0.28),
    );
  }

  void _fallback(Canvas canvas, String code) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 8, 48, 48),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFFFF2D78),
    );
    final label = code.length <= 4 ? code : code.substring(0, 4);
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(32 - tp.width / 2, 32 - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _SymbolPainter oldDelegate) {
    return oldDelegate.code != code || oldDelegate.palette != palette;
  }
}
