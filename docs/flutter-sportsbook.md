# Bablo Sportsbook — Flutter Cursor Integration Guide

> Передай этот документ Flutter Cursor в проекте Bablo Community.  
> Контракт основан на **фактически реализованном** backend.  
> Flutter — untrusted renderer: **не считает** payout, winner, settlement и не меняет RSV сам.

Base: `https://api.bablochatik.com/api/v1`  
Auth: `Authorization: Bearer <access_token>` (тот же JWT, что для `/users/me`)

Permission: `USE_SPORTSBOOK` — **только PREMIUM и PRO**.  
FREE → экран «Доступно с PREMIUM», ставки не слать.

---

## 0. Что это в продукте (MVP)

- Sport: **NBA** (`sport_key: BASKETBALL`)
- Валюта: **только RSV** (тот же `earned_rsv`, что Copy и Casino)
- **Нет DEMO**
- Только **single prematch** (1 исход на матч)
- Рынок: **MATCH_WINNER** (home / away, decimal odds)
- Live betting **нет**. После стартового времени `betting_enabled=false`
- Backend — единственный source of truth по балансу и результату ставки

---

## 1. Что должен сделать Flutter Cursor

1. Встроить модуль в текущие patterns (auth, RSV wallet, Copy, Casino). Не копировать backend-пакеты.
2. Показывать только NBA list → event → 2 исхода → stake → confirm.
3. Ставить **только** с `sportsbook.balances.rsv.available`.
4. После ставки рефрешить `/users/me` или `/users/me/sports`.
5. Историю брать с `/users/me/sports/bets`. Статус `OPEN` → `WON` / `LOST` / `VOID` приходит с backend (polling 30–60 сек или pull-to-refresh).

---

## 2. Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/users/me/sports` | Eligibility, plan, min/max stake, RSV available |
| GET | `/users/me/sports/events` | Upcoming / live NBA |
| GET | `/users/me/sports/events/{id}` | Один матч |
| GET | `/users/me/sports/events/{id}/markets` | MATCH_WINNER + odds |
| POST | `/users/me/sports/bets` | Принять ставку (idempotent) |
| GET | `/users/me/sports/bets?limit=50` | История |
| GET | `/users/me/sports/bets/{id}` | Одна ставка |

Bootstrap:

`GET /users/me` → поле `"sportsbook"` (тот же shape, что `GET /users/me/sports`) + `"permissions"`.

---

## 3. Auth & gate

- Все routes требуют Bearer.
- **Не** передавать `user_id`.
- Показывать спортбук если `permissions.contains('USE_SPORTSBOOK')` **или** `sportsbook.eligible == true`.
- Иначе: «Нужна подписка PREMIUM».

---

## 4. Status / wallet

`GET /users/me/sports`

```json
{
  "eligible": true,
  "plan": "PREMIUM",
  "enabled": true,
  "sport": "BASKETBALL",
  "competition": "NBA",
  "currency": "RSV",
  "min_stake_rsv": 10.0,
  "max_stake_rsv": 100.0,
  "balances": {
    "rsv": {
      "available": 3000.0,
      "committed_copy": 2000.0
    }
  }
}
```

| Поле | Смысл |
|------|--------|
| `available` | Можно поставить. Уже минус Copy lock и открытые sportsbook holds |
| `committed_copy` | RSV в Copy Pool — **нельзя** ставить |
| `min_stake_rsv` | **10** |
| `max_stake_rsv` | **100** |

Тот же RSV, что `rewards.earned_rsv` / Casino RSV. После ставки `available` падает сразу.

---

## 5. Events

`GET /users/me/sports/events` → `{ "items": [ ... ] }`

```json
{
  "id": "uuid",
  "sport_key": "BASKETBALL",
  "event_kind": "MATCH",
  "competition": "NBA",
  "name": "Boston Celtics @ Los Angeles Lakers",
  "home": "Los Angeles Lakers",
  "away": "Boston Celtics",
  "starts_at": "2026-09-24T00:30:00+00:00",
  "status": "SCHEDULED",
  "betting_enabled": true,
  "provider": "the_odds_api",
  "provider_event_id": "…"
}
```

`status`: `SCHEDULED` | `LIVE` | `FINISHED`  
`name` формат: `{away} @ {home}`

Правила UI:

- Кнопка «Поставить» только если `betting_enabled == true` **и** `status == SCHEDULED`
- `LIVE` — показать «Идёт», без ставки
- Список может быть пустым (off-season / provider down)

---

## 6. Markets / odds

`GET /users/me/sports/events/{id}/markets`

```json
{
  "event": { "...как выше..." },
  "market": {
    "id": "uuid",
    "market_type": "MATCH_WINNER",
    "provider_market_id": "h2h",
    "status": "OPEN",
    "bookmaker": "draftkings",
    "last_odds_at": "2026-09-23T09:00:00+00:00",
    "outcomes": [
      {
        "provider_outcome_id": "Los Angeles Lakers",
        "name": "Los Angeles Lakers",
        "odds": 1.85,
        "side": "home"
      },
      {
        "provider_outcome_id": "Boston Celtics",
        "name": "Boston Celtics",
        "odds": 2.05,
        "side": "away"
      }
    ]
  }
}
```

- Odds **decimal**. Потенциал на UI: `stake * odds` — только preview. Backend сам пишет `potential_payout`.
- `provider_outcome_id` = имя команды. Его и слать в POST.
- Если `market.status != OPEN` — не принимать ставку.

Линии кэшируются (~90 мин). Перед confirm лучше ещё раз дернуть markets.

---

## 7. Place bet

```http
POST /api/v1/users/me/sports/bets
Authorization: Bearer …
Content-Type: application/json

{
  "event_id": "uuid-из-events",
  "provider_outcome_id": "Los Angeles Lakers",
  "stake": 20,
  "client_request_id": "flutter-unique-id",
  "expected_odds": 1.85
}
```

| Поле | Правило |
|------|---------|
| `event_id` | UUID из catalog, не `provider_event_id` |
| `provider_outcome_id` | Точная строка из `outcomes[]` |
| `stake` | 10…100, ≤ `balances.rsv.available` |
| `client_request_id` | **обязателен**, 1–100 символов. Новый UUID на каждую попытку юзера. Retry с тем же id вернёт ту же ставку |
| `expected_odds` | **обязательно слать**. Если линия ушла больше чем на 0.05 → `odds_changed` |

Нет поля `currency` — всегда RSV. Нет `user_id`.

### Успех `200`

```json
{
  "id": "uuid",
  "status": "OPEN",
  "currency": "RSV",
  "bet_type": "SINGLE",
  "stake": 20.0,
  "accepted_odds": 1.85,
  "potential_payout": 37.0,
  "outcome_name": "Los Angeles Lakers",
  "provider": "the_odds_api",
  "provider_event_id": "…",
  "provider_market_id": "h2h",
  "provider_outcome_id": "Los Angeles Lakers",
  "bookmaker": "draftkings",
  "accepted_at": "…",
  "settled_at": null,
  "settlement_reason": null,
  "event": { }
}
```

Показывать `accepted_odds` и `potential_payout` с ответа, не пересчитывать заново как истину.

После accept линия у провайдера **не** меняет эту ставку.

---

## 8. History

`GET /users/me/sports/bets?limit=50` → `{ "items": [ ...тот же shape... ] }`

`status`:

| Status | UI |
|--------|-----|
| `OPEN` | Принята, ждём результат |
| `WON` | Выигрыш начислен (`potential_payout` вернулся в RSV) |
| `LOST` | Проигрыш, stake сгорел |
| `VOID` | Stake вернули (нет счёта / отмена / ничья) |

Не считать WON/LOST на клиенте по счёту матча.

---

## 9. Экраны (мин. UX)

### A. Hub

1. Gate PREMIUM
2. Available RSV + «в Copy: committed_copy»
3. CTA к списку NBA
4. Ссылка на историю

### B. Список матчей

1. `starts_at` локальное время
2. away @ home
3. Badge SCHEDULED / LIVE
4. Disabled если `!betting_enabled`

### C. Карточка матча + slip

1. Два исхода + decimal odds
2. Stake stepper 10…min(100, available)
3. Preview: «Возможный выигрыш ≈ stake × odds»
4. Confirm → POST с `expected_odds` и новым `client_request_id`
5. Если `odds_changed` — обновить markets и попросить confirm ещё раз

### D. История

Список: матч, исход, stake, odds, status, payout если WON.

---

## 10. Ошибки

`detail` = `{ "error": "…", "message": "…" }`

| `error` | HTTP | UI |
|---------|------|-----|
| `plan_required` | 403 | «Нужна подписка PREMIUM» |
| `sportsbook_disabled` | 403 | «Спортбук временно выключен» |
| `min_stake` | 400 | «Минимум 10 RSV» |
| `max_stake` | 400 | «Максимум 100 RSV» |
| `insufficient_balance` | 402 | «Недостаточно available RSV» |
| `odds_changed` | 400 | «Коэффициент изменился — обнови» |
| `event_closed` / `betting_disabled` / `market_closed` | 400 | «Ставки на матч закрыты» |
| `event_not_found` / `bet_not_found` / `outcome_not_found` | 404 | «Не найдено» |
| `invalid_idempotency` | 400 | Всегда слать `client_request_id` |
| `provider_unavailable` / `provider_rate_limited` / `provider_error` | 503 | «Линии временно недоступны» |

---

## 11. Dart sketch

```dart
Future<Map<String, dynamic>> placeSportsBet({
  required String token,
  required String eventId,
  required String providerOutcomeId,
  required double stake,
  required double expectedOdds,
  required String clientRequestId,
}) async {
  final res = await http.post(
    Uri.parse('$apiBase/users/me/sports/bets'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'event_id': eventId,
      'provider_outcome_id': providerOutcomeId,
      'stake': stake,
      'expected_odds': expectedOdds,
      'client_request_id': clientRequestId,
    }),
  );
  return jsonDecode(res.body) as Map<String, dynamic>;
}
```

`clientRequestId = const Uuid().v4()` на каждый tap Confirm. При retry сети — тот же id.

---

## 12. Не делать

- DEMO / второй RSV wallet
- Свой расчёт settlement
- Live / parlay / F1 в этом MVP
- Provider API key на клиенте
- Ставка без `expected_odds` и без `client_request_id`

---

## Checklist

- [ ] Gate `USE_SPORTSBOOK` / `sportsbook.eligible`
- [ ] RSV available + Copy committed hint
- [ ] NBA list + match card
- [ ] Slip 10–100, preview payout
- [ ] POST idempotent + `expected_odds`
- [ ] History OPEN/WON/LOST/VOID
- [ ] Ошибки из таблицы
- [ ] Refresh bootstrap после ставки
