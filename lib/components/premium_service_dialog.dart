import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/external_services_config.dart';
import '../core/navigation/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';

/// Explains that leisure services unlock only with Premium.
Future<void> showPremiumServiceDialog(
  BuildContext context,
  ExternalServiceLink link, {
  VoidCallback? onBeforeNavigate,
}) {
  final p = context.read<ThemeController>().palette;

  return showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: p.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ExternalServicesConfig.premiumGateTitle,
                style: TextStyle(
                  color: p.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          ExternalServicesConfig.premiumGateMessage(link.title),
          style: TextStyle(
            color: p.textSecondary,
            fontSize: 14,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Закрыть',
              style: TextStyle(color: p.textMuted, fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onBeforeNavigate?.call();
              Navigator.of(context).pushNamed(AppRoutes.subscriptions);
            },
            style: FilledButton.styleFrom(
              backgroundColor: p.primary,
              foregroundColor: p.onPrimary,
            ),
            child: const Text('Оформить Premium'),
          ),
        ],
      );
    },
  );
}
