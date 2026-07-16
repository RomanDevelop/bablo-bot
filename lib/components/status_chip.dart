import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Unified AppBar / status chip — same height, padding, type for all badges.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.background,
    this.icon,
    this.leading,
    this.onTap,
    this.emphasized = false,
  });

  final String label;
  final Color color;
  final Color? background;
  final IconData? icon;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool emphasized;

  static const double height = 32;
  static const double radius = 10;
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 10);

  @override
  Widget build(BuildContext context) {
    final bg = background ?? color.withValues(alpha: emphasized ? 0.22 : 0.14);
    final borderColor = color.withValues(alpha: emphasized ? 0.65 : 0.4);

    final content = Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 6),
          ] else if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 6),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.55),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
              height: 1,
            ),
          ),
        ],
      ),
    );

    return Material(
      color: bg,
      elevation: 0,
      shadowColor: emphasized ? color.withValues(alpha: 0.35) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor, width: emphasized ? 1.2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: onTap == null
            ? Align(alignment: Alignment.center, child: content)
            : InkWell(
                onTap: onTap,
                child: Align(alignment: Alignment.center, child: content),
              ),
      ),
    );
  }
}

class OnlineDot extends StatelessWidget {
  const OnlineDot({super.key, required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final color = online ? AppColors.online : AppColors.offline;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 6),
        ],
      ),
    );
  }
}
