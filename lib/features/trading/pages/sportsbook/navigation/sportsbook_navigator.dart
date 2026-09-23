import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/sportsbook_constants.dart';
import '../../../../../core/navigation/app_routes.dart';
import '../../../../../core/theme/theme_controller.dart';

class SportsbookNavigator {
  SportsbookNavigator(this._context);

  final BuildContext _context;

  void goToSubscriptions() {
    Navigator.of(_context).pushNamed(AppRoutes.subscriptions);
  }

  void goToProfile() {
    Navigator.of(_context).pushNamed(AppRoutes.profile);
  }

  void goToEvents() {
    Navigator.of(_context).pushNamed(AppRoutes.sportsbookEvents);
  }

  void goToEvent(String eventId) {
    Navigator.of(_context).pushNamed(AppRoutes.sportsbookEvent(eventId));
  }

  void goToHistory() {
    Navigator.of(_context).pushNamed(AppRoutes.sportsbookBets);
  }

  Future<bool> confirmPlaceBet({
    required String outcome,
    required num stake,
    required num odds,
  }) async {
    final p = _context.read<ThemeController>().palette;
    final result = await showDialog<bool>(
      context: _context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(SportsbookConstants.confirmTitle),
          content: Text(
            SportsbookConstants.confirmBody(
              outcome: outcome,
              stake: SportsbookConstants.plain(stake),
              odds: SportsbookConstants.odds(odds),
              preview: SportsbookConstants.plain(stake * odds),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text(SportsbookConstants.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: p.primary,
                foregroundColor: p.onPrimary,
              ),
              child: const Text(SportsbookConstants.confirmCta),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
