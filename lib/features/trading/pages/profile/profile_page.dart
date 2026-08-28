import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../components/trading_card.dart';
import '../../../../core/auth/auth_session.dart';
import '../../../../core/constants/auth_constants.dart';
import '../../../../core/constants/exchange_constants.dart';
import '../../../../core/constants/microloans_constants.dart';
import '../../../../core/mwwm/core_mwwm_widget.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigate_back.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../features/auth/models/bablo_bootstrap.dart';
import 'di/profile_wm_builder.dart';
import 'profile_wm.dart';

class ProfilePage extends CoreMwwmWidget<ProfileWidgetModel> {
  ProfilePage({super.key})
      : super(widgetModelBuilder: createProfileWidgetModel);

  static Route<void> route() => MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.profile),
        builder: (_) => ProfilePage(),
      );

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState
    extends MwwmWidgetState<ProfilePage, ProfileWidgetModel> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final auth = context.watch<AuthSession>();
    final bootstrap = auth.bootstrap;

    return StreamBuilder<ProfileState>(
      stream: wm.stateStream,
      initialData: wm.stateStream.value,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const ProfileState();

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
            title: const Text('Profile'),
            actions: [
              if (wm.isAuthenticated)
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: state.isBusy ? null : wm.refreshProfile,
                  icon: state.isBusy
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: p.primary,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            children: [
              Text(
                'ACCOUNT',
                style: TextStyle(
                  color: p.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                wm.isAuthenticated ? wm.displayName : 'Guest',
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                wm.isAuthenticated
                    ? '${bootstrap?.subscription.plan ?? 'FREE'} · Bablo User Platform'
                    : 'Sign in via Telegram Mini App (@${AuthConstants.botUsername})',
                style: TextStyle(
                  color: p.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              if (!wm.isAuthenticated)
                _GuestAuthCard(
                  isBusy: state.isBusy,
                  inTelegram: auth.isInTelegram,
                  error: auth.errorMessage,
                  onSignIn: wm.signIn,
                )
              else if (bootstrap != null) ...[
                _IdentityCard(
                  bootstrap: bootstrap,
                  onSignOut: wm.signOut,
                  isBusy: state.isBusy,
                ),
                const SizedBox(height: 12),
                _RsvBalanceCard(
                  paidRsv: wm.rsvBalance,
                  earnedRsv: wm.earnedRsv,
                ),
                const SizedBox(height: 12),
                _ReferralCard(referral: bootstrap.referral),
                const SizedBox(height: 12),
                _StatsCard(stats: bootstrap.stats),
                const SizedBox(height: 12),
                _LoanStatusCard(
                  loan: wm.activeLoan,
                  appliedAt: auth.loanAppliedAt,
                  onOpenMicroloans: () =>
                      context.push(AppRoutes.microloans),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _GuestAuthCard extends StatelessWidget {
  const _GuestAuthCard({
    required this.isBusy,
    required this.inTelegram,
    required this.onSignIn,
    this.error,
  });

  final bool isBusy;
  final bool inTelegram;
  final VoidCallback onSignIn;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, color: p.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            inTelegram ? 'Sign in with Telegram' : AuthConstants.outsideTelegramTitle,
            style: TextStyle(
              color: p.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            inTelegram
                ? 'Authorize with your Telegram identity to unlock RSV balance, '
                    'referrals and microloans.'
                : AuthConstants.outsideTelegramBody,
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (error != null && error!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              error!,
              style: TextStyle(color: p.danger, fontSize: 12, height: 1.35),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isBusy
                  ? null
                  : inTelegram
                      ? onSignIn
                      : () => launchUrl(
                            Uri.parse(AuthConstants.botDeepLink),
                            mode: LaunchMode.externalApplication,
                          ),
              style: FilledButton.styleFrom(
                backgroundColor: p.primary,
                foregroundColor: p.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.controlRadius),
                ),
              ),
              child: Text(
                inTelegram
                    ? (isBusy ? 'Signing in…' : 'Sign in')
                    : 'Open @${AuthConstants.botUsername}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.bootstrap,
    required this.onSignOut,
    required this.isBusy,
  });

  final BabloBootstrap bootstrap;
  final VoidCallback onSignOut;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final name = bootstrap.user.displayName;
    return TradingCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: p.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'B',
              style: TextStyle(
                color: p.primary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bootstrap.telegram.handle,
                  style: TextStyle(color: p.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Plan ${bootstrap.subscription.plan}',
                  style: TextStyle(color: p.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: isBusy ? null : onSignOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _RsvBalanceCard extends StatelessWidget {
  const _RsvBalanceCard({
    required this.paidRsv,
    required this.earnedRsv,
  });

  final num paidRsv;
  final num earnedRsv;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final usd = paidRsv * ExchangeConstants.rsvUsd;
    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RSV REWARDS',
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${paidRsv.toStringAsFixed(2)} RSV paid',
            style: context.tradingText.monoLarge.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(
            'Earned ${earnedRsv.toStringAsFixed(2)} RSV · '
            '≈ \$${usd.toStringAsFixed(2)} at cabinet rate',
            style: TextStyle(color: p.textSecondary, fontSize: 12),
          ),
          if (context.read<AuthSession>().bootstrap?.wallet != null) ...[
            const SizedBox(height: 8),
            Text(
              'Wallet ${context.read<AuthSession>().bootstrap!.wallet!.address}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: p.textMuted, fontSize: 11),
            ),
          ] else
            Text(
              'On-chain wallet payout — coming soon',
              style: TextStyle(color: p.textMuted, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  const _ReferralCard({required this.referral});

  final BabloReferral referral;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return TradingCard(
      onTap: () => SharePlus.instance.share(ShareParams(text: referral.link)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REFERRAL',
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            referral.code,
            style: TextStyle(
              color: p.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${referral.invitedCount} invited · '
            '${referral.activeInvitedCount} active',
            style: TextStyle(color: p.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            referral.link,
            style: TextStyle(color: p.primary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final BabloUserStats stats;

  @override
  Widget build(BuildContext context) {
    return TradingCard(
      child: Row(
        children: [
          _StatTile(label: 'Level', value: '${stats.level}'),
          _StatTile(label: 'Points', value: '${stats.points}'),
          _StatTile(label: 'Rating', value: stats.rating.toStringAsFixed(1)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: p.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: p.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _LoanStatusCard extends StatelessWidget {
  const _LoanStatusCard({
    required this.loan,
    required this.appliedAt,
    required this.onOpenMicroloans,
  });

  final MicroloanTier? loan;
  final DateTime? appliedAt;
  final VoidCallback onOpenMicroloans;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    if (loan == null) {
      return TradingCard(
        onTap: onOpenMicroloans,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No active microloan',
                    style: TextStyle(
                      color: p.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Browse RSV advance tiers',
                    style: TextStyle(color: p.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.textMuted),
          ],
        ),
      );
    }

    final applied = appliedAt != null
        ? DateFormat('d MMM yyyy', 'ru').format(appliedAt!)
        : '—';

    return TradingCard(
      borderColor: p.buy.withValues(alpha: 0.35),
      onTap: onOpenMicroloans,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MICROLOAN · ${loan!.name.toUpperCase()}',
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${loan!.principalRsv} RSV advance',
            style: TextStyle(
              color: p.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Applied $applied · pending wallet credit',
            style: TextStyle(color: p.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
