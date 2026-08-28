import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/bablo_brand_mark.dart';
import '../../../../components/dashboard_widgets.dart';
import '../../../../components/feedback.dart';
import '../../../../components/navigation/side_menu_button.dart';
import '../../../../components/stats_action_button.dart';
import '../../../../components/status_chip.dart';
import '../../../../components/trading_card.dart';
import '../../../../core/auth/auth_session.dart';
import '../../../../core/constants/exchange_constants.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/utils/money_format.dart';
import '../../models/bot_status_model.dart';
import '../daily/widgets/daily_carousel.dart';
import 'dashboard_wm.dart';
import 'di/dashboard_wm_builder.dart';

class DashboardPage extends CoreMwwmWidget<DashboardWidgetModel> {
  DashboardPage({super.key, this.onOpenMenu})
      : super(widgetModelBuilder: createDashboardWidgetModel);

  final VoidCallback? onOpenMenu;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState
    extends MwwmWidgetState<DashboardPage, DashboardWidgetModel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DashboardState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const DashboardState();
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const BabloBrandMark(),
                  const Spacer(),
                  StatsActionButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.stats);
                    },
                  ),
                  if (state.health != null) ...[
                    const SizedBox(width: 10),
                    StatusChip(
                      label: state.health!.isOk ? 'Online' : 'Offline',
                      color: state.health!.isOk
                          ? AppColors.online
                          : AppColors.offline,
                    ),
                  ],
                  const SizedBox(width: 8),
                  SideMenuButton(onPressed: widget.onOpenMenu ?? () {}),
                ],
              ),
            ),
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () => wm.refresh(forceRefresh: true),
            child: _buildBody(state),
          ),
        );
      },
    );
  }

  Widget _buildBody(DashboardState state) {
    if (state.isLoading && state.status == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          PageLoading(),
          SizedBox(height: 32),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 120),
            child: DailyCarousel(),
          ),
        ],
      );
    }

    final status = state.status;
    if (status == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          if (state.error != null)
            ErrorBanner(message: state.error!, onRetry: () => wm.refresh()),
          const SizedBox(height: 16),
          const DailyCarousel(),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        if (state.error != null) ...[
          ErrorBanner(message: state.error!, onRetry: () => wm.refresh()),
          const SizedBox(height: 12),
        ],
        const _UserBootstrapStrip(),
        const SizedBox(height: 12),
        _CollapsibleTradingBlock(
          status: status,
          showUpdating: state.showUpdating,
        ),
        if (status.isHalted && status.haltReason.isNotEmpty) ...[
          const SizedBox(height: 12),
          ErrorBanner(message: 'Risk halt: ${status.haltReason}'),
        ],
        const SizedBox(height: 20),
        const DailyCarousel(),
      ],
    );
  }
}

/// Balance + position + scanner + meta. Collapsed by default unless a
/// position is open; tap the chevron (or compact row) to expand.
class _CollapsibleTradingBlock extends StatefulWidget {
  const _CollapsibleTradingBlock({
    required this.status,
    required this.showUpdating,
  });

  final BotStatus status;
  final bool showUpdating;

  @override
  State<_CollapsibleTradingBlock> createState() =>
      _CollapsibleTradingBlockState();
}

class _CollapsibleTradingBlockState extends State<_CollapsibleTradingBlock> {
  /// `null` → follow default (open if position open).
  bool? _userExpanded;

  bool get _hasOpenPosition => widget.status.position.isOpen;

  bool get _expanded => _userExpanded ?? _hasOpenPosition;

  @override
  void didUpdateWidget(covariant _CollapsibleTradingBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasOpen = oldWidget.status.position.isOpen;
    final isOpen = widget.status.position.isOpen;
    if (isOpen && !wasOpen) {
      // New position → force expanded (clear manual collapse).
      _userExpanded = null;
    } else if (!isOpen && wasOpen && _userExpanded == true) {
      // Position closed while user had forced open → return to default.
      _userExpanded = null;
    }
  }

  void _toggle() {
    setState(() => _userExpanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    if (!_expanded) {
      return _CollapsedBalanceRow(
        equity: status.equity,
        dailyPnlPct: status.dailyPnlPct,
        onTap: _toggle,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EquityHeader(
          equity: status.equity,
          dailyPnlPct: status.dailyPnlPct,
          symbol: status.symbol,
          interval: status.interval,
          isRunning: status.isRunning,
          isHalted: status.isHalted,
          scanMode: status.scanMode,
          strategyLabel: status.mode,
          onCollapse: _toggle,
        ),
        const SizedBox(height: 12),
        MiniPositionCard(status: status),
        const SizedBox(height: 12),
        SignalCard(status: status),
        const SizedBox(height: 16),
        _MetaRow(status: status, showUpdating: widget.showUpdating),
      ],
    );
  }
}

class _CollapsedBalanceRow extends StatelessWidget {
  const _CollapsedBalanceRow({
    required this.equity,
    required this.dailyPnlPct,
    required this.onTap,
  });

  final String equity;
  final String dailyPnlPct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pnlPositive = MoneyFormat.isPositive(dailyPnlPct);
    final pnlNegative = MoneyFormat.isNegative(dailyPnlPct);
    final pnlColor = pnlPositive
        ? AppColors.buy
        : pnlNegative
            ? AppColors.sell
            : AppColors.textSecondary;

    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL BALANCE',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      MoneyFormat.usd(equity, decimals: 2),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    MoneyFormat.pct(dailyPnlPct),
                    style: TextStyle(
                      color: pnlColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'день',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserBootstrapStrip extends StatelessWidget {
  const _UserBootstrapStrip();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthSession>();
    final p = context.watch<ThemeController>().palette;

    if (auth.isLoading) {
      return TradingCard(
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: p.primary),
            ),
            const SizedBox(width: 12),
            Text(
              'Connecting Bablo account…',
              style: TextStyle(color: p.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (!auth.isAuthenticated || auth.bootstrap == null) {
      return TradingCard(
        onTap: () => context.push(AppRoutes.profile),
        child: Row(
          children: [
            Icon(Icons.person_outline_rounded, color: p.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Sign in via Telegram to see your RSV rewards',
                style: TextStyle(color: p.textSecondary, fontSize: 13),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.textMuted),
          ],
        ),
      );
    }

    final b = auth.bootstrap!;
    final rsv = b.rewards.paidRsv;
    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.35),
      onTap: () => context.push(AppRoutes.profile),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.user.displayName.toUpperCase(),
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${rsv.toStringAsFixed(2)} RSV · ${b.subscription.plan}',
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Level ${b.stats.level} · ${b.referral.invitedCount} referrals',
                  style: TextStyle(color: p.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '≈ \$${(rsv * ExchangeConstants.rsvUsd).toStringAsFixed(2)}',
                style: TextStyle(
                  color: p.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Profile',
                style: TextStyle(color: p.primary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.status, required this.showUpdating});

  final BotStatus status;
  final bool showUpdating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            showUpdating
                ? 'обновляется… · ${MoneyFormat.dateTime(status.updatedAt)}'
                : 'Обновлено ${MoneyFormat.dateTime(status.updatedAt)}',
            style: TextStyle(
              color: showUpdating ? AppColors.primary : AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ),
        Text(
          'Candles ${status.candlesLoaded}',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}
