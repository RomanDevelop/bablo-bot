import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/trading_card.dart';
import '../../../../core/constants/signals_constants.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import 'di/signals_wm_builder.dart';
import 'signals_wm.dart';

class SignalsPage extends CoreMwwmWidget<SignalsWidgetModel> {
  SignalsPage({super.key})
      : super(widgetModelBuilder: createSignalsWidgetModel);

  static Route<void> route() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.signals),
        builder: (_) => SignalsPage(),
      );

  @override
  State<SignalsPage> createState() => _SignalsPageState();
}

class _SignalsPageState
    extends MwwmWidgetState<SignalsPage, SignalsWidgetModel> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;

    return StreamBuilder<SignalsState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const SignalsState();
        final signals = wm.filteredSignals(state);

        if (state.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final msg = wm.stateStream.value.message;
            if (msg == null) return;
            if (msg.startsWith('premium_gate:')) {
              wm.clearMessage();
              _showPremiumGate(context);
              return;
            }
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
            title: const Text('Signals'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            children: [
              Text(
                SignalsConstants.title,
                style: TextStyle(
                  color: p.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                SignalsConstants.subtitle,
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
                SignalsConstants.intro,
                style: TextStyle(
                  color: p.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: SignalsConstants.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = SignalsConstants.categories[index];
                    final selected = cat.id == state.category;
                    return _CategoryChip(
                      label: cat.label,
                      selected: selected,
                      onTap: () => wm.selectCategory(cat.id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              const SectionLabel('Лента сигналов'),
              const SizedBox(height: 12),
              if (signals.isEmpty)
                TradingCard(
                  child: Text(
                    'Пока нет сигналов в этой категории',
                    style: TextStyle(color: p.textSecondary, fontSize: 13.5),
                  ),
                )
              else
                for (final signal in signals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SignalCard(signal: signal),
                  ),
              const SizedBox(height: 18),
              const SectionLabel(SignalsConstants.robotsTitle),
              const SizedBox(height: 8),
              Text(
                SignalsConstants.robotsSubtitle,
                style: TextStyle(
                  color: p.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              for (final robot in SignalsConstants.robots)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RobotCard(
                    robot: robot,
                    isPremium: state.isPremium,
                    onConnect: () => wm.requestConnect(robot),
                  ),
                ),
              const SizedBox(height: 8),
              TradingCard(
                borderColor: p.primary.withValues(alpha: 0.45),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: p.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PREMIUM ACCESS',
                          style: TextStyle(
                            color: p.primaryHover,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      SignalsConstants.premiumGateBody,
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Material(
                      color: p.primary,
                      borderRadius:
                          BorderRadius.circular(AppTheme.controlRadius),
                      child: InkWell(
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.subscriptions),
                        borderRadius:
                            BorderRadius.circular(AppTheme.controlRadius),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: Text(
                              SignalsConstants.upgradeCta,
                              style: TextStyle(
                                color: p.onPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPremiumGate(BuildContext context) async {
    final p = context.read<ThemeController>().palette;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: p.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          ),
          title: Row(
            children: [
              Icon(Icons.workspace_premium_rounded, color: p.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  SignalsConstants.premiumGateTitle,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            SignalsConstants.premiumGateBody,
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Закрыть',
                style: TextStyle(
                  color: p.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushNamed(AppRoutes.subscriptions);
              },
              style: FilledButton.styleFrom(
                backgroundColor: p.primary,
                foregroundColor: p.onPrimary,
              ),
              child: const Text(SignalsConstants.upgradeCta),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Material(
      color: selected ? p.primary : p.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? p.primary : p.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? p.onPrimary : p.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({required this.signal});

  final TradeSignalItem signal;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final side = signal.side.toUpperCase();
    final sideColor = switch (side) {
      'BUY' => p.buy,
      'SELL' => p.sell,
      _ => p.hold,
    };

    return TradingCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: sideColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sideColor.withValues(alpha: 0.45)),
                ),
                child: Text(
                  side,
                  style: TextStyle(
                    color: sideColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: p.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.primary.withValues(alpha: 0.35)),
                ),
                child: Text(
                  signal.marketLabel.toUpperCase(),
                  style: TextStyle(
                    color: p.primaryHover,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                signal.atLabel,
                style: TextStyle(color: p.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  signal.pair,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Text(
                signal.price,
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${signal.timeframe} · ${signal.reason}',
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _RobotCard extends StatelessWidget {
  const _RobotCard({
    required this.robot,
    required this.isPremium,
    required this.onConnect,
  });

  final SignalRobot robot;
  final bool isPremium;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;

    return TradingCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      borderColor: isPremium ? null : p.primary.withValues(alpha: 0.28),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.primaryDim,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.primary.withValues(alpha: 0.4)),
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              color: p.primaryHover,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  robot.title,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  robot.subtitle,
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: p.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Premium',
                style: TextStyle(
                  color: p.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          const SizedBox(width: 6),
            IconButton(
            tooltip: isPremium
                ? SignalsConstants.connectCta
                : SignalsConstants.upgradeCta,
            onPressed: onConnect,
            icon: Icon(
              isPremium
                  ? Icons.link_rounded
                  : Icons.lock_outline_rounded,
              color: p.primary,
            ),
          ),
        ],
      ),
    );
  }
}
