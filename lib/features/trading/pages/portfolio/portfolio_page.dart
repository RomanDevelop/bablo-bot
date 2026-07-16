import 'package:flutter/material.dart';

import '../../../../components/feedback.dart';
import '../../../../components/status_chip.dart';
import '../../../../components/trading_card.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_format.dart';
import '../../models/portfolio_model.dart';
import 'di/portfolio_wm_builder.dart';
import 'portfolio_wm.dart';

class PortfolioPage extends CoreMwwmWidget<PortfolioWidgetModel> {
  PortfolioPage({super.key})
      : super(widgetModelBuilder: createPortfolioWidgetModel);

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState
    extends MwwmWidgetState<PortfolioPage, PortfolioWidgetModel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PortfolioState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const PortfolioState();

        if (state.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final msg = wm.stateStream.value.message;
            if (msg == null) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
            wm.stateStream.add(wm.stateStream.value.copyWith(clearMessage: true));
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Portfolio')),
          body: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () => wm.refresh(),
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PortfolioState state) {
    if (state.isLoading && state.portfolio == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 180), PageLoading()],
      );
    }

    final p = state.portfolio;
    if (p == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (state.error != null)
            ErrorBanner(message: state.error!, onRetry: () => wm.refresh()),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        if (state.error != null) ...[
          ErrorBanner(message: state.error!, onRetry: () => wm.refresh()),
          const SizedBox(height: 12),
        ],
        _SyncHeader(portfolio: p),
        const SizedBox(height: 12),
        _BotPositionSection(portfolio: p),
        const SizedBox(height: 12),
        _WalletSection(portfolio: p),
        if (p.hasIdle) ...[
          const SizedBox(height: 12),
          IdleBanner(
            assetLabel: p.baseAsset,
            message: p.idleBaseNote ?? p.syncNote,
          ),
        ],
        // TODO: временно скрыто — админ Reconcile / Adopt idle
        // const SizedBox(height: 20),
        // const SectionLabel('Админ'),
        // const SizedBox(height: 10),
        // Row(
        //   children: [
        //     Expanded(
        //       child: OutlinedButton(
        //         onPressed: state.isBusy ? null : () => wm.reconcile(),
        //         child: const Text('Reconcile'),
        //       ),
        //     ),
        //     const SizedBox(width: 10),
        //     Expanded(
        //       child: ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: AppColors.warning,
        //           foregroundColor: AppColors.onPrimary,
        //         ),
        //         onPressed: state.isBusy ? null : () => _confirmAdopt(context),
        //         child: const Text('Adopt idle'),
        //       ),
        //     ),
        //   ],
        // ),
        // if (state.isBusy) ...[
        //   const SizedBox(height: 16),
        //   const LinearProgressIndicator(
        //     color: AppColors.primary,
        //     backgroundColor: AppColors.border,
        //   ),
        // ],
        // if (p.whatCountsAsPosition != null) ...[
        //   const SizedBox(height: 18),
        //   Text(
        //     p.whatCountsAsPosition!,
        //     style: const TextStyle(
        //       color: AppColors.textMuted,
        //       fontSize: 12,
        //       height: 1.4,
        //     ),
        //   ),
        // ],
      ],
    );
  }

  // Future<void> _confirmAdopt(BuildContext context) async {
  //   final ok = await showDialog<bool>(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('Adopt idle?'),
  //       content: const Text(
  //         'Весь base на кошельке станет tracked LONG по рынку. '
  //         'Это необратимо для позиции бота. Продолжить?',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx, false),
  //           child: const Text('Отмена'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx, true),
  //           child: const Text(
  //             'Adopt',
  //             style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  //   if (ok == true) await wm.adopt();
  // }
}

class _SyncHeader extends StatelessWidget {
  const _SyncHeader({required this.portfolio});
  final Portfolio portfolio;

  @override
  Widget build(BuildContext context) {
    final color = switch (portfolio.syncStatus) {
      'ok' => AppColors.buy,
      'ok_with_idle' || 'idle_base' => AppColors.warning,
      'short_inventory' => AppColors.danger,
      _ => AppColors.textMuted,
    };

    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                portfolio.symbol,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              StatusChip(label: portfolio.syncStatus.toUpperCase(), color: color),
            ],
          ),
          if (portfolio.syncNote.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              portfolio.syncNote,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _BotPositionSection extends StatelessWidget {
  const _BotPositionSection({required this.portfolio});
  final Portfolio portfolio;

  @override
  Widget build(BuildContext context) {
    final pnlColor = MoneyFormat.isPositive(portfolio.botUnrealizedPnl)
        ? AppColors.buy
        : MoneyFormat.isNegative(portfolio.botUnrealizedPnl)
            ? AppColors.sell
            : AppColors.textSecondary;

    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Bot position'),
          const SizedBox(height: 12),
          if (!portfolio.botOpen)
            const Text(
              'Нет tracked позиции',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else ...[
            Text(
              '${portfolio.botSide ?? 'LONG'}  '
              '${MoneyFormat.trim(portfolio.botQuantity)} @ '
              '${MoneyFormat.trim(portfolio.botEntryPrice, maxDecimals: 2)}',
              style: context.tradingText.monoMedium,
            ),
            const SizedBox(height: 8),
            KeyValueRow(
              label: 'Unrealized PnL',
              value: MoneyFormat.signedUsd(portfolio.botUnrealizedPnl),
              valueColor: pnlColor,
            ),
            KeyValueRow(
              label: 'Entry time',
              value: MoneyFormat.dateTime(portfolio.botEntryTime),
              mono: false,
            ),
          ],
        ],
      ),
    );
  }
}

class _WalletSection extends StatelessWidget {
  const _WalletSection({required this.portfolio});
  final Portfolio portfolio;

  @override
  Widget build(BuildContext context) {
    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Wallet'),
          const SizedBox(height: 8),
          KeyValueRow(
            label: 'Equity',
            value: MoneyFormat.usd(portfolio.equity),
          ),
          KeyValueRow(
            label: '${portfolio.baseAsset} balance',
            value: MoneyFormat.trim(portfolio.baseBalance),
          ),
          KeyValueRow(
            label: '${portfolio.quoteAsset} balance',
            value: MoneyFormat.trim(portfolio.quoteBalance, maxDecimals: 2),
          ),
          KeyValueRow(
            label: 'Idle ${portfolio.baseAsset}',
            value: MoneyFormat.trim(portfolio.idleBase),
            valueColor: portfolio.hasIdle ? AppColors.warning : null,
          ),
          KeyValueRow(
            label: 'Price',
            value: MoneyFormat.trim(portfolio.price, maxDecimals: 2),
          ),
        ],
      ),
    );
  }
}
