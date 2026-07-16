import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'status_chip.dart';

/// Subtle AppBar CTA — ghost chip + primary accent, not a loud solid button.
class StatsActionButton extends StatelessWidget {
  const StatsActionButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Stats · доходность эпохи',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(StatusChip.radius),
          child: Ink(
            height: StatusChip.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(StatusChip.radius),
              color: AppColors.surfaceElevated,
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _StatsGlyph(size: 13),
                  const SizedBox(width: 7),
                  Text(
                    'Stats',
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.92),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.55),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsGlyph extends StatelessWidget {
  const _StatsGlyph({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _StatsGlyphPainter()),
    );
  }
}

class _StatsGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.45
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final fill = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    final p0 = Offset(w * 0.08, h * 0.78);
    final p1 = Offset(w * 0.34, h * 0.42);
    final p2 = Offset(w * 0.58, h * 0.58);
    final p3 = Offset(w * 0.88, h * 0.18);

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy);
    canvas.drawPath(path, stroke);

    for (final p in [p0, p1, p2, p3]) {
      canvas.drawCircle(p, 1.2, fill);
    }

    _drawSpark(canvas, Offset(w * 0.78, h * 0.04), 2.6, fill);
  }

  void _drawSpark(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = i * (math.pi / 2) - math.pi / 4;
      final outer = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      final midA = a + math.pi / 4;
      final inner = Offset(
        c.dx + r * 0.28 * math.cos(midA),
        c.dy + r * 0.28 * math.sin(midA),
      );
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
