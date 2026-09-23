import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../components/trading_card.dart';
import '../../../../../core/constants/sportsbook_constants.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../models/sportsbook_model.dart';

class SportsbookBalanceStrip extends StatelessWidget {
  const SportsbookBalanceStrip({super.key, required this.status});

  final SportsbookStatus status;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MetricTile(
                label: SportsbookConstants.availableRsv,
                value: SportsbookConstants.rsv(status.availableRsv),
              ),
              MetricTile(
                label: SportsbookConstants.inCopy,
                value: SportsbookConstants.rsv(status.committedCopyRsv),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            SportsbookConstants.balanceHint,
            style: TextStyle(color: p.textMuted, fontSize: 12, height: 1.35),
          ),
        ],
      ),
    );
  }
}
