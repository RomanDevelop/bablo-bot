import 'package:flutter/material.dart';

import '../../../../components/bablo_brand_mark.dart';
import '../../../../components/dashboard_widgets.dart';
import '../../../../components/feedback.dart';
import '../../../../components/stats_action_button.dart';
import '../../../../components/status_chip.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money_format.dart';
import '../../models/bot_status_model.dart';
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
                      label: state.health!.networkLabel,
                      color: state.health!.testnet
                          ? AppColors.testnet
                          : AppColors.mainnet,
                    ),
                    const SizedBox(width: 6),
                    StatusChip(
                      label: state.health!.isOk ? 'Online' : 'Offline',
                      color: state.health!.isOk
                          ? AppColors.online
                          : AppColors.offline,
                    ),
                  ],
                  IconButton(
                    tooltip: 'Меню',
                    onPressed: widget.onOpenMenu,
                    icon: const Icon(Icons.menu_rounded),
                  ),
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
        EquityHeader(
          equity: status.equity,
          dailyPnlPct: status.dailyPnlPct,
          symbol: status.symbol,
          interval: status.interval,
          isRunning: status.isRunning,
          isHalted: status.isHalted,
          scanMode: status.scanMode,
          strategyLabel: status.mode,
        ),
        const SizedBox(height: 12),
        MiniPositionCard(status: status),
        const SizedBox(height: 12),
        SignalCard(status: status),
        if (status.isHalted && status.haltReason.isNotEmpty) ...[
          const SizedBox(height: 12),
          ErrorBanner(message: 'Risk halt: ${status.haltReason}'),
        ],
        const SizedBox(height: 16),
        _MetaRow(status: status, showUpdating: state.showUpdating),
      ],
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
