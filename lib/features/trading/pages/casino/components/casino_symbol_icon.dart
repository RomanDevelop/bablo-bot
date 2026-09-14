import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_palette.dart';

/// Draws slot symbols with CustomPaint (works on Flutter web / Telegram).
/// No AssetBundle — avoids missing-image / idle-"!" confusion.
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final size = side.isFinite && side > 0 ? side : 48.0;
        return Center(
          child: CustomPaint(
            size: Size.square(size * 0.92),
            painter: _SymbolPainter(code: code, palette: palette),
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
      ..color = const Color(0xFF5B8C3E)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(const Rect.fromLTWH(24, 6, 18, 22), -1.3, 1.7, false, stem);
    canvas.drawOval(
      const Rect.fromLTWH(8, 26, 26, 30),
      Paint()..color = const Color(0xFFFF2D55),
    );
    canvas.drawOval(
      const Rect.fromLTWH(30, 26, 26, 30),
      Paint()..color = const Color(0xFFE0113A),
    );
    canvas.drawOval(
      const Rect.fromLTWH(14, 32, 8, 10),
      Paint()..color = const Color(0xFFFF8FA3),
    );
  }

  void _coin(Canvas canvas) {
    canvas.drawCircle(const Offset(32, 32), 24, Paint()..color = const Color(0xFFE8B923));
    canvas.drawCircle(const Offset(32, 32), 19, Paint()..color = const Color(0xFFFFE082));
    canvas.drawCircle(
      const Offset(32, 32),
      14,
      Paint()
        ..color = const Color(0xFFC4920A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: '\$',
        style: TextStyle(
          color: Color(0xFF8A6A00),
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(32 - tp.width / 2, 32 - tp.height / 2));
  }

  void _bar(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6, 18, 52, 28),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF2A3344),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 22, 44, 20),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF5A6B88),
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: 'BAR',
        style: TextStyle(
          color: Color(0xFFF4F7FF),
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(32 - tp.width / 2, 32 - tp.height / 2));
  }

  void _seven(Canvas canvas) {
    final path = Path()
      ..moveTo(14, 12)
      ..lineTo(50, 12)
      ..lineTo(50, 20)
      ..lineTo(30, 52)
      ..lineTo(18, 52)
      ..lineTo(38, 20)
      ..lineTo(14, 20)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF2470F5));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF8EC2FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _diamond(Canvas canvas) {
    final outer = Path()
      ..moveTo(32, 6)
      ..lineTo(54, 32)
      ..lineTo(32, 58)
      ..lineTo(10, 32)
      ..close();
    canvas.drawPath(outer, Paint()..color = const Color(0xFF00C853));
    final inner = Path()
      ..moveTo(32, 16)
      ..lineTo(44, 32)
      ..lineTo(32, 48)
      ..lineTo(20, 32)
      ..close();
    canvas.drawPath(inner, Paint()..color = const Color(0xFFB9F6CA));
  }

  void _bablo(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 8, 48, 48),
        const Radius.circular(14),
      ),
      Paint()..color = const Color(0xFFFFC94A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(14, 14, 36, 36),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF2A1C05),
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: 'B',
        style: TextStyle(
          color: Color(0xFFFFC94A),
          fontSize: 26,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(32 - tp.width / 2, 32 - tp.height / 2));
  }

  void _wild(Canvas canvas) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? 24.0 : 10.0;
      final x = 32 + math.cos(a) * r;
      final y = 32 + math.sin(a) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFD166));
  }

  void _rsv(Canvas canvas) {
    canvas.drawCircle(const Offset(32, 32), 24, Paint()..color = const Color(0xFF047857));
    canvas.drawCircle(const Offset(32, 32), 18, Paint()..color = const Color(0xFF12C97A));
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
      Paint()..color = const Color(0xFF243044),
    );
    canvas.drawCircle(
      const Offset(32, 32),
      6,
      Paint()..color = palette.textMuted.withValues(alpha: 0.35),
    );
  }

  void _fallback(Canvas canvas, String code) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 8, 48, 48),
        const Radius.circular(10),
      ),
      Paint()..color = palette.primary.withValues(alpha: 0.9),
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
