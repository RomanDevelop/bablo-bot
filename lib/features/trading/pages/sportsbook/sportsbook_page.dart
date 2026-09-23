import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/feedback.dart';
import '../../../../components/trading_card.dart';
import '../../../../core/auth/auth_session.dart';
import '../../../../core/constants/sportsbook_constants.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/theme_controller.dart';
import 'components/sportsbook_balance_strip.dart';
import 'components/sportsbook_gate_card.dart';
import 'di/sportsbook_wm_builder.dart';
import 'sportsbook_wm.dart';

class SportsbookPage extends CoreMwwmWidget<SportsbookWidgetModel> {
  SportsbookPage({super.key})
      : super(widgetModelBuilder: createSportsbookWidgetModel);

  static Route<void> route() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.sportsbook),
        builder: (_) => SportsbookPage(),
      );

  @override
  State<SportsbookPage> createState() => _SportsbookPageState();
}

class _SportsbookPageState
    extends MwwmWidgetState<SportsbookPage, SportsbookWidgetModel> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final auth = context.watch<AuthSession>();

    return StreamBuilder<SportsbookHubState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const SportsbookHubState();

        if (state.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final msg = wm.stateStream.value.message;
            if (msg == null) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                behavior: SnackBarBehavior.floating,
              ),
            );
            wm.clearMessage();
          });
        }

        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            backgroundColor: p.background,
            foregroundColor: p.textPrimary,
            leading: IconButton(
              tooltip: 'Назад',
              onPressed: () => navigateBackOrHome(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text(SportsbookConstants.subtitle),
            actions: [
              IconButton(
                tooltip: 'Profile',
                onPressed: wm.openProfile,
                icon: Icon(
                  auth.isAuthenticated
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            color: p.primary,
            backgroundColor: p.surface,
            onRefresh: () => wm.load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              children: [
                Text(
                  SportsbookConstants.title,
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  SportsbookConstants.subtitle,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  SportsbookConstants.intro,
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                ..._body(state),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _body(SportsbookHubState state) {
    if (state.isLoading && state.status == null) {
      return const [
        SizedBox(height: 80),
        PageLoading(),
      ];
    }

    if (state.error != null) {
      return [
        ErrorBanner(message: state.error!, onRetry: () => wm.load()),
        const SizedBox(height: 12),
        if (state.planRequired || state.needsAuth) ..._gateOrAuth(state),
      ];
    }

    if (state.needsAuth) return _gateOrAuth(state);

    if (state.planRequired) {
      return [SportsbookGateCard(onOpenPremium: wm.openSubscriptions)];
    }

    final status = state.status;
    if (status == null) {
      return [SportsbookGateCard(onOpenPremium: wm.openSubscriptions)];
    }

    return [
      if (state.isDisabled) ...[
        SportsbookGateCard(
          onOpenPremium: wm.openSubscriptions,
          disabled: true,
        ),
        const SizedBox(height: 16),
      ],
      SportsbookBalanceStrip(status: status),
      const SizedBox(height: 16),
      _ActionCard(
        title: SportsbookConstants.eventsCta,
        subtitle: '${status.competition} · ${status.sport}',
        icon: Icons.sports_basketball_outlined,
        enabled: !state.isDisabled,
        onTap: wm.openEvents,
      ),
      const SizedBox(height: 10),
      _ActionCard(
        title: SportsbookConstants.historyCta,
        subtitle: 'OPEN / WON / LOST / VOID',
        icon: Icons.receipt_long_outlined,
        onTap: wm.openHistory,
      ),
    ];
  }

  List<Widget> _gateOrAuth(SportsbookHubState state) {
    if (state.needsAuth) {
      return [
        TradingCard(
          onTap: wm.openProfile,
          child: const Text(SportsbookConstants.needAuth),
        ),
      ];
    }
    return [SportsbookGateCard(onOpenPremium: wm.openSubscriptions)];
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      onTap: enabled ? onTap : null,
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
            child: Icon(icon, color: p.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: p.textSecondary, fontSize: 13),
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
