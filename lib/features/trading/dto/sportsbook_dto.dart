import '../../../core/utils/json_parsers.dart';

class SportsbookRsvBalanceDto {
  const SportsbookRsvBalanceDto({
    this.available = 0,
    this.committedCopy = 0,
  });

  final num available;
  final num committedCopy;

  factory SportsbookRsvBalanceDto.fromJson(Map<String, dynamic> json) {
    return SportsbookRsvBalanceDto(
      available: asNum(json['available']),
      committedCopy: asNum(json['committed_copy']),
    );
  }

  Map<String, dynamic> toJson() => {
        'available': available,
        'committed_copy': committedCopy,
      };
}

class SportsbookBalancesDto {
  const SportsbookBalancesDto({
    this.rsv = const SportsbookRsvBalanceDto(),
  });

  final SportsbookRsvBalanceDto rsv;

  factory SportsbookBalancesDto.fromJson(Map<String, dynamic> json) {
    return SportsbookBalancesDto(
      rsv: SportsbookRsvBalanceDto.fromJson(asMap(json['rsv'])),
    );
  }

  Map<String, dynamic> toJson() => {
        'rsv': rsv.toJson(),
      };
}

class SportsbookStatusDto {
  const SportsbookStatusDto({
    this.eligible = false,
    this.plan = 'FREE',
    this.enabled = true,
    this.sport = 'BASKETBALL',
    this.competition = 'NBA',
    this.currency = 'RSV',
    this.minStakeRsv = 10,
    this.maxStakeRsv = 100,
    this.balances = const SportsbookBalancesDto(),
  });

  final bool eligible;
  final String plan;
  final bool enabled;
  final String sport;
  final String competition;
  final String currency;
  final num minStakeRsv;
  final num maxStakeRsv;
  final SportsbookBalancesDto balances;

  factory SportsbookStatusDto.fromJson(Map<String, dynamic> json) {
    final root = json['sportsbook'] is Map ? asMap(json['sportsbook']) : json;
    final balancesRaw = root['balances'] ?? root['balance'];
    return SportsbookStatusDto(
      eligible: asBool(root['eligible']),
      plan: asString(root['plan'], 'FREE'),
      enabled: root['enabled'] == null ? true : asBool(root['enabled']),
      sport: asString(root['sport'], 'BASKETBALL'),
      competition: asString(root['competition'], 'NBA'),
      currency: asString(root['currency'], 'RSV'),
      minStakeRsv: asNum(root['min_stake_rsv'], 10),
      maxStakeRsv: asNum(root['max_stake_rsv'], 100),
      balances: balancesRaw is Map
          ? SportsbookBalancesDto.fromJson(asMap(balancesRaw))
          : SportsbookBalancesDto(
              rsv: SportsbookRsvBalanceDto.fromJson(asMap(root['rsv'])),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
        'eligible': eligible,
        'plan': plan,
        'enabled': enabled,
        'sport': sport,
        'competition': competition,
        'currency': currency,
        'min_stake_rsv': minStakeRsv,
        'max_stake_rsv': maxStakeRsv,
        'balances': balances.toJson(),
      };
}

class SportsbookEventDto {
  const SportsbookEventDto({
    required this.id,
    this.sportKey = 'BASKETBALL',
    this.eventKind = 'MATCH',
    this.competition = 'NBA',
    this.name = '',
    this.home = '',
    this.away = '',
    this.startsAt,
    this.status = 'SCHEDULED',
    this.bettingEnabled = false,
    this.provider,
    this.providerEventId,
  });

  final String id;
  final String sportKey;
  final String eventKind;
  final String competition;
  final String name;
  final String home;
  final String away;
  final String? startsAt;
  final String status;
  final bool bettingEnabled;
  final String? provider;
  final String? providerEventId;

  factory SportsbookEventDto.fromJson(Map<String, dynamic> json) {
    final root = json['event'] is Map ? asMap(json['event']) : json;
    return SportsbookEventDto(
      id: asString(
        root['id'] ?? root['event_id'] ?? root['sports_event_id'],
        '',
      ),
      sportKey: asString(root['sport_key'], 'BASKETBALL'),
      eventKind: asString(root['event_kind'], 'MATCH'),
      competition: asString(root['competition'], 'NBA'),
      name: asString(root['name'], ''),
      home: asString(root['home'], ''),
      away: asString(root['away'], ''),
      startsAt: asNullableString(root['starts_at']),
      status: asString(root['status'], 'SCHEDULED'),
      bettingEnabled: asBool(root['betting_enabled']),
      provider: asNullableString(root['provider']),
      providerEventId: asNullableString(root['provider_event_id']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sport_key': sportKey,
        'event_kind': eventKind,
        'competition': competition,
        'name': name,
        'home': home,
        'away': away,
        'starts_at': startsAt,
        'status': status,
        'betting_enabled': bettingEnabled,
        'provider': provider,
        'provider_event_id': providerEventId,
      };
}

class SportsbookOutcomeDto {
  const SportsbookOutcomeDto({
    required this.providerOutcomeId,
    this.name = '',
    this.odds = 0,
    this.side = '',
  });

  final String providerOutcomeId;
  final String name;
  final num odds;
  final String side;

  factory SportsbookOutcomeDto.fromJson(Map<String, dynamic> json) {
    return SportsbookOutcomeDto(
      providerOutcomeId: asString(
        json['provider_outcome_id'] ?? json['name'],
        '',
      ),
      name: asString(json['name'], asString(json['provider_outcome_id'], '')),
      odds: asNum(json['odds']),
      side: asString(json['side'], ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'provider_outcome_id': providerOutcomeId,
        'name': name,
        'odds': odds,
        'side': side,
      };
}

class SportsbookMarketDto {
  const SportsbookMarketDto({
    required this.id,
    this.marketType = 'MATCH_WINNER',
    this.providerMarketId,
    this.status = 'OPEN',
    this.bookmaker,
    this.lastOddsAt,
    this.outcomes = const [],
  });

  final String id;
  final String marketType;
  final String? providerMarketId;
  final String status;
  final String? bookmaker;
  final String? lastOddsAt;
  final List<SportsbookOutcomeDto> outcomes;

  factory SportsbookMarketDto.fromJson(Map<String, dynamic> json) {
    final outcomes = <SportsbookOutcomeDto>[];
    final raw = json['outcomes'];
    if (raw is List) {
      for (final item in raw) {
        outcomes.add(SportsbookOutcomeDto.fromJson(asMap(item)));
      }
    }
    return SportsbookMarketDto(
      id: asString(json['id'], ''),
      marketType: asString(json['market_type'], 'MATCH_WINNER'),
      providerMarketId: asNullableString(json['provider_market_id']),
      status: asString(json['status'], 'OPEN'),
      bookmaker: asNullableString(json['bookmaker']),
      lastOddsAt: asNullableString(json['last_odds_at']),
      outcomes: List.unmodifiable(outcomes),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'market_type': marketType,
        'provider_market_id': providerMarketId,
        'status': status,
        'bookmaker': bookmaker,
        'last_odds_at': lastOddsAt,
        'outcomes': outcomes.map((e) => e.toJson()).toList(),
      };
}

class SportsbookMarketsDto {
  const SportsbookMarketsDto({
    required this.event,
    required this.market,
  });

  final SportsbookEventDto event;
  final SportsbookMarketDto market;

  factory SportsbookMarketsDto.fromJson(Map<String, dynamic> json) {
    final marketRaw = json['market'];
    return SportsbookMarketsDto(
      event: SportsbookEventDto.fromJson(
        json['event'] is Map ? asMap(json['event']) : json,
      ),
      market: SportsbookMarketDto.fromJson(
        marketRaw is Map ? asMap(marketRaw) : json,
      ),
    );
  }
}

class SportsbookBetDto {
  const SportsbookBetDto({
    required this.id,
    this.status = 'OPEN',
    this.currency = 'RSV',
    this.betType = 'SINGLE',
    this.stake = 0,
    this.acceptedOdds = 0,
    this.potentialPayout = 0,
    this.outcomeName = '',
    this.provider,
    this.providerEventId,
    this.providerMarketId,
    this.providerOutcomeId,
    this.bookmaker,
    this.acceptedAt,
    this.settledAt,
    this.settlementReason,
    this.event,
  });

  final String id;
  final String status;
  final String currency;
  final String betType;
  final num stake;
  final num acceptedOdds;
  final num potentialPayout;
  final String outcomeName;
  final String? provider;
  final String? providerEventId;
  final String? providerMarketId;
  final String? providerOutcomeId;
  final String? bookmaker;
  final String? acceptedAt;
  final String? settledAt;
  final String? settlementReason;
  final SportsbookEventDto? event;

  factory SportsbookBetDto.fromJson(Map<String, dynamic> json) {
    final root = _unwrapBet(json);
    final eventRaw = root['event'];
    return SportsbookBetDto(
      id: asString(root['id'], ''),
      status: asString(root['status'], 'OPEN'),
      currency: asString(root['currency'], 'RSV'),
      betType: asString(root['bet_type'], 'SINGLE'),
      stake: asNum(root['stake']),
      acceptedOdds: asNum(root['accepted_odds'] ?? root['odds']),
      potentialPayout: asNum(root['potential_payout']),
      outcomeName: asString(
        root['outcome_name'] ?? root['provider_outcome_id'],
        '',
      ),
      provider: asNullableString(root['provider']),
      providerEventId: asNullableString(root['provider_event_id']),
      providerMarketId: asNullableString(root['provider_market_id']),
      providerOutcomeId: asNullableString(root['provider_outcome_id']),
      bookmaker: asNullableString(root['bookmaker']),
      acceptedAt: asNullableString(root['accepted_at']),
      settledAt: asNullableString(root['settled_at']),
      settlementReason: asNullableString(root['settlement_reason']),
      event: eventRaw is Map ? SportsbookEventDto.fromJson(asMap(eventRaw)) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'currency': currency,
        'bet_type': betType,
        'stake': stake,
        'accepted_odds': acceptedOdds,
        'potential_payout': potentialPayout,
        'outcome_name': outcomeName,
        'provider': provider,
        'provider_event_id': providerEventId,
        'provider_market_id': providerMarketId,
        'provider_outcome_id': providerOutcomeId,
        'bookmaker': bookmaker,
        'accepted_at': acceptedAt,
        'settled_at': settledAt,
        'settlement_reason': settlementReason,
        'event': event?.toJson(),
      };
}

Map<String, dynamic> _unwrapBet(Map<String, dynamic> json) {
  if (json['id'] != null && json['stake'] != null) return json;
  if (json['bet'] is Map) return asMap(json['bet']);
  if (json['data'] is Map) return asMap(json['data']);
  return json;
}
