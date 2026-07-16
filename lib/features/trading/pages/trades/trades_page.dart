import 'package:flutter/material.dart';

import '../../../../components/feedback.dart';
import '../../../../components/trading_card.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_format.dart';
import '../../models/trade_model.dart';
import 'di/trades_wm_builder.dart';
import 'trades_wm.dart';

class TradesPage extends CoreMwwmWidget<TradesWidgetModel> {
  TradesPage({super.key}) : super(widgetModelBuilder: createTradesWidgetModel);

  @override
  State<TradesPage> createState() => _TradesPageState();
}

class _TradesPageState extends MwwmWidgetState<TradesPage, TradesWidgetModel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TradesState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const TradesState();
        return Scaffold(
          appBar: AppBar(title: const Text('Trades')),
          body: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () => wm.refresh(),
            child: _buildBody(state),
          ),
        );
      },
    );
  }

  Widget _buildBody(TradesState state) {
    if (state.isLoading && state.trades.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 180), PageLoading()],
      );
    }

    if (state.error != null && state.trades.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          ErrorBanner(message: state.error!, onRetry: () => wm.refresh()),
        ],
      );
    }

    if (state.trades.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 80),
          EmptyState(
            title: 'Сделок пока нет',
            subtitle: 'История эпохи появится после первых fills бота',
            icon: Icons.candlestick_chart_outlined,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      itemCount: state.trades.length + (state.error != null ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (state.error != null && index == 0) {
          return ErrorBanner(message: state.error!, onRetry: () => wm.refresh());
        }
        final trade = state.trades[state.error != null ? index - 1 : index];
        return _TradeTile(trade: trade);
      },
    );
  }
}

class _TradeTile extends StatelessWidget {
  const _TradeTile({required this.trade});
  final Trade trade;

  @override
  Widget build(BuildContext context) {
    final sideColor = trade.isBuy
        ? AppColors.buy
        : trade.isSell
            ? AppColors.sell
            : AppColors.hold;
    final pnlColor = MoneyFormat.isPositive(trade.realizedPnl)
        ? AppColors.buy
        : MoneyFormat.isNegative(trade.realizedPnl)
            ? AppColors.sell
            : AppColors.textSecondary;

    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sideColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trade.side,
                  style: TextStyle(
                    color: sideColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                trade.symbol,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                MoneyFormat.dateTime(trade.createdAt),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${MoneyFormat.trim(trade.quantity)} @ '
                  '${MoneyFormat.trim(trade.price, maxDecimals: 2)}',
                  style: context.tradingText.monoMedium.copyWith(fontSize: 14),
                ),
              ),
              if (trade.hasPnl)
                Text(
                  MoneyFormat.signedUsd(trade.realizedPnl),
                  style: context.tradingText.monoSmall.copyWith(
                    color: pnlColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          if (trade.reason != null && trade.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              trade.reason!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
          if (trade.entryPrice != null) ...[
            const SizedBox(height: 6),
            Text(
              'Entry ${MoneyFormat.trim(trade.entryPrice, maxDecimals: 2)}',
              style: context.tradingText.monoSmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
