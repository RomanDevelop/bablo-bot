import 'package:flutter/material.dart';

import '../../../../../core/constants/casino_constants.dart';
import '../../../../../core/navigation/app_routes.dart';
import '../../../models/casino_model.dart';

class CasinoNavigator {
  CasinoNavigator(this._context);

  final BuildContext _context;

  void goToSubscriptions() {
    Navigator.of(_context).pushNamed(AppRoutes.subscriptions);
  }

  void goToProfile() {
    Navigator.of(_context).pushNamed(AppRoutes.profile);
  }

  void openGame(String gameId) {
    Navigator.of(_context).pushNamed(AppRoutes.casinoGame(gameId));
  }

  Future<bool> confirmRsvBet({
    required CasinoBalance balance,
    required num bet,
  }) async {
    final result = await showDialog<bool>(
      context: _context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(CasinoConstants.rsvConfirmTitle),
          content: Text(
            CasinoConstants.rsvConfirmBody(
              available: CasinoConstants.amount(balance.rsv.available),
              committed: CasinoConstants.amount(balance.rsv.committedCopy),
              bet: CasinoConstants.amount(bet),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Поставить'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
