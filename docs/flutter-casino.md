# Bablo Community Casino — Flutter Cursor Integration Guide

> Передай этот документ Flutter Cursor, который работает в Flutter-проекте Bablo Community.  
> Контракт основан на **фактически реализованном** backend (не на черновой спецификации).  
> Flutter — untrusted renderer: **не считает** win / symbols / payout / RNG / bonus math.

Base API: `/api/v1`  
Auth: `Authorization: Bearer <access_token>` (тот же JWT, что для `/users/me`)

Permission: `USE_CASINO` (FREE / PREMIUM / PRO)

---

## 0. Что должен сделать Flutter Cursor

1. Изучить текущую архитектуру Flutter Bablo (навигация, auth, wallet/rewards UI, Copy Pool).
2. Встроить **Casino Module** в существующие patterns — не копировать backend-архитектуру.
3. Реализовать UI/animations, которые **последовательно проигрывают** `events[]` из spin response.
4. Использовать Demo currency для UI-разработки; RSV — тот же `earned_rsv`, что и Copy Pool.

---

## 1. Backend endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/users/me/casino` | Status: eligibility, balances, games, active session |
| GET | `/users/me/casino/balance` | RSV available / committed_copy + Demo |
| POST | `/users/me/casino/demo/reset` | Reset Demo to 10_000 |
| GET | `/users/me/casino/games` | Active game registry |
| GET | `/users/me/casino/games/{game_id}` | Catalog + public config |
| POST | `/users/me/casino/sessions` | Start / resume session |
| GET | `/users/me/casino/sessions/{session_id}` | Session + bonus state |
| POST | `/users/me/casino/spin` | Authoritative spin (idempotent) |
| GET | `/users/me/casino/spins/{spin_id}` | Re-fetch spin after disconnect |
| GET | `/users/me/casino/history` | Spin history summary |
| GET | `/users/me/casino/stats` | User casino stats |
| POST | `/users/me/casino/simulate` | Math sim (dev only) |

Также bootstrap:

`GET /users/me` → поле `"casino": { ... }` (тот же payload, что `/users/me/casino`).

---

## 2. Authentication

- Тот же Telegram Mini App → JWT flow.
- Все casino routes требуют `get_current_user` (ACTIVE user).
- Если нет `USE_CASINO` в `permissions` → `403` `{ "error": "plan_required" }` (сейчас permission есть на всех планах).

---

## 3. Game Registry response

`GET /users/me/casino/games`

```json
{
  "items": [
    {
      "game_id": "bablo_classic",
      "title": "Bablo Classic",
      "description": "Classic 3×3 Bablo slot with five fixed paylines.",
      "game_type": "CLASSIC_SLOT",
      "version": "1.0.0",
      "status": "ACTIVE",
      "supported_currencies": ["RSV", "DEMO"],
      "min_bet": 1.0,
      "max_bet": 100.0,
      "bet_steps": [1.0, 2.0, 5.0, 10.0, 25.0, 50.0, 100.0],
      "features": ["wild_substitutes", "five_paylines"]
    },
    {
      "game_id": "bablo_tumble",
      "game_type": "TUMBLE_SLOT",
      "version": "1.0.0",
      "status": "ACTIVE"
    },
    {
      "game_id": "rsv_hold_and_win",
      "game_type": "HOLD_AND_WIN",
      "version": "1.0.0",
      "status": "ACTIVE"
    }
  ]
}
```

`GET /users/me/casino/games/bablo_classic` добавляет `"config": { ... }` (paytable, paylines, board size, features, disclaimer).

---

## 4. Currencies & wallet (критично)

### Currencies

| Code | Meaning |
|------|---------|
| `DEMO` | Demo Credits (start **10_000**). Не RSV. |
| `RSV` | Platform `RewardAccount.earned_rsv` — **тот же баланс**, что Copy Pool |

### Balance payload

`GET /users/me/casino/balance`

```json
{
  "rsv": {
    "available": 3000.0,
    "committed_copy": 7000.0,
    "total_spendable_field": 3000.0,
    "note": "available = RewardAccount.earned_rsv after Copy locks. Casino may only spend available RSV."
  },
  "demo": {
    "available": 10000.0,
    "starting_credits": 10000.0
  },
  "supported_currencies": ["RSV", "DEMO"]
}
```

### Total vs Available vs Committed

| Concept | Где смотреть |
|---------|----------------|
| Available RSV для Casino | `rsv.available` (= `earned_rsv`) |
| Committed в Copy Bot | `rsv.committed_copy` (equity ACTIVE stake) |
| Total «бумажный» field | Не сумма available+committed в одном поле account — Copy уже **вычел** lock из `earned_rsv` |

**Правило:** ставка Casino возможна только из `rsv.available`.  
Залоченный Copy RSV **нельзя** поставить в Casino.  
После Copy `complete` / `early_exit` RSV снова появляется в `available`.

### Demo

- `POST /users/me/casino/demo/reset` → `{ "demo_credits": 10000.0 }`
- Для Flutter animations всегда начинай с `currency: "DEMO"`.

### On-chain wallet

**Не используется.** Нет Polygon transfer на spin.  
`UserWallet` / Angela on-chain RSV — другой мир.

### RSV Coin symbol ≠ wallet RSV

В Hold & Win символ `RSV_COIN` — только игровая математика/визуал.  
Wallet двигается только через bet debit / win credit.

---

## 5. Session lifecycle

### Start

`POST /users/me/casino/sessions`

```json
{ "game_id": "bablo_classic", "currency": "DEMO" }
```

Response:

```json
{
  "id": "uuid",
  "game_id": "bablo_classic",
  "game_version": "1.0.0",
  "currency": "DEMO",
  "status": "ACTIVE",
  "state": { "next_action": "SPIN" },
  "bonus_state": null,
  "next_action": "SPIN",
  "total_wagered": 0.0,
  "total_won": 0.0,
  "started_at": "...",
  "updated_at": "..."
}
```

### Правила

- Один ACTIVE session на игру; повторный start без bonus завершает предыдущую.
- Если Hold & Win в `mode: BONUS` — session **сохраняется** (не дропать mid-bonus).
- Spin может сам создать session, если `session_id` не передан.

### Hold & Win state

Во время bonus:

```json
{
  "state": {
    "mode": "BONUS",
    "base_bet": 1.0,
    "bonus": {
      "active": true,
      "remaining_respins": 2,
      "locked_coins": [{ "row": 0, "col": 1, "value": 2.0 }],
      "bet": 1.0,
      "accumulated": 12.0
    },
    "next_action": "RESPIN"
  },
  "next_action": "RESPIN"
}
```

Flutter **не** меняет bonus state локально как source of truth — только отображает server state.

---

## 6. Spin request

`POST /users/me/casino/spin`

```json
{
  "game_id": "bablo_classic",
  "bet": 1.0,
  "currency": "DEMO",
  "action": "SPIN",
  "session_id": null,
  "client_request_id": "flutter-uuid-or-ulid",
  "forced_scenario": null
}
```

| Field | Client may send? | Notes |
|-------|------------------|-------|
| `game_id` | yes | |
| `bet` | yes | Must be in `bet_steps` |
| `currency` | yes | `DEMO` \| `RSV` |
| `action` | yes | `SPIN` или `RESPIN` |
| `session_id` | yes | optional |
| `client_request_id` | **required** | idempotency (1–100 chars) |
| `forced_scenario` | only if enabled | see §22 |
| symbols / win / payout / board | **NEVER** | server-only |

Во время Hold & Win bonus: `action: "RESPIN"`, `bet_charged` будет `0` (ставка уже зафиксирована в bonus).

---

## 7. Spin response (unified)

```json
{
  "spin_id": "…",
  "session_id": "…",
  "game_id": "bablo_classic",
  "game_version": "1.0.0",
  "action": "SPIN",
  "bet": 1.0,
  "bet_charged": 1.0,
  "currency": "DEMO",
  "balance_before": 10000.0,
  "balance_after": 10024.0,
  "total_win": 25.0,
  "net_result": 24.0,
  "board": [["CHERRY","COIN","BAR"],["SEVEN","SEVEN","SEVEN"],["BAR","DIAMOND","COIN"]],
  "winning_combinations": [
    {
      "payline_id": "middle",
      "symbol": "SEVEN",
      "positions": [[1,0],[1,1],[1,2]],
      "multiplier": 8.0,
      "payout": 8.0
    }
  ],
  "multiplier": 1.0,
  "triggered_features": [],
  "bonus_state": null,
  "next_action": "SPIN",
  "round_complete": true,
  "events": [
    { "type": "SPIN_STARTED", "data": { "game_id": "bablo_classic", "bet": 1.0 } },
    { "type": "BET_ACCEPTED", "data": { "bet": 1.0, "currency": "DEMO", "balance_before": 10000.0 } },
    { "type": "BOARD_GENERATED", "data": { "board": [["…"]] } },
    { "type": "WIN_DETECTED", "data": { "payline_id": "middle", "symbol": "SEVEN", "payout": 8.0 } },
    { "type": "SPIN_COMPLETED", "data": { "total_win": 25.0, "round_complete": true } },
    { "type": "WIN_CREDITED", "data": { "amount": 25.0, "currency": "DEMO", "balance_after": 10024.0 } }
  ],
  "game_specific": { "paylines_hit": ["middle"] },
  "client_request_id": "flutter-uuid-or-ulid",
  "timestamp": "2026-09-11T…",
  "session": { "…current session…" }
}
```

**Board indexing:** `board[row][col]` — row 0 = top.

---

## 8. Idempotency / retry

1. На каждый logical spin генерируй **новый** `client_request_id` (UUID).
2. Если сеть упала после отправки — **повтори тот же** `client_request_id`.
3. Backend вернёт **тот же** `spin_id` / result; вторая ставка **не** спишется.
4. Также можно `GET /users/me/casino/spins/{spin_id}` если spin_id уже известен.

Не создавай новый request id при retry одного и того же user action.

---

## 9–11. Wallet / RSV / Demo

См. §4. UI должен показывать:

- **Available RSV** для ставок Casino  
- **In Copy** (`committed_copy`) как недоступные  
- **Demo Credits** отдельно (переключатель currency)

---

## 12. Game Event model

Каждый event:

```json
{ "type": "EVENT_NAME", "data": { } }
```

### Все event types (поддерживать во Flutter)

| Type | Когда |
|------|--------|
| `SPIN_STARTED` | Начало |
| `BET_ACCEPTED` | Ставка списана (только если `bet_charged > 0`) |
| `BOARD_GENERATED` | Доска готова (`data.board`) |
| `WIN_DETECTED` | Выигрышная комбинация / cluster / bonus payout |
| `NO_WIN` | Нет выигрыша на этом шаге |
| `CASCADE_STARTED` | Tumble cascade |
| `SYMBOLS_REMOVED` | Удалены символы |
| `NEW_SYMBOLS_DROPPED` | Новые символы + `board` |
| `MULTIPLIER_CHANGED` | Множитель cascade |
| `BONUS_TRIGGERED` | Hold & Win старт |
| `RESPIN_STARTED` | Bonus respin |
| `COIN_LOCKED` | Новая/стартовая RSV_COIN |
| `RESPINS_RESET` | Сброс счётчика respins |
| `BONUS_COMPLETED` | Финал bonus + payout |
| `WIN_CREDITED` | Wallet credit |
| `SPIN_COMPLETED` | Конец этого request |

Flutter проигрывает `events` **строго по порядку**. Не пересчитывай payout из board.

---

## 13. Bablo Classic — event sequence

Typical win:

1. `SPIN_STARTED`
2. `BET_ACCEPTED`
3. `BOARD_GENERATED`
4. `WIN_DETECTED` (× N paylines)
5. `SPIN_COMPLETED`
6. `WIN_CREDITED` (если win > 0)

Loss: вместо WIN_DETECTED → `NO_WIN`.

Paylines: `top`, `middle`, `bottom`, `diag_down`, `diag_up`.  
Symbols: `CHERRY`, `COIN`, `BAR`, `SEVEN`, `DIAMOND`, `BABLO`, `WILD`.

---

## 14. Bablo Tumble — cascade sequence

1. `SPIN_STARTED` → `BET_ACCEPTED` → `BOARD_GENERATED`
2. Loop cascades:
   - `CASCADE_STARTED` (`cascade_index`, `multiplier`)
   - `MULTIPLIER_CHANGED`
   - `WIN_DETECTED` (clusters)
   - `SYMBOLS_REMOVED`
   - `NEW_SYMBOLS_DROPPED` (`new_symbols`, `board`)
3. `SPIN_COMPLETED` → optional `WIN_CREDITED`

`game_specific.cascades[]` — готовая структура для timeline UI.  
Board: **5 rows × 6 cols**. Cluster min size = 8.

---

## 15. RSV Hold & Win — state / events

### Base spin → trigger

1. Normal board
2. Если ≥ 6 `RSV_COIN` → `BONUS_TRIGGERED` + `COIN_LOCKED`×N
3. `next_action = "RESPIN"`, `round_complete = false`
4. Line wins (если есть) платятся сразу; **coin values** копятся и платятся на `BONUS_COMPLETED`

### Respin loop

`action: "RESPIN"`, `bet_charged: 0`

1. `RESPIN_STARTED`
2. `COIN_LOCKED` (новые)
3. `BOARD_GENERATED` (mode BONUS)
4. optional `RESPINS_RESET`
5. либо продолжение (`next_action: RESPIN`), либо `BONUS_COMPLETED` + `WIN_DETECTED` + `WIN_CREDITED`

Board: **3×5**. Empty cells: `EMPTY`. Coin: `RSV_COIN`.

---

## 16. Error models

HTTP `detail`:

```json
{ "error": "insufficient_balance", "message": "Not enough available balance" }
```

| error | HTTP | UI |
|-------|------|-----|
| `insufficient_balance` | 402 | Показать available; предложить Demo / пополнить RSV / дождаться unlock Copy |
| `invalid_bet` / `invalid_bet_step` | 400 | Подсветить bet_steps |
| `game_not_found` / `game_inactive` | 404/400 | Обновить registry |
| `session_not_found` / `session_inactive` | 404/400 | Новый session |
| `bonus_requires_respin` | 400 | Не слать SPIN во время bonus |
| `forced_scenarios_disabled` | 400 | Только prod |
| `plan_required` | 403 | Upgrade / permission |
| `invalid_idempotency` | 400 | Всегда слать client_request_id |

---

## 17. Loading / reconnect / retry

Рекомендуемый flow:

1. Disable Spin button → send request с `client_request_id`.
2. Timeout / network error → retry **same** id (backoff).
3. Success → play `events` animation queue; unlock button только после `SPIN_COMPLETED` (+ UI queue done).
4. App kill mid-animation → `GET session` + optional `GET spin` / history; не гадай outcome.
5. Hold & Win: после reconnect читай `session.next_action` / `bonus_state`.

---

## 18. Что хранить локально

- Last `session_id` per game  
- Last `client_request_id` in-flight (для retry)  
- Cached game configs  
- UI preferences (sounds, turbo)  
- Selected currency  

Не хранить как truth: balances, board, wins, bonus — всегда сверяй с server.

---

## 19. Что Flutter НЕ считает

- RNG / symbol generation  
- Payline / cluster wins  
- Cascade multipliers  
- Bonus trigger / coin values / respin counts  
- Final payout / net  
- Available RSV (кроме отображения server value)

---

## 20. Animation playback

```
for (event in response.events) {
  await play(event); // await animation duration
}
updateBalances(response.balance_after);
applySession(response.session);
```

Turbo mode: shorten delays, **не** skip event semantics.  
Никогда не «угадывай» следующий cascade — бери из events.

---

## 21. Recommended Flutter screen/state structure

Встроить в существующую app navigation Bablo:

```
CasinoHome
  - balance strip (Available RSV | Demo)
  - game grid from registry
CasinoGameScreen(gameId)
  - BetSelector(bet_steps)
  - CurrencyToggle(DEMO/RSV)
  - BoardView (game-specific painter)
  - SpinButton / RespinButton (from session.next_action)
  - EventPlayer / AnimationController driven by events[]
  - BonusOverlay (Hold & Win locked coins + respins)
CasinoHistory
```

State management: следуй существующему Flutter стеку проекта (Riverpod/Bloc/…).  
Модель: `CasinoSpinResult`, `CasinoEvent`, `CasinoSession` — mirrors JSON.

---

## 22. Development / forced scenarios

Env на backend: `CASINO_FORCED_SCENARIOS=true`  
Тогда в spin body можно:

| forced_scenario | Game | Effect |
|-----------------|------|--------|
| `LOSS` / `GUARANTEED_LOSS` | all | No win / no trigger |
| `WIN` / `GUARANTEED_WIN` / `MIDDLE_WIN` | classic | Middle sevens |
| `DIAGONAL_WIN` | classic | Diagonal Bablo |
| `WILD_LINE` | classic | Wild middle |
| `ALL_PAYLINES` | classic | Full diamond |
| `ONE_CASCADE` / `WIN` | tumble | At least one cascade |
| `MULTI_CASCADE` / `CASCADES` | tumble | Full BABLO board |
| `BONUS_TRIGGER` / `HOLD_AND_WIN` | hold&win | Trigger bonus |
| `LINE_WIN` | hold&win | Middle Bablo line |
| `BONUS_COMPLETE` / `NO_NEW_COIN` | hold&win respin | Finish bonus |
| `NEW_COIN` / `RESET_RESPINS` | hold&win respin | Force new coin |

Production: `CASINO_FORCED_SCENARIOS=false` (default) → `forced_scenarios_disabled`.

---

## 23. Example flows (real shapes)

### A) Classic DEMO win (forced)

Request:

```json
{
  "game_id": "bablo_classic",
  "bet": 1.0,
  "currency": "DEMO",
  "action": "SPIN",
  "client_request_id": "ui-test-classic-1",
  "forced_scenario": "GUARANTEED_WIN"
}
```

Expect: `total_win > 0`, events include `WIN_DETECTED`, `balance_after = balance_before - 1 + total_win`.

### B) Idempotent retry

Same body twice → identical `spin_id`, balance unchanged on second call.

### C) RSV blocked by Copy

If Copy locked most RSV and `available < bet` → `402 insufficient_balance`.  
UI: «RSV in Copy Bot» using `committed_copy`.

### D) Hold & Win

1. Spin `forced_scenario: "BONUS_TRIGGER"` → `next_action: RESPIN`  
2. Loop `action: "RESPIN"` + `forced_scenario: "BONUS_COMPLETE"` until `round_complete: true`

---

## 24. Enums / statuses / constants

### game_id
`bablo_classic` | `bablo_tumble` | `rsv_hold_and_win`

### game_type
`CLASSIC_SLOT` | `TUMBLE_SLOT` | `HOLD_AND_WIN`

### currency
`RSV` | `DEMO`

### action
`SPIN` | `RESPIN`

### session.status
`ACTIVE` | `ENDED`

### session.state.mode (Hold & Win)
`BASE` | `BONUS`

### spin status (history)
`COMPLETED`

### Ledger (informational; Flutter rarely needs)
`CASINO_BET` | `CASINO_WIN`

---

## UX notes (не архитектура backend)

- По умолчанию открывай **Demo**.
- Перед RSV-spin явно покажи Available vs In Copy.
- Respin button вместо Spin, когда `next_action == RESPIN`.
- Не давай менять bet во время bonus.
- После network error — «Retry» с тем же request id, не «Spin again».
- RSV Coin на поле подписать как game symbol (не «+RSV to wallet»).

---

## Quick integration checklist

- [ ] Auth header на все casino calls  
- [ ] Registry → game list  
- [ ] Demo spin Classic end-to-end with event player  
- [ ] Idempotent retry  
- [ ] Balance Available RSV vs Copy committed  
- [ ] Tumble cascade player  
- [ ] Hold & Win respin loop from `next_action`  
- [ ] Forced scenarios behind debug flag matching backend env  

---

*Generated for Bablo Community backend Casino MVP. If endpoint/field names change in later commits, update this guide from the live OpenAPI/`/docs` and route handlers in `bablo_platform/api/routes/casino.py`.*
