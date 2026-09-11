import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/copy_constants.dart';
import '../../../../../core/navigation/app_routes.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../models/copy_model.dart';

class CopyNavigator {
  CopyNavigator(this._context);

  final BuildContext _context;

  void goToSubscriptions() {
    Navigator.of(_context).pushNamed(AppRoutes.subscriptions);
  }

  void goToProfile() {
    Navigator.of(_context).pushNamed(AppRoutes.profile);
  }

  Future<bool> confirmEarlyExit({required CopyStatus status}) async {
    final stake = status.stake;
    if (stake == null) return false;
    final penalty = status.estimatedPenalty(stake.equityRsv);
    final p = _context.read<ThemeController>().palette;

    final result = await showDialog<bool>(
      context: _context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(CopyConstants.exitTitle),
          content: Text(
            CopyConstants.exitConfirmBody(
              penaltyPct: CopyConstants.plain(status.earlyExitPenaltyPct),
              equity: CopyConstants.plain(stake.equityRsv),
              burned: CopyConstants.plain(penalty),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text(CopyConstants.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: p.danger,
                foregroundColor: p.onPrimary,
              ),
              child: const Text(CopyConstants.exitCta),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<num?> promptTopup({required num maxAmount}) async {
    final p = _context.read<ThemeController>().palette;
    final initial = maxAmount >= 100 ? 100 : maxAmount;
    final controller = TextEditingController(text: initial.toString());
    final result = await showDialog<num>(
      context: _context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(CopyConstants.topupTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                CopyConstants.topupBody,
                style: TextStyle(color: p.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(
                'Максимум ${CopyConstants.rsv(maxAmount)}',
                style: TextStyle(color: p.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  labelText: 'RSV',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.controlRadius),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(CopyConstants.cancel),
            ),
            FilledButton(
              onPressed: () {
                final raw = controller.text.replaceAll(',', '.').trim();
                final value = num.tryParse(raw);
                if (value == null || value <= 0) {
                  Navigator.of(ctx).pop();
                  return;
                }
                Navigator.of(ctx).pop(value > maxAmount ? maxAmount : value);
              },
              child: const Text(CopyConstants.confirm),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }
}
