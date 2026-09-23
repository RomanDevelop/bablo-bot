import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../components/trading_card.dart';
import '../../../../../core/constants/sportsbook_constants.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../models/sportsbook_model.dart';

class SportsbookEventCard extends StatelessWidget {
  const SportsbookEventCard({
    super.key,
    required this.event,
    this.onOpen,
    this.showPlaceCta = true,
  });

  final SportsbookEvent event;
  final VoidCallback? onOpen;
  final bool showPlaceCta;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final starts = event.startsAt == null
        ? '—'
        : DateFormat('dd MMM, HH:mm', 'ru').format(event.startsAt!);
    final canBet = event.canPlaceBet;

    return TradingCard(
      onTap: onOpen,
      borderColor: canBet ? p.primary.withValues(alpha: 0.25) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              _StatusBadge(event: event),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            starts,
            style: TextStyle(color: p.textSecondary, fontSize: 13),
          ),
          if (showPlaceCta) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                canBet
                    ? SportsbookConstants.placeCta
                    : event.isLive
                        ? SportsbookConstants.liveBadge
                        : SportsbookConstants.errorEventClosed,
                style: TextStyle(
                  color: canBet ? p.primary : p.textMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.event});

  final SportsbookEvent event;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final Color color;
    final String label;
    if (event.isLive) {
      color = p.danger;
      label = SportsbookConstants.liveBadge;
    } else if (event.isFinished) {
      color = p.textMuted;
      label = SportsbookConstants.finishedBadge;
    } else {
      color = p.primary;
      label = SportsbookConstants.scheduledBadge;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
