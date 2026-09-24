import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../components/trading_card.dart';
import '../../../../../core/constants/sportsbook_constants.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../models/sportsbook_model.dart';

class SportsbookHistoryList extends StatelessWidget {
  const SportsbookHistoryList({
    super.key,
    required this.items,
    this.showTitle = true,
  });

  final List<SportsbookBet> items;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            SportsbookConstants.historyTitle,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (items.isEmpty)
          TradingCard(
            child: Text(
              SportsbookConstants.historyEmpty,
              style: TextStyle(color: p.textSecondary),
            ),
          )
        else
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _BetTile(bet: items[i]),
          ],
      ],
    );
  }
}

class _BetTile extends StatelessWidget {
  const _BetTile({required this.bet});

  final SportsbookBet bet;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final date = bet.acceptedAt == null
        ? '—'
        : DateFormat('dd MMM HH:mm', 'ru').format(bet.acceptedAt!);
    final statusColor = switch (bet.status.toUpperCase()) {
      SportsbookConstants.statusWon => p.success,
      SportsbookConstants.statusLost => p.danger,
      SportsbookConstants.statusVoid => p.textMuted,
      _ => p.primary,
    };

    return TradingCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bet.eventTitle,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${bet.outcomeName} · ${SportsbookConstants.rsv(bet.stake)} @ ${SportsbookConstants.odds(bet.acceptedOdds)}',
                  style: TextStyle(color: p.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(color: p.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                SportsbookConstants.statusLabel(bet.status),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
              if (bet.potentialPayout > 0 && (bet.isOpen || bet.isWon)) ...[
                const SizedBox(height: 4),
                Text(
                  bet.isWon
                      ? SportsbookConstants.rsv(bet.potentialPayout)
                      : '≈ ${SportsbookConstants.rsv(bet.potentialPayout)}',
                  style: context.tradingText.monoSmall.copyWith(
                    color: bet.isWon ? p.success : p.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
