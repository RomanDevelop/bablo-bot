import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_controller.dart';

class GlassCircleButton extends StatelessWidget {
  const GlassCircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.accent = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final button = Material(
      color: accent ? p.primary : p.navGlass,
      shape: CircleBorder(
        side: BorderSide(color: p.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            icon,
            color: accent ? p.onPrimary : p.textPrimary,
            size: 22,
          ),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class AiChatFloatingButton extends StatelessWidget {
  const AiChatFloatingButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassCircleButton(
      icon: Icons.auto_awesome_rounded,
      tooltip: 'AI Assistant',
      accent: true,
      onPressed: onPressed,
    );
  }
}

class GlobalSearchButton extends StatelessWidget {
  const GlobalSearchButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassCircleButton(
      icon: Icons.search_rounded,
      tooltip: 'Поиск',
      onPressed: onPressed,
    );
  }
}
