import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    // Rebuild when AuthSession changes (sign-in / loan apply).
    context.watch<AuthSession>();

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
                    ? 'Cabinet profile · RSV wallet transfer ships on backend'
                    : 'Sign in to manage microloans and your RSV balance',
                style: TextStyle(
                  color: p.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              if (!wm.isAuthenticated)
                _GuestAuthCard(onSignIn: wm.signIn)
              else ...[
                _IdentityCard(
                  name: wm.displayName,
                  handle: wm.handle,
                  onSignOut: wm.signOut,
                ),
                const SizedBox(height: 12),
                _RsvBalanceCard(balance: wm.rsvBalance),
                const SizedBox(height: 12),
                _LoanStatusCard(
                  loan: wm.activeLoan,
                  appliedAt: context.read<AuthSession>().loanAppliedAt,
                  onOpenMicroloans: () =>
                      context.push(AppRoutes.microloans),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Backend auth, KYC and on-chain RSV payout are not live yet. '
                'This screen is the UI shell so you can review terms and '
                'prepare applications.',
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

class _GuestAuthCard extends StatelessWidget {
  const _GuestAuthCard({required this.onSignIn});

  final VoidCallback onSignIn;

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
            'Not signed in',
            style: TextStyle(
              color: p.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Authorize to unlock your Profile, RSV balance and Microloan '
            'applications. Real Bablo backend login arrives next.',
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSignIn,
              style: FilledButton.styleFrom(
                backgroundColor: p.primary,
                foregroundColor: p.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.controlRadius),
                ),
              ),
              child: const Text(
                'Sign in',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
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
    required this.name,
    required this.handle,
    required this.onSignOut,
  });

  final String name;
  final String handle;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
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
                  handle,
                  style: TextStyle(color: p.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSignOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _RsvBalanceCard extends StatelessWidget {
  const _RsvBalanceCard({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final usd = balance * ExchangeConstants.rsvUsd;
    return TradingCard(
      borderColor: p.primary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RSV BALANCE',
            style: TextStyle(
              color: p.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$balance RSV',
            style: context.tradingText.monoLarge.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(
            '≈ \$${usd.toStringAsFixed(2)} · crypto wallet payout — soon',
            style: TextStyle(color: p.textSecondary, fontSize: 12),
          ),
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
          Row(
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
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: p.textMuted, size: 20),
            ],
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
          const SizedBox(height: 6),
          Text(
            '${loan!.sharePercent}% share · ${loan!.monthlyUsers}/mo users · '
            '${loan!.termMonths} mo',
            style: TextStyle(color: p.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Applied $applied · status: pending wallet credit',
            style: TextStyle(color: p.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
