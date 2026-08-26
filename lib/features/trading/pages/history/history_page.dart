import 'package:flutter/material.dart';

import '../../../../components/feedback.dart';
import '../../../../components/navigation/side_menu_button.dart';
import '../../../../components/trading_card.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_format.dart';
import '../../models/trade_model.dart';
import '../trades/di/trades_wm_builder.dart';
import '../trades/trades_wm.dart';

/// History tab — same Trades WM / API, refreshed presentation.
class HistoryPage extends CoreMwwmWidget<TradesWidgetModel> {
  HistoryPage({super.key, this.onOpenMenu})
      : super(widgetModelBuilder: createTradesWidgetModel);

  final VoidCallback? onOpenMenu;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState
    extends MwwmWidgetState<HistoryPage, TradesWidgetModel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TradesState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const TradesState();
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            title: Text(
              'История',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    AppNavigator.pushNamed(context, AppRoutes.stats),
                child: Text(
                  'Stats',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SideMenuButton(onPressed: widget.onOpenMenu ?? () {}),
              ),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () => wm.refresh(forceRefresh: true),
            child: _body(context, state),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, TradesState state) {
    if (state.isLoading && state.trades.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 180), PageLoading()],
      );
    }

    if (state.error != null && state.trades.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          ErrorBanner(message: state.error!, onRetry: () => wm.refresh()),
        ],
      );
    }

    if (state.trades.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: const [
          EmptyState(
            title: 'Сделок пока нет',
            subtitle: 'Pull-to-refresh — fills подтягиваются с Binance',
            icon: Icons.history_rounded,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: state.trades.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _HistoryTradeTile(trade: state.trades[index]);
      },
    );
  }
}

class _HistoryTradeTile extends StatelessWidget {
  const _HistoryTradeTile({required this.trade});

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sideColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trade.sideLabel,
                  style: TextStyle(
                    color: sideColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                trade.symbol,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                MoneyFormat.dateTime(trade.createdAt),
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
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
        ],
      ),
    );
  }
}
