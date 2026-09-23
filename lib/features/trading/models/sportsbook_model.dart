import '../../../core/constants/sportsbook_constants.dart';
import '../dto/sportsbook_dto.dart';

class SportsbookRsvBalance {
  const SportsbookRsvBalance({
    this.available = 0,
    this.committedCopy = 0,
  });

  final num available;
  final num committedCopy;

  factory SportsbookRsvBalance.fromDto(SportsbookRsvBalanceDto dto) {
    return SportsbookRsvBalance(
      available: dto.available,
      committedCopy: dto.committedCopy,
    );
  }
}

class SportsbookStatus {
  const SportsbookStatus({
    this.eligible = false,
    this.plan = 'FREE',
    this.enabled = true,
    this.sport = SportsbookConstants.sport,
    this.competition = SportsbookConstants.competition,
    this.currency = SportsbookConstants.currency,
    this.minStakeRsv = SportsbookConstants.minStakeRsv,
    this.maxStakeRsv = SportsbookConstants.maxStakeRsv,
    this.balances = const SportsbookRsvBalance(),
  });

  final bool eligible;
  final String plan;
  final bool enabled;
  final String sport;
  final String competition;
  final String currency;
  final num minStakeRsv;
  final num maxStakeRsv;
  final SportsbookRsvBalance balances;

  factory SportsbookStatus.fromDto(SportsbookStatusDto dto) {
    return SportsbookStatus(
      eligible: dto.eligible,
      plan: dto.plan,
      enabled: dto.enabled,
      sport: dto.sport,
      competition: dto.competition,
      currency: dto.currency,
      minStakeRsv: dto.minStakeRsv,
      maxStakeRsv: dto.maxStakeRsv,
      balances: SportsbookRsvBalance.fromDto(dto.balances.rsv),
    );
  }

  num get availableRsv => balances.available;

  num get committedCopyRsv => balances.committedCopy;

  num get stakeCeiling {
    final cap = maxStakeRsv < availableRsv ? maxStakeRsv : availableRsv;
    return cap < minStakeRsv ? minStakeRsv : cap;
  }

  bool get canAffordMin => availableRsv >= minStakeRsv;

  SportsbookStatus copyWithBalance({num? available, num? committedCopy}) {
    return SportsbookStatus(
      eligible: eligible,
      plan: plan,
      enabled: enabled,
      sport: sport,
      competition: competition,
      currency: currency,
      minStakeRsv: minStakeRsv,
      maxStakeRsv: maxStakeRsv,
      balances: SportsbookRsvBalance(
        available: available ?? balances.available,
        committedCopy: committedCopy ?? balances.committedCopy,
      ),
    );
  }
}

class SportsbookEvent {
  const SportsbookEvent({
    required this.id,
    this.sportKey = SportsbookConstants.sport,
    this.eventKind = 'MATCH',
    this.competition = SportsbookConstants.competition,
    this.name = '',
    this.home = '',
    this.away = '',
    this.startsAt,
    this.status = SportsbookConstants.eventScheduled,
    this.bettingEnabled = false,
    this.provider,
    this.providerEventId,
    this.market,
  });

  final String id;
  final String sportKey;
  final String eventKind;
  final String competition;
  final String name;
  final String home;
  final String away;
  final DateTime? startsAt;
  final String status;
  final bool bettingEnabled;
  final String? provider;
  final String? providerEventId;
  final SportsbookMarket? market;

  factory SportsbookEvent.fromDto(SportsbookEventDto dto) {
    return SportsbookEvent(
      id: dto.id,
      sportKey: dto.sportKey,
      eventKind: dto.eventKind,
      competition: dto.competition,
      name: dto.name,
      home: dto.home,
      away: dto.away,
      startsAt: _parseDate(dto.startsAt),
      status: dto.status,
      bettingEnabled: dto.bettingEnabled,
      provider: dto.provider,
      providerEventId: dto.providerEventId,
      market: dto.market == null ? null : SportsbookMarket.fromDto(dto.market!),
    );
  }

  List<String> get lookupIds {
    final ids = <String>[];
    void add(String? value) {
      final id = value?.trim() ?? '';
      if (id.isEmpty || ids.contains(id)) return;
      ids.add(id);
    }

    add(id);
    add(providerEventId);
    return ids;
  }

  String get title {
    if (name.trim().isNotEmpty) return name;
    if (away.isEmpty && home.isEmpty) return 'NBA';
    return '$away @ $home';
  }

  bool get isScheduled =>
      status.toUpperCase() == SportsbookConstants.eventScheduled;

  bool get isLive => status.toUpperCase() == SportsbookConstants.eventLive;

  bool get isFinished =>
      status.toUpperCase() == SportsbookConstants.eventFinished;

  bool get canPlaceBet => bettingEnabled && isScheduled;
}

class SportsbookOutcome {
  const SportsbookOutcome({
    required this.providerOutcomeId,
    this.name = '',
    this.odds = 0,
    this.side = '',
  });

  final String providerOutcomeId;
  final String name;
  final num odds;
  final String side;

  factory SportsbookOutcome.fromDto(SportsbookOutcomeDto dto) {
    return SportsbookOutcome(
      providerOutcomeId: dto.providerOutcomeId,
      name: dto.name.isEmpty ? dto.providerOutcomeId : dto.name,
      odds: dto.odds,
      side: dto.side,
    );
  }

  bool get isHome => side.toLowerCase() == 'home';

  bool get isAway => side.toLowerCase() == 'away';
}

class SportsbookMarket {
  const SportsbookMarket({
    required this.id,
    this.marketType = SportsbookConstants.marketWinner,
    this.providerMarketId,
    this.status = SportsbookConstants.marketOpen,
    this.bookmaker,
    this.lastOddsAt,
    this.outcomes = const [],
  });

  final String id;
  final String marketType;
  final String? providerMarketId;
  final String status;
  final String? bookmaker;
  final DateTime? lastOddsAt;
  final List<SportsbookOutcome> outcomes;

  factory SportsbookMarket.fromDto(SportsbookMarketDto dto) {
    return SportsbookMarket(
      id: dto.id,
      marketType: dto.marketType,
      providerMarketId: dto.providerMarketId,
      status: dto.status,
      bookmaker: dto.bookmaker,
      lastOddsAt: _parseDate(dto.lastOddsAt),
      outcomes: dto.outcomes
          .map(SportsbookOutcome.fromDto)
          .toList(growable: false),
    );
  }

  bool get isOpen => status.toUpperCase() == SportsbookConstants.marketOpen;

  SportsbookOutcome? byProviderId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final outcome in outcomes) {
      if (outcome.providerOutcomeId == id) return outcome;
    }
    return null;
  }
}

class SportsbookMarkets {
  const SportsbookMarkets({
    required this.event,
    required this.market,
  });

  final SportsbookEvent event;
  final SportsbookMarket market;

  factory SportsbookMarkets.fromDto(SportsbookMarketsDto dto) {
    return SportsbookMarkets(
      event: SportsbookEvent.fromDto(dto.event),
      market: SportsbookMarket.fromDto(dto.market),
    );
  }
}

class SportsbookBet {
  const SportsbookBet({
    required this.id,
    this.status = SportsbookConstants.statusOpen,
    this.currency = SportsbookConstants.currency,
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
  final DateTime? acceptedAt;
  final DateTime? settledAt;
  final String? settlementReason;
  final SportsbookEvent? event;

  factory SportsbookBet.fromDto(SportsbookBetDto dto) {
    return SportsbookBet(
      id: dto.id,
      status: dto.status,
      currency: dto.currency,
      betType: dto.betType,
      stake: dto.stake,
      acceptedOdds: dto.acceptedOdds,
      potentialPayout: dto.potentialPayout,
      outcomeName: dto.outcomeName,
      provider: dto.provider,
      providerEventId: dto.providerEventId,
      providerMarketId: dto.providerMarketId,
      providerOutcomeId: dto.providerOutcomeId,
      bookmaker: dto.bookmaker,
      acceptedAt: _parseDate(dto.acceptedAt),
      settledAt: _parseDate(dto.settledAt),
      settlementReason: dto.settlementReason,
      event: dto.event == null ? null : SportsbookEvent.fromDto(dto.event!),
    );
  }

  bool get isOpen => status.toUpperCase() == SportsbookConstants.statusOpen;

  bool get isWon => status.toUpperCase() == SportsbookConstants.statusWon;

  bool get isLost => status.toUpperCase() == SportsbookConstants.statusLost;

  bool get isVoid => status.toUpperCase() == SportsbookConstants.statusVoid;

  String get eventTitle => event?.title ?? outcomeName;

  num? get settledPayout => isWon ? potentialPayout : null;
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}
