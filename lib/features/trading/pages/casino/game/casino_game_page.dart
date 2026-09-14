import 'dart:async';

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
import '../../../../../core/theme/app_palette.dart';
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
  StreamSubscription<CasinoGameState>? _sub;
  late CasinoGameState _state;

  @override
  void initState() {
    super.initState();
    _state = wm.stateStream.value;
    _sub = wm.stateStream.listen((next) {
      if (!mounted) return;
      setState(() => _state = next);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _onSpin() async {
    try {
      if (_state.canRetry) {
        await wm.retrySameRequest();
      } else {
        await wm.spinOrRespin();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Spin error: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final auth = context.watch<AuthSession>();
    final state = _state;

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
          if (state.balance != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  state.currency.toUpperCase() ==
                          CasinoConstants.currencyDemo
                      ? CasinoConstants.demo(
                          state.balance!.demo.available,
                        )
                      : CasinoConstants.rsv(
                          state.balance!.rsv.available,
                        ),
                  style: TextStyle(
                    color: p.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
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
  }

  Widget _gameBody(
    BuildContext context,
    CasinoGameState state,
    AppPalette p,
  ) {
    final game = state.game!;
    final isDemo =
        state.currency.toUpperCase() == CasinoConstants.currencyDemo;
    final balanceValue = state.balance?.availableFor(state.currency) ?? 0;
    final committed = state.balance?.rsv.committedCopy ?? 0;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              _CompactWalletBar(
                balanceLabel: isDemo
                    ? CasinoConstants.demo(balanceValue)
                    : CasinoConstants.rsv(balanceValue),
                committedCopy: committed,
                isDemo: isDemo,
                multiplier: state.multiplier,
                turbo: state.turbo,
                currencyLocked: state.busy || state.betLocked,
                onCurrencyDemo: () =>
                    wm.setCurrency(CasinoConstants.currencyDemo),
                onCurrencyRsv: () =>
                    wm.setCurrency(CasinoConstants.currencyRsv),
                onTurbo: wm.setTurbo,
              ),
              if (state.error != null) ...[
                const SizedBox(height: 10),
                ErrorBanner(
                  message: state.error!,
                  onRetry: state.canRetry ? wm.retrySameRequest : wm.load,
                ),
              ],
              if (state.lastWin > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Win ${CasinoConstants.amount(state.lastWin)}',
                  style: TextStyle(
                    color: p.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ] else if (state.statusLine != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.statusLine!,
                  style: TextStyle(
                    color: p.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (state.session?.bonusState != null) ...[
                CasinoBonusOverlay(bonus: state.session!.bonusState!),
                const SizedBox(height: 10),
              ],
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: state.busy ? null : _onSpin,
                child: CasinoBoardView(
                  game: game,
                  board: state.board,
                  highlightPositions: state.highlightPositions,
                  removedPositions: state.removedPositions,
                  bonus: state.session?.bonusState,
                  spinning: state.isPlayingEvents || state.isSpinning,
                ),
              ),
              if (game.isHoldAndWin) ...[
                const SizedBox(height: 8),
                Text(
                  CasinoConstants.symbolNotWallet,
                  style: TextStyle(
                    color: p.textMuted,
                    fontSize: 11,
                    height: 1.3,
                  ),
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
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: state.busy ? null : _onSpin,
                style: FilledButton.styleFrom(
                  backgroundColor: p.primary,
                  foregroundColor: p.onPrimary,
                  disabledBackgroundColor: p.primary.withValues(alpha: 0.45),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.controlRadius),
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
          ),
        ),
      ],
    );
  }
}

class _CompactWalletBar extends StatelessWidget {
  const _CompactWalletBar({
    required this.balanceLabel,
    required this.committedCopy,
    required this.isDemo,
    required this.multiplier,
    required this.turbo,
    required this.currencyLocked,
    required this.onCurrencyDemo,
    required this.onCurrencyRsv,
    required this.onTurbo,
  });

  final String balanceLabel;
  final num committedCopy;
  final bool isDemo;
  final num multiplier;
  final bool turbo;
  final bool currencyLocked;
  final VoidCallback onCurrencyDemo;
  final VoidCallback onCurrencyRsv;
  final ValueChanged<bool> onTurbo;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  balanceLabel,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '×${CasinoConstants.amount(multiplier)}',
                style: TextStyle(
                  color: p.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (!isDemo && committedCopy > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${CasinoConstants.inCopy}: ${CasinoConstants.rsv(committedCopy)}',
              style: TextStyle(color: p.textMuted, fontSize: 11),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              ChoiceChip(
                label: const Text(CasinoConstants.currencyDemo),
                selected: isDemo,
                visualDensity: VisualDensity.compact,
                onSelected:
                    currencyLocked ? null : (_) => onCurrencyDemo(),
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: const Text(CasinoConstants.currencyRsv),
                selected: !isDemo,
                visualDensity: VisualDensity.compact,
                onSelected:
                    currencyLocked ? null : (_) => onCurrencyRsv(),
              ),
              const Spacer(),
              FilterChip(
                label: const Text(CasinoConstants.turboLabel),
                selected: turbo,
                visualDensity: VisualDensity.compact,
                onSelected: onTurbo,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
