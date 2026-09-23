import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../components/feedback.dart';
import '../../../../../components/trading_card.dart';
import '../../../../../core/auth/auth_session.dart';
import '../../../../../core/constants/sportsbook_constants.dart';
import '../../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../../core/navigation/app_routes.dart';
import '../../../../../core/navigation/navigate_back.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../components/sportsbook_gate_card.dart';
import '../components/sportsbook_history_list.dart';
import 'di/sportsbook_history_wm_builder.dart';
import 'sportsbook_history_wm.dart';

class SportsbookHistoryPage
    extends CoreMwwmWidget<SportsbookHistoryWidgetModel> {
  SportsbookHistoryPage({super.key})
      : super(widgetModelBuilder: createSportsbookHistoryWidgetModel);

  static Route<void> route() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.sportsbookBets),
        builder: (_) => SportsbookHistoryPage(),
      );

  @override
  State<SportsbookHistoryPage> createState() => _SportsbookHistoryPageState();
}

class _SportsbookHistoryPageState
    extends MwwmWidgetState<SportsbookHistoryPage, SportsbookHistoryWidgetModel> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final auth = context.watch<AuthSession>();

    return StreamBuilder<SportsbookHistoryState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const SportsbookHistoryState();

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
            title: const Text(SportsbookConstants.historyTitle),
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: _body(state),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _body(SportsbookHistoryState state) {
    if (state.isLoading && state.bets.isEmpty) {
      return const [
        SizedBox(height: 80),
        PageLoading(),
      ];
    }

    if (state.error != null) {
      return [
        ErrorBanner(message: state.error!, onRetry: () => wm.load()),
      ];
    }

    if (state.needsAuth) {
      return [
        TradingCard(
          onTap: wm.openProfile,
          child: const Text(SportsbookConstants.needAuth),
        ),
      ];
    }

    if (state.planRequired) {
      return [SportsbookGateCard(onOpenPremium: wm.openSubscriptions)];
    }

    return [
      SportsbookHistoryList(items: state.bets),
    ];
  }
}
