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
import '../components/sportsbook_event_card.dart';
import '../components/sportsbook_gate_card.dart';
import 'di/sportsbook_events_wm_builder.dart';
import 'sportsbook_events_wm.dart';

class SportsbookEventsPage extends CoreMwwmWidget<SportsbookEventsWidgetModel> {
  SportsbookEventsPage({super.key})
      : super(widgetModelBuilder: createSportsbookEventsWidgetModel);

  static Route<void> route() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.sportsbookEvents),
        builder: (_) => SportsbookEventsPage(),
      );

  @override
  State<SportsbookEventsPage> createState() => _SportsbookEventsPageState();
}

class _SportsbookEventsPageState
    extends MwwmWidgetState<SportsbookEventsPage, SportsbookEventsWidgetModel> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final auth = context.watch<AuthSession>();

    return StreamBuilder<SportsbookEventsState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const SportsbookEventsState();

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
            title: const Text(SportsbookConstants.eventsTitle),
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
            onRefresh: wm.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              children: [
                Text(
                  SportsbookConstants.competition,
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  SportsbookConstants.eventsTitle,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
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

  List<Widget> _body(SportsbookEventsState state) {
    if (state.isLoading && state.events.isEmpty) {
      return const [
        SizedBox(height: 80),
        PageLoading(),
      ];
    }

    if (state.error != null) {
      return [
        ErrorBanner(message: state.error!, onRetry: wm.load),
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

    if (state.events.isEmpty) {
      return [
        EmptyState(
          title: SportsbookConstants.eventsEmpty,
          icon: Icons.sports_basketball_outlined,
        ),
      ];
    }

    return [
      for (final event in state.events) ...[
        SportsbookEventCard(
          event: event,
          onOpen: () => wm.openEvent(event),
        ),
        const SizedBox(height: 10),
      ],
    ];
  }
}
