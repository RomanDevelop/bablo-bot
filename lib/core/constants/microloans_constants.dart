import 'exchange_constants.dart';

/// Quasi-credit RSV advance — UI shell until backend settlement.
///
/// Economics (cabinet rate [ExchangeConstants.rsvUsd] = \$0.13):
/// user receives RSV now; “interest” is paid in community growth —
/// a share of attributed referrals + a monthly quota into Telegram
/// and Bablo Community. Wallet transfer ships on backend later.
class MicroloansConstants {
  MicroloansConstants._();

  static const title = 'MICROLOANS';
  static const subtitle = 'RSV advance against community growth';
  static const intro =
      'Quasi-credit from Bablo Community. We advance Reserve (RSV) to your '
      'cabinet balance. You repay in acquisition: a fixed share of users you '
      'bring, plus a monthly quota into our Telegram and Bablo Community. '
      'No cash APR — growth is the collateral.';

  static const rsvTicker = ExchangeConstants.rsvTicker;
  static const rsvUsd = ExchangeConstants.rsvUsd;

  static const howItWorksTitle = 'How it works';
  static const howItWorks = <String>[
    'Pick a tier. Principal is credited as RSV (wallet transfer — soon).',
    'Accept the quasi-credit terms: share % + monthly invite quota.',
    'Invite people into Telegram Community and Bablo Community every month.',
    'Missed quotas pause new advances until you catch up (backend enforces).',
  ];

  static const obligationsTitle = 'Your obligations';
  static const disclaimer =
      'This is a product UI for a quasi-credit facility, not a bank loan and '
      'not regulated consumer credit. RSV advances and on-chain payouts are '
      'finalized by Bablo backend. Terms may change before go-live.';

  static const applySoonHint =
      'Application saved locally. Backend contract + RSV wallet credit — soon.';

  static const needAuthMessage =
      'Sign in on your Profile to apply for an RSV microloan.';

  static const telegramHandle = ExchangeConstants.telegramHandle;

  static Uri applyTelegramUri(MicroloanTier tier) {
    return Uri.https('t.me', telegramHandle, {
      'text':
          'Привет! Хочу Microloan tier «${tier.name}»: '
          '${tier.principalRsv} RSV (~\$${tier.principalUsd.toStringAsFixed(0)}), '
          'share ${tier.sharePercent}%, '
          '${tier.monthlyUsers} users/mo × ${tier.termMonths} mo.',
    });
  }

  static double usdOfRsv(int rsv) => rsv * rsvUsd;

  static const tiers = <MicroloanTier>[
    MicroloanTier(
      id: 'starter',
      name: 'Starter',
      badge: 'ENTRY',
      principalRsv: 2000,
      sharePercent: 12,
      monthlyUsers: 8,
      termMonths: 6,
      blurb: 'Test the funnel. Low advance, light monthly quota.',
    ),
    MicroloanTier(
      id: 'builder',
      name: 'Builder',
      badge: 'POPULAR',
      principalRsv: 10000,
      sharePercent: 18,
      monthlyUsers: 20,
      termMonths: 9,
      blurb: 'Serious growth seat. Matches ~\$1,300 cabinet RSV.',
      highlighted: true,
    ),
    MicroloanTier(
      id: 'whale',
      name: 'Whale',
      badge: 'SCALE',
      principalRsv: 50000,
      sharePercent: 25,
      monthlyUsers: 50,
      termMonths: 12,
      blurb: 'Large advance for partners who already bring volume.',
    ),
  ];

  static MicroloanTier? byId(String id) {
    for (final t in tiers) {
      if (t.id == id) return t;
    }
    return null;
  }
}

class MicroloanTier {
  const MicroloanTier({
    required this.id,
    required this.name,
    required this.badge,
    required this.principalRsv,
    required this.sharePercent,
    required this.monthlyUsers,
    required this.termMonths,
    required this.blurb,
    this.highlighted = false,
  });

  final String id;
  final String name;
  final String badge;
  final int principalRsv;
  final int sharePercent;
  final int monthlyUsers;
  final int termMonths;
  final String blurb;
  final bool highlighted;

  double get principalUsd => MicroloansConstants.usdOfRsv(principalRsv);

  int get totalUsersObligation => monthlyUsers * termMonths;

  /// Rough “acquisition cost” of the advance if each invite is valued at
  /// the +5 RSV referral credit from Currency Exchange.
  double get impliedReferralRsvCost =>
      totalUsersObligation * ExchangeConstants.referralRewardRsv.toDouble();

  String get shareLabel => '$sharePercent% of attributed referrals';

  String get quotaLabel =>
      '$monthlyUsers users / month → Telegram + Bablo Community';

  String get termLabel => '$termMonths months';
}
