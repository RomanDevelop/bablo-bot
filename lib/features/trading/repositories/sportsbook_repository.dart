import '../../../core/constants/sportsbook_constants.dart';
import '../../../core/errors/data_error.dart';
import '../data_providers/sportsbook_data_provider.dart';
import '../models/sportsbook_model.dart';

class SportsbookRepository {
  SportsbookRepository({required SportsbookDataProviderInterface dataProvider})
      : _dataProvider = dataProvider;

  final SportsbookDataProviderInterface _dataProvider;

  Future<SportsbookStatus> getStatus() async {
    final dto = await _dataProvider.getStatus();
    return SportsbookStatus.fromDto(dto);
  }

  Future<List<SportsbookEvent>> getEvents() async {
    final dtos = await _dataProvider.getEvents();
    return dtos.map(SportsbookEvent.fromDto).toList(growable: false);
  }

  Future<SportsbookEvent> getEvent(String eventId) async {
    final dto = await _dataProvider.getEvent(eventId);
    return SportsbookEvent.fromDto(dto);
  }

  Future<SportsbookMarkets> getMarkets(String eventId) async {
    final dto = await _dataProvider.getMarkets(eventId);
    return SportsbookMarkets.fromDto(dto);
  }

  Future<SportsbookMarkets> resolveMarkets({
    required String eventId,
    SportsbookEvent? preview,
  }) async {
    final embedded = preview?.market;
    if (embedded != null && embedded.outcomes.isNotEmpty) {
      return SportsbookMarkets(event: preview!, market: embedded);
    }

    Object? lastError;
    final ids = <String>[];
    void add(String? value) {
      final id = value?.trim() ?? '';
      if (id.isEmpty || ids.contains(id)) return;
      ids.add(id);
    }

    add(eventId);
    if (preview != null) {
      for (final id in preview.lookupIds) {
        add(id);
      }
    }

    for (final id in ids) {
      try {
        final event = await getEvent(id);
        if (event.market != null && event.market!.outcomes.isNotEmpty) {
          return SportsbookMarkets(event: event, market: event.market!);
        }
      } catch (e) {
        lastError = e;
      }
    }

    for (final id in ids) {
      try {
        final loaded = await getMarkets(id);
        if (loaded.market.outcomes.isNotEmpty) {
          return SportsbookMarkets(
            event: loaded.event.id.isEmpty
                ? (preview ?? loaded.event)
                : loaded.event,
            market: loaded.market,
          );
        }
      } catch (e) {
        lastError = e;
      }
    }

    throw lastError ??
        const DataError(
          errorCode: ErrorCode.unhandled,
          message: SportsbookConstants.errorProvider,
        );
  }

  Future<SportsbookBet> placeBet({
    required String eventId,
    required String providerOutcomeId,
    required num stake,
    required num expectedOdds,
    required String clientRequestId,
  }) async {
    final dto = await _dataProvider.placeBet(
      eventId: eventId,
      providerOutcomeId: providerOutcomeId,
      stake: stake,
      expectedOdds: expectedOdds,
      clientRequestId: clientRequestId,
    );
    return SportsbookBet.fromDto(dto);
  }

  Future<List<SportsbookBet>> getBets({
    int limit = SportsbookConstants.historyLimit,
  }) async {
    final dtos = await _dataProvider.getBets(limit: limit);
    return dtos.map(SportsbookBet.fromDto).toList(growable: false);
  }

  Future<SportsbookBet> getBet(String betId) async {
    final dto = await _dataProvider.getBet(betId);
    return SportsbookBet.fromDto(dto);
  }

  static bool isMissingResource(Object error) {
    if (error is! DataError) return false;
    switch (error.apiError) {
      case 'event_not_found':
      case 'bet_not_found':
      case 'outcome_not_found':
        return true;
    }
    final message = error.displayMessage.toLowerCase();
    return message == 'не найдено' || message == 'not found';
  }

  static bool isProviderUnavailable(Object error) {
    if (error is! DataError) return false;
    switch (error.apiError) {
      case 'provider_unavailable':
      case 'provider_rate_limited':
      case 'provider_error':
        return true;
    }
    return error.errorCode == ErrorCode.exchangeUnavailable;
  }

  static String mapError(Object error) {
    if (error is DataError) {
      switch (error.apiError) {
        case 'plan_required':
          return SportsbookConstants.errorPlanRequired;
        case 'sportsbook_disabled':
          return SportsbookConstants.errorDisabled;
        case 'min_stake':
          return SportsbookConstants.errorMinStake;
        case 'max_stake':
          return SportsbookConstants.errorMaxStake;
        case 'insufficient_balance':
          return SportsbookConstants.errorInsufficient;
        case 'odds_changed':
          return SportsbookConstants.errorOddsChanged;
        case 'event_closed':
        case 'betting_disabled':
        case 'market_closed':
          return SportsbookConstants.errorEventClosed;
        case 'event_not_found':
        case 'bet_not_found':
        case 'outcome_not_found':
          return SportsbookConstants.errorNotFound;
        case 'invalid_idempotency':
          return SportsbookConstants.errorIdempotency;
        case 'provider_unavailable':
        case 'provider_rate_limited':
        case 'provider_error':
          return SportsbookConstants.errorProvider;
      }
      return error.displayMessage;
    }
    return error.toString();
  }
}
