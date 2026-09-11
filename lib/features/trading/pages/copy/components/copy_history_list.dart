import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../components/trading_card.dart';
import '../../../../../core/constants/copy_constants.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../models/copy_model.dart';

class CopyHistoryList extends StatelessWidget {
  const CopyHistoryList({super.key, required this.items});

  final List<CopyHistoryItem> items;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          CopyConstants.historyTitle,
          style: TextStyle(
            color: p.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          TradingCard(
            child: Text(
              CopyConstants.historyEmpty,
              style: TextStyle(color: p.textSecondary),
            ),
          )
        else
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _HistoryTile(item: items[i]),
          ],
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final CopyHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final actionColor = item.isBuy
        ? p.buy
        : item.isSell
            ? p.sell
            : p.hold;
    final deltaColor = item.deltaPositive
        ? p.positive
        : item.deltaNegative
            ? p.negative
            : p.textPrimary;
    final date = item.createdAt == null
        ? '—'
        : DateFormat('dd MMM HH:mm', 'ru').format(item.createdAt!);
    final pnl = item.masterPnlPct;

    return TradingCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.symbol,
                  style: context.tradingText.monoMedium.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
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
                item.action.isEmpty ? '—' : item.action.toUpperCase(),
                style: TextStyle(
                  color: actionColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _signedRsv(item.deltaRsv),
                style: context.tradingText.monoSmall.copyWith(
                  color: deltaColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (pnl != null) ...[
                const SizedBox(height: 2),
                Text(
                  '${pnl > 0 ? '+' : ''}${pnl.toStringAsFixed(2)}%',
                  style: TextStyle(color: p.textMuted, fontSize: 11),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static String _signedRsv(num value) {
    final body = CopyConstants.rsv(value.abs());
    if (value > 0) return '+$body';
    if (value < 0) return '−$body';
    return body;
  }
}
