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
            onRefresh: () => wm.refresh(forceRefresh: true),
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
        if (state.isRefreshing) ...[
          const LinearProgressIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.border,
          ),
          const SizedBox(height: 12),
        ],
        _SyncHeader(portfolio: p),
        const SizedBox(height: 12),
        _BotPositionSection(portfolio: p),
        const SizedBox(height: 12),
        _FuturesWalletSection(portfolio: p),
        if (p.whatCountsAsPosition != null) ...[
          const SizedBox(height: 18),
          Text(
            p.whatCountsAsPosition!,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _SyncHeader extends StatelessWidget {
  const _SyncHeader({required this.portfolio});
  final Portfolio portfolio;

  @override
  Widget build(BuildContext context) {
    final color = switch (portfolio.syncStatus) {
      'ok' => AppColors.buy,
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
          if (portfolio.leverage != null) ...[
            const SizedBox(height: 8),
            Text(
              'Leverage ${portfolio.leverageLabel}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
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
    final sideLabel = portfolio.botSideLabel;
    final sideColor = switch (sideLabel) {
      'LONG' => AppColors.buy,
      'SHORT' => AppColors.sell,
      _ => AppColors.textSecondary,
    };
    final pnlColor = MoneyFormat.isPositive(portfolio.botUnrealizedPnl)
        ? AppColors.buy
        : MoneyFormat.isNegative(portfolio.botUnrealizedPnl)
            ? AppColors.sell
            : AppColors.textSecondary;

    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SectionLabel('Bot position'),
              const Spacer(),
              StatusChip(label: sideLabel, color: sideColor),
            ],
          ),
          const SizedBox(height: 12),
          if (portfolio.botOpen) ...[
            Text(
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
          ] else
            Text(
              portfolio.market ?? 'USDT-M Futures · flat',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}

class _FuturesWalletSection extends StatelessWidget {
  const _FuturesWalletSection({required this.portfolio});
  final Portfolio portfolio;

  @override
  Widget build(BuildContext context) {
    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(portfolio.market ?? 'Futures wallet'),
          const SizedBox(height: 8),
          KeyValueRow(
            label: 'Equity',
            value: MoneyFormat.usd(portfolio.equity),
          ),
          KeyValueRow(
            label: '${portfolio.quoteAsset} available',
            value: MoneyFormat.trim(portfolio.quoteBalance, maxDecimals: 2),
          ),
          KeyValueRow(
            label: 'Mark price',
            value: MoneyFormat.trim(portfolio.price, maxDecimals: 2),
          ),
        ],
      ),
    );
  }
}
