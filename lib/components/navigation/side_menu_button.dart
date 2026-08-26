import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_controller.dart';
import '../status_chip.dart';

/// AppBar menu trigger — ghost chip + primary accent, matches Stats button.
class SideMenuButton extends StatelessWidget {
  const SideMenuButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;

    return Tooltip(
      message: 'Menu',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(StatusChip.radius),
          child: Ink(
            height: StatusChip.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(StatusChip.radius),
              color: p.surfaceElevated,
              border: Border.all(color: p.primary.withValues(alpha: 0.35)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.grid_view_rounded,
                    size: 14,
                    color: p.primary,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: p.textPrimary.withValues(alpha: 0.92),
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
                      color: p.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: p.primary.withValues(alpha: 0.55),
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
