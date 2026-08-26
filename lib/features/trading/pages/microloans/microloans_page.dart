import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/trading_card.dart';
import '../../../../core/auth/auth_session.dart';
import '../../../../core/constants/exchange_constants.dart';
import '../../../../core/constants/microloans_constants.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import 'di/microloans_wm_builder.dart';
import 'microloans_wm.dart';

class MicroloansPage extends CoreMwwmWidget<MicroloansWidgetModel> {
  MicroloansPage({super.key})
      : super(widgetModelBuilder: createMicroloansWidgetModel);

  static Route<void> route() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.microloans),
        builder: (_) => MicroloansPage(),
      );

  @override
  State<MicroloansPage> createState() => _MicroloansPageState();
}

class _MicroloansPageState
    extends MwwmWidgetState<MicroloansPage, MicroloansWidgetModel> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final auth = context.watch<AuthSession>();

    return StreamBuilder<MicroloansState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const MicroloansState();
        final tier = state.selectedTier;

        if (state.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final msg = wm.stateStream.value.message;
            if (msg == null) return;
            final needsAuth = wm.stateStream.value.needsAuth;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                behavior: SnackBarBehavior.floating,
                action: needsAuth
                    ? SnackBarAction(
                        label: 'Profile',
                        onPressed: () => context.push(AppRoutes.profile),
                      )
                    : null,
              ),
            );
            wm.clearMessage();
            if (needsAuth) {
              context.push(AppRoutes.profile);
            }
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
            title: const Text('Microloans'),
            actions: [
              IconButton(
                tooltip: 'Profile',
                onPressed: () => context.push(AppRoutes.profile),
                icon: Icon(
                  auth.isAuthenticated
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            children: [
              Text(
                MicroloansConstants.title,
                style: TextStyle(
                  color: p.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                MicroloansConstants.subtitle,
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
                MicroloansConstants.intro,
                style: TextStyle(
                  color: p.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              if (auth.activeLoanTier != null) ...[
                const SizedBox(height: 16),
                _ActiveLoanBanner(tier: auth.activeLoanTier!),
              ],
              const SizedBox(height: 20),
              Text(
                'CHOOSE TIER',
                style: TextStyle(
                  color: p.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              for (final t in MicroloansConstants.tiers) ...[
                _TierCard(
                  tier: t,
                  selected: t.id == tier.id,
                  onTap: () => wm.selectTier(t.id),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              _CalcCard(tier: tier),
              const SizedBox(height: 12),
              TradingCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MicroloansConstants.howItWorksTitle,
                      style: TextStyle(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0;
                        i < MicroloansConstants.howItWorks.length;
                        i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}.',
                            style: TextStyle(
                              color: p.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              MicroloansConstants.howItWorks[i],
                              style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TradingCard(
                borderColor: p.primary.withValues(alpha: 0.35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MicroloansConstants.obligationsTitle,
                      style: TextStyle(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Bullet(
                      text:
                          '${tier.sharePercent}% share of attributed referrals / paid activity you bring.',
                    ),
                    _Bullet(text: tier.quotaLabel),
                    _Bullet(
                      text:
                          'Total over term: ${tier.totalUsersObligation} invites '
                          '(Telegram Community + Bablo Community).',
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () =>
                          wm.setTermsAccepted(!state.termsAccepted),
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          Icon(
                            state.termsAccepted
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            color: state.termsAccepted
                                ? p.primary
                                : p.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'I accept the quasi-credit terms for ${tier.name}.',
                              style: TextStyle(
                                color: p.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: wm.apply,
                        style: FilledButton.styleFrom(
                          backgroundColor: p.primary,
                          foregroundColor: p.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.controlRadius,
                            ),
                          ),
                        ),
                        child: Text(
                          auth.isAuthenticated
                              ? 'Apply for ${tier.principalRsv} RSV'
                              : 'Sign in to apply',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    if (!auth.isAuthenticated) ...[
                      const SizedBox(height: 8),
                      Text(
                        MicroloansConstants.needAuthMessage,
                        style: TextStyle(
                          color: p.textMuted,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                MicroloansConstants.disclaimer,
                style: TextStyle(
                  color: p.textMuted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveLoanBanner extends StatelessWidget {
  const _ActiveLoanBanner({required this.tier});

  final MicroloanTier tier;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      borderColor: p.buy.withValues(alpha: 0.4),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: p.buy),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active application · ${tier.name}',
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tier.principalRsv} RSV pending wallet credit',
                  style: TextStyle(color: p.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  final MicroloanTier tier;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      borderColor: selected
          ? p.primary
          : (tier.highlighted ? p.primary.withValues(alpha: 0.35) : null),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tier.name.toUpperCase(),
                style: TextStyle(
                  color: p.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: p.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tier.badge,
                  style: TextStyle(
                    color: p.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? p.primary : p.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${tier.principalRsv} RSV',
            style: context.tradingText.monoLarge.copyWith(fontSize: 26),
          ),
          Text(
            '≈ \$${tier.principalUsd.toStringAsFixed(0)} at cabinet rate',
            style: TextStyle(color: p.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            tier.blurb,
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(label: '${tier.sharePercent}% share'),
              _Chip(label: '${tier.monthlyUsers}/mo users'),
              _Chip(label: tier.termLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: p.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CalcCard extends StatelessWidget {
  const _CalcCard({required this.tier});

  final MicroloanTier tier;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIER MATH',
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          _MetricRow(
            label: 'Advance',
            value: '${tier.principalRsv} RSV',
          ),
          _MetricRow(
            label: 'USD equivalent',
            value: '\$${tier.principalUsd.toStringAsFixed(2)}',
          ),
          _MetricRow(
            label: 'Share of referrals',
            value: '${tier.sharePercent}%',
          ),
          _MetricRow(
            label: 'Monthly quota',
            value: '${tier.monthlyUsers} users',
          ),
          _MetricRow(
            label: 'Term total invites',
            value: '${tier.totalUsersObligation}',
          ),
          _MetricRow(
            label: 'RSV / invite (ref. credit)',
            value: '${ExchangeConstants.referralRewardRsv} RSV each',
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: p.textSecondary, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: p.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: TextStyle(color: p.primary, fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: p.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
