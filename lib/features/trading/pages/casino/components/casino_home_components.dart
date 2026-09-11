import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../components/trading_card.dart';
import '../../../../../core/auth/auth_session.dart';
import '../../../../../core/constants/casino_constants.dart';
import '../../../../../core/navigation/app_routes.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../models/casino_model.dart';

class CasinoBalanceStrip extends StatelessWidget {
  const CasinoBalanceStrip({
    super.key,
    required this.balance,
    required this.currency,
    required this.onCurrencyChanged,
    required this.onResetDemo,
    this.isMutating = false,
    this.showResetDemo = true,
  });

  final CasinoBalance balance;
  final String currency;
  final ValueChanged<String> onCurrencyChanged;
  final VoidCallback onResetDemo;
  final bool isMutating;
  final bool showResetDemo;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final isDemo = currency.toUpperCase() == CasinoConstants.currencyDemo;

    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MetricTile(
                  label: CasinoConstants.availableRsv,
                  value: CasinoConstants.amount(balance.rsv.available),
                ),
              MetricTile(
                  label: CasinoConstants.inCopy,
                  value: CasinoConstants.amount(balance.rsv.committedCopy),
                ),
              MetricTile(
                  label: CasinoConstants.demoCredits,
                  value: CasinoConstants.amount(balance.demo.available),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CasinoConstants.balanceStripHint,
            style: TextStyle(color: p.textMuted, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ChoiceChip(
                label: const Text(CasinoConstants.currencyDemo),
                selected: isDemo,
                onSelected: (_) =>
                    onCurrencyChanged(CasinoConstants.currencyDemo),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text(CasinoConstants.currencyRsv),
                selected: !isDemo,
                onSelected: (_) =>
                    onCurrencyChanged(CasinoConstants.currencyRsv),
              ),
              const Spacer(),
              if (showResetDemo)
                TextButton(
                  onPressed: isMutating ? null : onResetDemo,
                  child: const Text(CasinoConstants.resetDemo),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class CasinoGateCard extends StatelessWidget {
  const CasinoGateCard({super.key, required this.onOpenPremium});

  final VoidCallback onOpenPremium;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CasinoConstants.premiumTitle,
            style: TextStyle(
              color: p.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CasinoConstants.premiumBody,
            style: TextStyle(color: p.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onOpenPremium,
              style: FilledButton.styleFrom(
                backgroundColor: p.primary,
                foregroundColor: p.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                ),
              ),
              child: const Text(
                CasinoConstants.premiumCta,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CasinoGameCard extends StatelessWidget {
  const CasinoGameCard({
    super.key,
    required this.game,
    required this.onOpen,
  });

  final CasinoGame game;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      onTap: onOpen,
      borderColor: p.primary.withValues(alpha: 0.25),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: p.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_iconFor(game), color: p.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.title,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  game.description.isEmpty
                      ? game.gameType
                      : game.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bet ${CasinoConstants.amount(game.minBet)}–${CasinoConstants.amount(game.maxBet)}',
                  style: TextStyle(color: p.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: p.textMuted),
        ],
      ),
    );
  }

  IconData _iconFor(CasinoGame game) {
    if (game.isTumble) return Icons.waterfall_chart_rounded;
    if (game.isHoldAndWin) return Icons.monetization_on_outlined;
    return Icons.casino_outlined;
  }
}

class CasinoHistoryList extends StatelessWidget {
  const CasinoHistoryList({super.key, required this.items});

  final List<CasinoHistoryItem> items;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    if (items.isEmpty) {
      return TradingCard(
        child: Text(
          CasinoConstants.historyEmpty,
          style: TextStyle(color: p.textSecondary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(CasinoConstants.historyTitle),
        const SizedBox(height: 10),
        ...items.take(20).map((item) {
          final win = item.totalWin ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TradingCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.gameId ?? 'spin',
                          style: TextStyle(
                            color: p.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.currency ?? ''} · bet ${CasinoConstants.amount(item.bet ?? 0)}',
                          style: TextStyle(color: p.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CasinoConstants.netResult(win),
                    style: TextStyle(
                      color: win > 0 ? p.success : p.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class CasinoTeaserCard extends StatelessWidget {
  const CasinoTeaserCard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthSession>();
    if (!auth.isAuthenticated) return const SizedBox.shrink();

    final p = context.watch<ThemeController>().palette;
    final gated = !auth.canUseCasino;

    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.3),
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.casino),
      child: Row(
        children: [
          Icon(Icons.sports_esports_outlined, color: p.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CasinoConstants.title,
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gated
                      ? CasinoConstants.premiumTitle
                      : CasinoConstants.subtitle,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  gated
                      ? CasinoConstants.premiumBody
                      : 'Demo + RSV слоты Bablo',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: p.textMuted),
        ],
      ),
    );
  }
}
