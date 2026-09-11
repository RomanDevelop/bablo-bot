# Flutter — Copy Pool (передай фронту)

Base: `https://api.bablochatik.com/api/v1`  
Auth: `Authorization: Bearer <access_token>` (как у `/users/me`)

## Что это для юзера

PREMIUM+ может **залочить Earned RSV** (≥500) на **30 дней** и виртуально копировать сделки master-бота Bablo.  
Это **не** реальный Binance-счёт. PnL (плюс и минус) крутит equity stake.  
Досрочный выход = **−14%** от equity.

---

## Откуда брать данные

### 1) Bootstrap (уже есть)

`GET /users/me` → поле `copy` + `permissions` + `rewards.earned_rsv`

```json
{
  "permissions": ["…", "USE_COPY_TRADING"],
  "rewards": { "earned_rsv": 5000, "pending_rsv": 0, "paid_rsv": 0 },
  "copy": {
    "eligible": true,
    "plan": "PREMIUM",
    "min_stake_rsv": 500,
    "lock_days": 30,
    "early_exit_penalty_pct": 14,
    "disclaimer": "Виртуальное копирование…",
    "available_earned_rsv": 4500,
    "pool_equity_rsv": 1000,
    "stake": null
  }
}
```

Если `stake != null` — копирование активно:

```json
"stake": {
  "id": "uuid",
  "status": "ACTIVE",
  "locked_rsv": 1000,
  "equity_rsv": 1105.2,
  "pnl_rsv": 105.2,
  "pool_share": 0.25,
  "started_at": "…",
  "ends_at": "…",
  "seconds_remaining": 2500000,
  "can_complete": false,
  "can_early_exit": true
}
```

Показывать экран Copy только если:
- `permissions.contains('USE_COPY_TRADING')` **или** `copy.eligible == true`
- иначе: «Доступно с PREMIUM»

---

## API

| Method | Path | Body | Когда |
|--------|------|------|--------|
| GET | `/users/me/copy` | — | обновить статус |
| GET | `/users/me/copy/disclaimer` | — | текст дисклеймера |
| POST | `/users/me/copy/enable` | см. ниже | подключить |
| POST | `/users/me/copy/topup` | `{ "amount_rsv": 100 }` | докинуть RSV |
| POST | `/users/me/copy/exit` | — | досрочный выход −14% |
| POST | `/users/me/copy/complete` | — | после истечения 30d |
| GET | `/users/me/copy/history?limit=50` | — | зеркальные сделки |

### Enable

```http
POST /api/v1/users/me/copy/enable
Authorization: Bearer …
Content-Type: application/json

{
  "amount_rsv": 500,
  "accept_disclaimer": true
}
```

Правила UI:
- `amount_rsv >= 500`
- `amount_rsv <= available_earned_rsv`
- checkbox «Принимаю условия» → `accept_disclaimer: true` (без этого 400)

### Dart example

```dart
Future<Map<String, dynamic>> enableCopy({
  required String token,
  required double amount,
}) async {
  final res = await http.post(
    Uri.parse('$apiBase/users/me/copy/enable'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'amount_rsv': amount,
      'accept_disclaimer': true,
    }),
  );
  // 200 → тот же shape, что GET /users/me/copy
  return jsonDecode(res.body) as Map<String, dynamic>;
}
```

---

## Экраны (минимальный UX)

### A. Нет активного stake (`stake == null`)

1. Заголовок: **Copy Trading** / «Копирование бота»
2. Карточки правил: min **500**, lock **30 дней**, штраф **−14%**, «виртуально / не Binance»
3. Показать `available_earned_rsv`
4. Поле суммы + slider (500 … available)
5. Полный текст `disclaimer` + checkbox
6. CTA **Подключить**

### B. Активный stake

1. Equity / Locked / PnL (`pnl_rsv`)
2. Доля пула `pool_share` (как %)
3. Countdown из `seconds_remaining` или до `ends_at`
4. Кнопки:
   - **Докинуть RSV** → topup (ends_at **не** сдвигается)
   - **Досрочный выход** → confirm «Сгорит 14%» → `POST …/exit`
   - **Завершить** → только если `can_complete == true` → `POST …/complete`
5. Список истории (`/history`): symbol, action, master_pnl_pct, delta_rsv, дата

### C. После exit/complete

Снова экран A. `earned_rsv` обновится (unlock − penalty или полный unlock).

---

## Ошибки → тексты

| `detail.error` | HTTP | UI |
|----------------|------|-----|
| `plan_required` | 403 | «Нужна подписка PREMIUM» |
| `disclaimer_required` | 400 | «Прими условия» |
| `min_stake` | 400 | «Минимум 500 RSV» |
| `insufficient_earned` | 400 | «Недостаточно Earned RSV» |
| `already_active` | 400 | «Уже подключено» |
| `no_active_stake` | 400 | «Нет активного копирования» |
| `lock_active` | 400 | «Срок ещё не истёк — досрочный выход или жди» |

`detail` может быть объектом: `{ "error": "…", "message": "…" }`.

---

## Важно для фронта

1. **Не** показывать настройку SL/TP — копируется master as-is.
2. Top-up **не** продлевает 30 дней.
3. PnL может быть отрицательным — показывать честно.
4. После enable/topup/exit/complete — рефреш `GET /users/me` или `/users/me/copy`.
5. On-chain контракт (`BabloCopyStake.sol`) в v1 **не** вызывать — только off-chain API.

---

## Checklist фронта

- [ ] Gate по `USE_COPY_TRADING` / `copy.eligible`
- [ ] Enable с disclaimer checkbox
- [ ] Active dashboard (equity, pnl, countdown, share)
- [ ] Topup / Exit (confirm −14%) / Complete
- [ ] History list
- [ ] Обработка ошибок из таблицы выше
