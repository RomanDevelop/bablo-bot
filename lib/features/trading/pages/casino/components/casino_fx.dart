import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/constants/casino_constants.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_theme.dart';

/// Gold machine bezel with living neon pulse.
class CasinoMachineFrame extends StatelessWidget {
  const CasinoMachineFrame({
    super.key,
    required this.palette,
    required this.pulse,
    required this.spinning,
    required this.child,
  });

  final AppPalette palette;
  final double pulse;
  final bool spinning;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gold =
        Color.lerp(
          const Color(0xFFB8860B),
          const Color(0xFFFFE082),
          spinning ? 0.55 + 0.45 * pulse : 0.22 + 0.18 * pulse,
        )!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gold, const Color(0xFF5A3A0A), gold.withValues(alpha: 0.85)],
        ),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.28 + 0.32 * pulse),
            blurRadius: spinning ? 28 : 16,
            spreadRadius: spinning ? 1.5 : 0,
          ),
          BoxShadow(
            color: palette.primary.withValues(alpha: spinning ? 0.22 : 0.08),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3.5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF07050A),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: child,
      ),
    );
  }
}

class CasinoPaylinePainter extends CustomPainter {
  CasinoPaylinePainter({
    required this.positions,
    required this.rows,
    required this.cols,
    required this.color,
    required this.pulse,
  });

  final List<List<int>> positions;
  final int rows;
  final int cols;
  final Color color;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2 || rows <= 0 || cols <= 0) return;
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final path = Path();
    for (var i = 0; i < positions.length; i++) {
      final pos = positions[i];
      if (pos.length < 2) continue;
      final x = (pos[1] + 0.5) * cellW;
      final y = (pos[0] + 0.5) * cellH;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final glow =
        Paint()
          ..color = color.withValues(alpha: 0.18 + 0.28 * pulse)
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    final core =
        Paint()
          ..color = Color.lerp(color, Colors.white, 0.45 + 0.25 * pulse)!
          ..strokeWidth = 2.6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, glow);
    canvas.drawPath(path, core);
    for (final pos in positions) {
      if (pos.length < 2) continue;
      final c = Offset((pos[1] + 0.5) * cellW, (pos[0] + 0.5) * cellH);
      canvas.drawCircle(
        c,
        7 + 3 * pulse,
        Paint()..color = color.withValues(alpha: 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CasinoPaylinePainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.color != color ||
        oldDelegate.rows != rows ||
        oldDelegate.cols != cols ||
        oldDelegate.positions != positions;
  }
}

class CasinoSparklePainter extends CustomPainter {
  CasinoSparklePainter({
    required this.t,
    required this.color,
    required this.origins,
  });

  final double t;
  final Color color;
  final List<Offset> origins;

  @override
  void paint(Canvas canvas, Size size) {
    final pts =
        origins.isEmpty
            ? <Offset>[Offset(size.width / 2, size.height / 2)]
            : origins;
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 28; i++) {
      final origin = pts[i % pts.length];
      final ang = i * 0.47 + t * math.pi * 2;
      final dist = 16.0 + (i % 7) * 10.0 * (0.45 + 0.55 * ((t + i * 0.08) % 1));
      final p =
          origin + Offset(math.cos(ang) * dist, math.sin(ang * 1.3) * dist);
      final r = 1.2 + (i % 4) * 0.7;
      paint.color = Color.lerp(
        color,
        Colors.white,
        (i % 3) * 0.25,
      )!.withValues(alpha: 0.25 + 0.55 * (1 - ((t + i * 0.1) % 1)));
      canvas.drawCircle(p, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CasinoSparklePainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color;
  }
}

class CasinoWinBanner extends StatelessWidget {
  const CasinoWinBanner({
    super.key,
    required this.amount,
    required this.palette,
  });

  final num amount;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.82, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF7A4A00), Color(0xFFE0A020), Color(0xFF7A4A00)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE0A020).withValues(alpha: 0.45),
              blurRadius: 18,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFFFF8E1), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'WIN  ${CasinoConstants.amount(amount)}',
                style: const TextStyle(
                  color: Color(0xFFFFF8E1),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CasinoSpinButton extends StatelessWidget {
  const CasinoSpinButton({
    super.key,
    required this.busy,
    required this.spinning,
    required this.label,
    required this.palette,
    required this.onPressed,
  });

  final bool busy;
  final bool spinning;
  final String label;
  final AppPalette palette;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: busy ? 0.97 : 1),
      duration: const Duration(milliseconds: 180),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.controlRadius),
            boxShadow:
                spinning
                    ? [
                      BoxShadow(
                        color: palette.primary.withValues(alpha: 0.45),
                        blurRadius: 22,
                        spreadRadius: 1,
                      ),
                    ]
                    : const [],
          ),
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: palette.primary,
              foregroundColor: palette.onPrimary,
              disabledBackgroundColor: palette.primary.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.controlRadius),
              ),
            ),
            child:
                spinning
                    ? const _SpinningLabel()
                    : busy
                    ? const Text(
                      'WAIT',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 2.2,
                      ),
                    )
                    : Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 1.4,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}

class _SpinningLabel extends StatefulWidget {
  const _SpinningLabel();

  @override
  State<_SpinningLabel> createState() => _SpinningLabelState();
}

class _SpinningLabelState extends State<_SpinningLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: _ctrl.value * math.pi * 2,
              child: const Icon(Icons.casino_rounded, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'SPINNING',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 2.2,
              ),
            ),
          ],
        );
      },
    );
  }
}
