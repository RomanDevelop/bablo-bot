import '../../../core/utils/json_parsers.dart';

class BabloBootstrap {
  const BabloBootstrap({
    required this.user,
    required this.telegram,
    required this.subscription,
    required this.stats,
    required this.rewards,
    this.wallet,
    required this.referral,
    required this.trading,
    required this.permissions,
  });

  final BabloUser user;
  final BabloTelegram telegram;
  final BabloSubscription subscription;
  final BabloUserStats stats;
  final BabloRewards rewards;
  final BabloWallet? wallet;
  final BabloReferral referral;
  final BabloTrading trading;
  final List<String> permissions;

  factory BabloBootstrap.fromJson(Map<String, dynamic> json) {
    return BabloBootstrap(
      user: BabloUser.fromJson(asMap(json['user'])),
      telegram: BabloTelegram.fromJson(asMap(json['telegram'])),
      subscription: BabloSubscription.fromJson(asMap(json['subscription'])),
      stats: BabloUserStats.fromJson(asMap(json['stats'])),
      rewards: BabloRewards.fromJson(asMap(json['rewards'])),
      wallet: json['wallet'] == null
          ? null
          : BabloWallet.fromJson(asMap(json['wallet'])),
      referral: BabloReferral.fromJson(asMap(json['referral'])),
      trading: BabloTrading.fromJson(asMap(json['trading'])),
      permissions: _asStringList(json['permissions']),
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'telegram': telegram.toJson(),
        'subscription': subscription.toJson(),
        'stats': stats.toJson(),
        'rewards': rewards.toJson(),
        'wallet': wallet?.toJson(),
        'referral': referral.toJson(),
        'trading': trading.toJson(),
        'permissions': permissions,
      };
}

class BabloUser {
  const BabloUser({
    required this.id,
    required this.status,
    required this.role,
    required this.displayName,
    this.avatarUrl,
    this.locale,
    this.timezone,
    this.createdAt,
    this.lastLoginAt,
  });

  final String id;
  final String status;
  final String role;
  final String displayName;
  final String? avatarUrl;
  final String? locale;
  final String? timezone;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  factory BabloUser.fromJson(Map<String, dynamic> json) {
    return BabloUser(
      id: asString(json['id']),
      status: asString(json['status'], 'ACTIVE'),
      role: asString(json['role'], 'USER'),
      displayName: asString(json['display_name'], 'Bablo Member'),
      avatarUrl: json['avatar_url'] as String?,
      locale: json['locale'] as String?,
      timezone: json['timezone'] as String?,
      createdAt: _parseDate(json['created_at']),
      lastLoginAt: _parseDate(json['last_login_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'role': role,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'locale': locale,
        'timezone': timezone,
        'created_at': createdAt?.toIso8601String(),
        'last_login_at': lastLoginAt?.toIso8601String(),
      };
}

class BabloTelegram {
  const BabloTelegram({
    required this.telegramUserId,
    this.username,
  });

  final String telegramUserId;
  final String? username;

  factory BabloTelegram.fromJson(Map<String, dynamic> json) {
    return BabloTelegram(
      telegramUserId: asString(json['telegram_user_id']),
      username: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'telegram_user_id': telegramUserId,
        'username': username,
      };

  String get handle {
    final u = username?.trim();
    if (u == null || u.isEmpty) return 'tg:$telegramUserId';
    return u.startsWith('@') ? u : '@$u';
  }
}

class BabloSubscription {
  const BabloSubscription({
    required this.plan,
    required this.status,
    this.expiresAt,
    this.maxConnectedAccounts = 0,
  });

  final String plan;
  final String status;
  final DateTime? expiresAt;
  final int maxConnectedAccounts;

  factory BabloSubscription.fromJson(Map<String, dynamic> json) {
    final limits = asMap(json['limits']);
    return BabloSubscription(
      plan: asString(json['plan'], 'FREE'),
      status: asString(json['status'], 'ACTIVE'),
      expiresAt: _parseDate(json['expires_at']),
      maxConnectedAccounts: asInt(limits['max_connected_accounts']),
    );
  }

  Map<String, dynamic> toJson() => {
        'plan': plan,
        'status': status,
        'expires_at': expiresAt?.toIso8601String(),
        'limits': {'max_connected_accounts': maxConnectedAccounts},
      };
}

class BabloUserStats {
  const BabloUserStats({
    this.points = 0,
    this.lifetimePoints = 0,
    this.level = 1,
    this.rating = 0,
    this.activityScore = 0,
    this.rank,
  });

  final num points;
  final num lifetimePoints;
  final int level;
  final num rating;
  final num activityScore;
  final int? rank;

  factory BabloUserStats.fromJson(Map<String, dynamic> json) {
    return BabloUserStats(
      points: asNum(json['points']),
      lifetimePoints: asNum(json['lifetime_points']),
      level: asInt(json['level'], 1),
      rating: asNum(json['rating']),
      activityScore: asNum(json['activity_score']),
      rank: json['rank'] == null ? null : asInt(json['rank']),
    );
  }

  Map<String, dynamic> toJson() => {
        'points': points,
        'lifetime_points': lifetimePoints,
        'level': level,
        'rating': rating,
        'activity_score': activityScore,
        'rank': rank,
      };
}

class BabloRewards {
  const BabloRewards({
    this.earnedRsv = 0,
    this.pendingRsv = 0,
    this.paidRsv = 0,
  });

  final num earnedRsv;
  final num pendingRsv;
  final num paidRsv;

  factory BabloRewards.fromJson(Map<String, dynamic> json) {
    return BabloRewards(
      earnedRsv: asNum(json['earned_rsv']),
      pendingRsv: asNum(json['pending_rsv']),
      paidRsv: asNum(json['paid_rsv']),
    );
  }

  Map<String, dynamic> toJson() => {
        'earned_rsv': earnedRsv,
        'pending_rsv': pendingRsv,
        'paid_rsv': paidRsv,
      };

  num get totalRsv => earnedRsv + pendingRsv + paidRsv;
}

class BabloWallet {
  const BabloWallet({
    required this.network,
    required this.address,
    required this.verified,
  });

  final String network;
  final String address;
  final bool verified;

  factory BabloWallet.fromJson(Map<String, dynamic> json) {
    return BabloWallet(
      network: asString(json['network']),
      address: asString(json['address']),
      verified: json['verified'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'network': network,
        'address': address,
        'verified': verified,
      };
}

class BabloReferral {
  const BabloReferral({
    required this.code,
    required this.link,
    this.invitedCount = 0,
    this.activeInvitedCount = 0,
  });

  final String code;
  final String link;
  final int invitedCount;
  final int activeInvitedCount;

  factory BabloReferral.fromJson(Map<String, dynamic> json) {
    return BabloReferral(
      code: asString(json['code']),
      link: asString(json['link']),
      invitedCount: asInt(json['invited_count']),
      activeInvitedCount: asInt(json['active_invited_count']),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'link': link,
        'invited_count': invitedCount,
        'active_invited_count': activeInvitedCount,
      };
}

class BabloTrading {
  const BabloTrading({
    this.accountsCount = 0,
    this.activeAccounts = 0,
    this.totalPnl,
  });

  final int accountsCount;
  final int activeAccounts;
  final num? totalPnl;

  factory BabloTrading.fromJson(Map<String, dynamic> json) {
    return BabloTrading(
      accountsCount: asInt(json['accounts_count']),
      activeAccounts: asInt(json['active_accounts']),
      totalPnl: json['total_pnl'] == null ? null : asNum(json['total_pnl']),
    );
  }

  Map<String, dynamic> toJson() => {
        'accounts_count': accountsCount,
        'active_accounts': activeAccounts,
        'total_pnl': totalPnl,
      };
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

List<String> _asStringList(dynamic value) {
  if (value is! List) return const [];
  return value.map((e) => e.toString()).toList();
}
