import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/feedback.dart';
import '../../../../components/trading_card.dart';
import '../../../../core/auth/auth_session.dart';
import '../../../../core/constants/casino_constants.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/theme_controller.dart';
import 'casino_wm.dart';
import 'components/casino_home_components.dart';
import 'di/casino_wm_builder.dart';

class CasinoPage extends CoreMwwmWidget<CasinoWidgetModel> {
  CasinoPage({super.key}) : super(widgetModelBuilder: createCasinoWidgetModel);

  static Route<void> route() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.casino),
        builder: (_) => CasinoPage(),
      );

  @override
  State<CasinoPage> createState() => _CasinoPageState();
}

class _CasinoPageState extends MwwmWidgetState<CasinoPage, CasinoWidgetModel> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final auth = context.watch<AuthSession>();

    return StreamBuilder<CasinoHomeState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const CasinoHomeState();

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
            title: const Text(CasinoConstants.subtitle),
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
                  CasinoConstants.title,
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  CasinoConstants.subtitle,
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
                  CasinoConstants.intro,
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

  List<Widget> _body(CasinoHomeState state) {
    if (state.isLoading && state.status == null && state.balance == null) {
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
      return [CasinoGateCard(onOpenPremium: wm.openSubscriptions)];
    }

    final balance = state.balance;
    return [
      if (balance != null) ...[
        CasinoBalanceStrip(
          balance: balance,
          currency: state.currency,
          onCurrencyChanged: wm.setCurrency,
          onResetDemo: wm.resetDemo,
          isMutating: state.isMutating,
        ),
        const SizedBox(height: 16),
      ],
      if (state.stats != null) ...[
        TradingCard(
          child: Row(
            children: [
              MetricTile(
                  label: 'Spins',
                  value: CasinoConstants.amount(state.stats!.totalSpins),
                ),
                MetricTile(
                  label: 'Wagered',
                  value: CasinoConstants.amount(state.stats!.totalWagered),
                ),
                MetricTile(
                  label: 'Won',
                  value: CasinoConstants.amount(state.stats!.totalWon),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
      const SectionLabel(CasinoConstants.gamesTitle),
      const SizedBox(height: 10),
      if (state.games.isEmpty)
        TradingCard(
          child: Text(
            'Игры пока не загрузились',
            style: TextStyle(
              color: context.watch<ThemeController>().palette.textSecondary,
            ),
          ),
        )
      else
        ...state.games.map(
          (game) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CasinoGameCard(
              game: game,
              onOpen: () => wm.openGame(game),
            ),
          ),
        ),
      const SizedBox(height: 12),
      CasinoHistoryList(items: state.history),
    ];
  }

  List<Widget> _gateOrAuth(CasinoHomeState state) {
    if (state.needsAuth) {
      return [
        TradingCard(
          onTap: wm.openProfile,
          child: const Text(CasinoConstants.needAuth),
        ),
      ];
    }
    return [CasinoGateCard(onOpenPremium: wm.openSubscriptions)];
  }
}
