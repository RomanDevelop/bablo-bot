import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../components/feedback.dart';
import '../../../../../components/trading_card.dart';
import '../../../../../core/auth/auth_session.dart';
import '../../../../../core/constants/casino_constants.dart';
import '../../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../../core/navigation/app_routes.dart';
import '../../../../../core/navigation/navigate_back.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../components/casino_board_view.dart';
import '../components/casino_home_components.dart';
import 'casino_game_wm.dart';
import 'di/casino_game_wm_builder.dart';

class CasinoGamePage extends CoreMwwmWidget<CasinoGameWidgetModel> {
  CasinoGamePage({
    super.key,
    required this.gameId,
  }) : super(
          widgetModelBuilder: (context) =>
              createCasinoGameWidgetModel(context, gameId: gameId),
        );

  final String gameId;

  static Route<void> route(String gameId) => MaterialPageRoute<void>(
        settings: RouteSettings(name: AppRoutes.casinoGame(gameId)),
        builder: (_) => CasinoGamePage(gameId: gameId),
      );

  @override
  State<CasinoGamePage> createState() => _CasinoGamePageState();
}

class _CasinoGamePageState
    extends MwwmWidgetState<CasinoGamePage, CasinoGameWidgetModel> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final auth = context.watch<AuthSession>();

    return StreamBuilder<CasinoGameState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const CasinoGameState();

        if (state.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final msg = wm.stateStream.value.message;
            if (msg == null) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                behavior: SnackBarBehavior.floating,
                action: state.canRetry
                    ? SnackBarAction(
                        label: CasinoConstants.retryCta,
                        onPressed: wm.retrySameRequest,
                      )
                    : null,
              ),
            );
            wm.clearMessage();
          });
        }

        final title = state.game?.title ?? widget.gameId;

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
            title: Text(title),
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
          body: state.isLoading && state.game == null
              ? const PageLoading()
              : state.needsAuth
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        TradingCard(
                          onTap: wm.openProfile,
                          child: const Text(CasinoConstants.needAuth),
                        ),
                      ],
                    )
                  : state.planRequired
                      ? ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            CasinoGateCard(onOpenPremium: wm.openSubscriptions),
                          ],
                        )
                      : state.error != null && state.game == null
                          ? ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                ErrorBanner(
                                  message: state.error!,
                                  onRetry: wm.load,
                                ),
                              ],
                            )
                          : _gameBody(context, state, p),
        );
      },
    );
  }

  Widget _gameBody(
    BuildContext context,
    CasinoGameState state,
    dynamic p,
  ) {
    final game = state.game!;
    final isDemo =
        state.currency.toUpperCase() == CasinoConstants.currencyDemo;
    final balanceValue = state.balance?.availableFor(state.currency) ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      children: [
        if (state.balance != null)
          CasinoBalanceStrip(
            balance: state.balance!,
            currency: state.currency,
            onCurrencyChanged: wm.setCurrency,
            onResetDemo: () {},
            isMutating: state.busy,
            showResetDemo: false,
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            ChoiceChip(
              label: const Text(CasinoConstants.currencyDemo),
              selected: isDemo,
              onSelected: state.busy || state.betLocked
                  ? null
                  : (_) => wm.setCurrency(CasinoConstants.currencyDemo),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text(CasinoConstants.currencyRsv),
              selected: !isDemo,
              onSelected: state.busy || state.betLocked
                  ? null
                  : (_) => wm.setCurrency(CasinoConstants.currencyRsv),
            ),
            const Spacer(),
            FilterChip(
              label: const Text(CasinoConstants.turboLabel),
              selected: state.turbo,
              onSelected: wm.setTurbo,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Balance ${CasinoConstants.amount(balanceValue)} · '
          '×${CasinoConstants.amount(state.multiplier)}',
          style: TextStyle(color: p.textMuted, fontSize: 12),
        ),
        if (state.statusLine != null) ...[
          const SizedBox(height: 6),
          Text(
            state.statusLine!,
            style: TextStyle(
              color: p.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (state.session?.bonusState != null)
          CasinoBonusOverlay(bonus: state.session!.bonusState!),
        if (state.session?.bonusState != null) const SizedBox(height: 10),
        CasinoBoardView(
          game: game,
          board: state.board,
          highlightPositions: state.highlightPositions,
          removedPositions: state.removedPositions,
          bonus: state.session?.bonusState,
        ),
        if (game.isHoldAndWin) ...[
          const SizedBox(height: 8),
          Text(
            CasinoConstants.symbolNotWallet,
            style: TextStyle(color: p.textMuted, fontSize: 11, height: 1.3),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          CasinoConstants.betLabel,
          style: TextStyle(
            color: p.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        CasinoBetSelector(
          steps: game.steps,
          bet: state.bet,
          enabled: !state.busy && !state.betLocked,
          onChanged: wm.setBet,
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 16),
          TradingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Debug forced_scenario',
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final s in const [
                      null,
                      'LOSS',
                      'GUARANTEED_WIN',
                      'ONE_CASCADE',
                      'MULTI_CASCADE',
                      'BONUS_TRIGGER',
                      'BONUS_COMPLETE',
                    ])
                      ChoiceChip(
                        label: Text(s ?? 'off'),
                        selected: state.forcedScenario == s,
                        onSelected: (_) => wm.setForcedScenario(s),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: state.busy
                ? null
                : state.canRetry
                    ? wm.retrySameRequest
                    : wm.spinOrRespin,
            style: FilledButton.styleFrom(
              backgroundColor: p.primary,
              foregroundColor: p.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.controlRadius),
              ),
            ),
            child: state.busy
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: p.onPrimary,
                    ),
                  )
                : Text(
                    state.canRetry
                        ? CasinoConstants.retryCta
                        : state.requiresRespin
                            ? CasinoConstants.respinCta
                            : CasinoConstants.spinCta,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        if (state.lastWin > 0) ...[
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Last win ${CasinoConstants.amount(state.lastWin)}',
              style: TextStyle(
                color: p.success,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
