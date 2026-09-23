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
import '../../../models/sportsbook_model.dart';
import '../components/sportsbook_balance_strip.dart';
import '../components/sportsbook_event_card.dart';
import '../components/sportsbook_gate_card.dart';
import '../components/sportsbook_slip.dart';
import 'di/sportsbook_event_wm_builder.dart';
import 'sportsbook_event_wm.dart';

class SportsbookEventPage extends CoreMwwmWidget<SportsbookEventWidgetModel> {
  SportsbookEventPage({
    super.key,
    required this.eventId,
    this.preview,
  }) : super(
          widgetModelBuilder: (context) => createSportsbookEventWidgetModel(
            context,
            eventId: eventId,
            preview: preview,
          ),
        );

  final String eventId;
  final SportsbookEvent? preview;

  static Route<void> route(String eventId) => MaterialPageRoute<void>(
        settings: RouteSettings(name: AppRoutes.sportsbookEvent(eventId)),
        builder: (_) => SportsbookEventPage(eventId: eventId),
      );

  @override
  State<SportsbookEventPage> createState() => _SportsbookEventPageState();
}

class _SportsbookEventPageState
    extends MwwmWidgetState<SportsbookEventPage, SportsbookEventWidgetModel> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final auth = context.watch<AuthSession>();

    return StreamBuilder<SportsbookEventState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const SportsbookEventState();

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
            title: Text(state.event?.title ?? SportsbookConstants.eventsTitle),
            actions: [
              IconButton(
                tooltip: SportsbookConstants.historyCta,
                onPressed: wm.openHistory,
                icon: const Icon(Icons.receipt_long_outlined),
              ),
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
              children: _body(state),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _body(SportsbookEventState state) {
    if (state.isLoading && state.event == null) {
      return const [
        SizedBox(height: 80),
        PageLoading(),
      ];
    }

    if (state.error != null && state.event == null) {
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

    final event = state.event;
    final status = state.status;
    if (event == null) {
      return const [
        EmptyState(
          title: SportsbookConstants.errorNotFound,
          icon: Icons.sports_basketball_outlined,
        ),
      ];
    }

    return [
      if (state.error != null) ...[
        ErrorBanner(message: state.error!, onRetry: () => wm.load()),
        const SizedBox(height: 12),
      ],
      SportsbookEventCard(
        event: event,
        showPlaceCta: false,
        showOdds: state.acceptedBet == null,
      ),
      if (status != null) ...[
        const SizedBox(height: 12),
        SportsbookBalanceStrip(status: status),
      ],
      const SizedBox(height: 12),
      ..._afterMatch(state, event, status),
    ];
  }

  List<Widget> _afterMatch(
    SportsbookEventState state,
    SportsbookEvent event,
    SportsbookStatus? status,
  ) {
    final accepted = state.acceptedBet;
    if (accepted != null) {
      return [
        TradingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SportsbookConstants.acceptedBody(
                  odds: SportsbookConstants.odds(accepted.acceptedOdds),
                  payout: SportsbookConstants.plain(accepted.potentialPayout),
                ),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                SportsbookConstants.acceptedLocked,
                style: TextStyle(
                  color: context.watch<ThemeController>().palette.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: wm.openHistory,
                  child: const Text(SportsbookConstants.historyCta),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    if (!event.canPlaceBet) {
      return [
        TradingCard(
          child: Text(
            event.isLive
                ? SportsbookConstants.liveBadge
                : SportsbookConstants.errorEventClosed,
          ),
        ),
      ];
    }

    if (state.market == null ||
        state.market!.outcomes.isEmpty ||
        status == null) {
      return [
        TradingCard(
          child: Text(state.error ?? SportsbookConstants.errorProvider),
        ),
      ];
    }

    return [
      SportsbookSlip(
        status: status,
        market: state.market!,
        stakeRsv: state.stakeRsv,
        selectedOutcomeId: state.selectedOutcomeId,
        isMutating: state.isMutating,
        canSubmit: state.canSubmit,
        oddsChanged: state.oddsChanged,
        onSelectOutcome: wm.selectOutcome,
        onStakeChanged: wm.setStake,
        onStepStake: wm.stepStake,
        onConfirm: wm.confirm,
        onRefreshOdds: wm.refreshMarkets,
      ),
    ];
  }
}
