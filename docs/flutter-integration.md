# Flutter Mini App — инструкция для Cursor

> Документ для **отдельного Flutter-репозитория** (`bablo-bot.web.app`).
> Скопируй в Flutter-проект как `docs/BACKEND_INTEGRATION.md` или положи в `.cursor/rules/` как контекст для агента.

**Backend repo:** `macd-trading-bot` (FastAPI)  
**Статус:** Bablo User Platform **Phase 1 задеплоена** на EC2 (2026-08-28)  
**Полный каталог API:** [`api.json`](./api.json) в backend-репо

---

## 1. Что уже сделано на backend (важно для Flutter)

| Готово | Детали |
|--------|--------|
| Telegram auth | `POST /api/v1/auth/telegram` — проверка `initData`, выдача JWT |
| Identity | Внутренний `BabloUser.id` (UUID), не Telegram id |
| Sessions | Access token (~15 мин) + refresh token (~30 дней), rotation при refresh |
| Bootstrap | Один объект с user, subscription, stats, rewards, wallet, referral, permissions |
| Profile API | `GET/PATCH /users/me/profile`, `/preferences` |
| DB | SQLite на EC2, Angela users/wallets/rewards уже импортированы |
| CORS | `*` (можно сузить до Firebase origin) |
| Mini App entry | `@Artem_Bablo_Bot` → BotFather Menu Button → `https://bablo-bot.web.app` |
| Marketplace button | Inline `web_app` (не plain URL) в trade channel |

**Не сделано (Phase 2+):** per-user trading accounts, user-scoped bot API, подключение биржи из Mini App.

**Trading endpoints (`/bot/*`, `/portfolio`, `/stats`) — глобальные**, не привязаны к залогиненному user. Mini App может их читать для дашборда «общего бота», но это не personal PnL.

---

## 2. URLs и конфиг Flutter

```bash
# Production (обязательно HTTPS)
flutter build web --dart-define=API_BASE_URL=https://api.bablochatik.com/api/v1

# Local dev (backend на :8000)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

В коде:

```dart
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://api.bablochatik.com/api/v1',
);
```

**Swagger (для отладки):** https://api.bablochatik.com/docs

---

## 3. Главный flow (обязательный)

```text
Telegram открывает Mini App (bablo-bot.web.app)
        ↓
Flutter Web читает Telegram.WebApp.initData  (строка query-string)
        ↓
POST /api/v1/auth/telegram  { "init_data": "..." }
        ↓
Ответ: access_token, refresh_token, bootstrap
        ↓
Сохранить tokens (secure storage / localStorage для web)
        ↓
Все /users/me/* → Header: Authorization: Bearer <access_token>
        ↓
При 401 → POST /auth/refresh → сохранить новую пару tokens → retry
        ↓
Logout → POST /auth/logout { refresh_token } + очистить storage
```

### Auth request

```http
POST /api/v1/auth/telegram
Content-Type: application/json

{
  "init_data": "<Telegram.WebApp.initData>",
  "device_name": "Chrome on macOS",
  "platform": "web",
  "app_version": "1.0.0"
}
```

### Auth response

```json
{
  "access_token": "eyJ...",
  "refresh_token": "...",
  "token_type": "bearer",
  "access_expires_at": "2026-08-28T16:20:00+00:00",
  "session_id": "uuid",
  "bootstrap": { "...": "см. раздел 5" }
}
```

### Refresh

```http
POST /api/v1/auth/refresh
Content-Type: application/json

{ "refresh_token": "..." }
```

Возвращает **новую** пару tokens (старый refresh invalid). Всегда перезаписывай оба.

### Logout

```http
POST /api/v1/auth/logout
Content-Type: application/json

{ "refresh_token": "..." }
```

Ответ: `204 No Content`.

---

## 4. Telegram Web (Flutter Web Mini App)

### index.html

Подключи SDK **до** Flutter:

```html
<script src="https://telegram.org/js/telegram-web-app.js"></script>
```

### Dart interop (web)

```dart
import 'dart:js_util' as js_util;
import 'package:web/web.dart' as web;

String? readTelegramInitData() {
  final tg = web.window.telegramWebApp;
  if (tg == null) return null;
  final initData = js_util.getProperty(tg, 'initData') as String?;
  return initData?.isNotEmpty == true ? initData : null;
}

void expandTelegramApp() {
  final tg = web.window.telegramWebApp;
  if (tg == null) return;
  js_util.callMethod(tg, 'ready', []);
  js_util.callMethod(tg, 'expand', []);
}
```

> Для `package:web` может понадобиться extension на `window` — или используй `dart:js_interop` / `telegram_web_app` pub package.

### Важно

- **Не** валидируй `initData` на клиенте — только отправляй на backend.
- `initData` живёт **~5 минут** (`TELEGRAM_INIT_DATA_MAX_AGE_SECONDS=300`). Логин сразу при старте приложения.
- Бот для auth: **`@Artem_Bablo_Bot`** (тот же, что Menu Button). Backend берёт token из `TELEGRAM_BOT_TOKEN`.
- Referral: если пользователь зашёл по ссылке `?startapp=ref_XXXX` или `start_param` в initData — backend сам привяжет referral при первом login.

### Вне Telegram (dev)

В браузере без Telegram `initData` будет пустым. Варианты:
- Mock auth screen «Open in Telegram»
- Dev-only endpoint **не существует** — тестируй через Telegram Desktop/Web или ngrok + BotFather test Mini App URL

---

## 5. Bootstrap schema (`GET /users/me` = то же, что в auth)

```json
{
  "user": {
    "id": "uuid",
    "status": "ACTIVE",
    "role": "USER",
    "display_name": "Roman",
    "avatar_url": "https://...",
    "locale": "ru",
    "timezone": null,
    "created_at": "2026-08-28T...",
    "last_login_at": "2026-08-28T..."
  },
  "telegram": {
    "telegram_user_id": "123456789",
    "username": "roman_dev"
  },
  "subscription": {
    "plan": "FREE",
    "status": "ACTIVE",
    "expires_at": null,
    "limits": { "max_connected_accounts": 0 }
  },
  "stats": {
    "points": 0,
    "lifetime_points": 0,
    "level": 1,
    "rating": 0.0,
    "activity_score": 0.0,
    "rank": null
  },
  "rewards": {
    "earned_rsv": 5.0,
    "pending_rsv": 0.0,
    "paid_rsv": 5.0
  },
  "wallet": {
    "network": "polygon",
    "address": "0x...",
    "verified": false
  },
  "referral": {
    "code": "ABC123",
    "link": "https://t.me/Artem_Bablo_Bot/app?startapp=ref_ABC123",
    "invited_count": 0,
    "active_invited_count": 0
  },
  "trading": {
    "accounts_count": 0,
    "active_accounts": 0,
    "total_pnl": null
  },
  "permissions": [
    "VIEW_TRADING_STATS",
    "USE_ANGELA"
  ]
}
```

`wallet` может быть `null`, если кошелёк не привязан.

---

## 6. Authenticated endpoints (Bearer required)

| Method | Path | Назначение |
|--------|------|------------|
| GET | `/users/me` | Полный bootstrap |
| GET | `/users/me/profile` | Профиль + telegram fields |
| PATCH | `/users/me/profile` | `{ display_name?, custom_avatar_url?, bio?, locale?, timezone? }` |
| GET | `/users/me/subscription` | Только subscription block |
| GET | `/users/me/stats` | Только stats |
| GET | `/users/me/rewards` | RSV balances |
| GET | `/users/me/wallets` | `{ wallets: [{ id, network, address, verified, is_primary }] }` |
| GET | `/users/me/referral` | Referral code + stats |
| GET | `/users/me/preferences` | Notification/privacy flags |
| PATCH | `/users/me/preferences` | Partial update booleans |

Header для всех:

```http
Authorization: Bearer <access_token>
```

---

## 7. Публичные endpoints (можно без auth)

Для дашборда «живого бота» (общие данные):

| Method | Path | Описание |
|--------|------|----------|
| GET | `/bot/health` | Binance connectivity |
| GET | `/bot/status` | Позиция, scanner, signals |
| GET | `/stats` | Epoch PnL, win rate |
| GET | `/portfolio` | Portfolio snapshot |
| GET | `/trades?limit=50` | История сделок |
| GET | `/articles`, `/articles/latest` | Bablo Daily |

**Не вызывай из Mini App без необходимости:** `POST /bot/start`, `/stop`, `/emergency-stop` — это ops/admin.

---

## 8. Ошибки API

FastAPI возвращает:

```json
{
  "detail": {
    "error": "invalid_signature",
    "message": "init_data signature is invalid"
  }
}
```

Или строку для простых случаев: `{ "detail": "not_found" }`.

| HTTP | Когда |
|------|-------|
| 400 | Пустой/битый initData |
| 401 | Просрочен access/refresh, invalid token |
| 403 | Daily admin only |
| 503 | Binance down, platform DB init fail |

**Flutter retry policy:**
- `401` на `/users/*` → refresh → retry once → иначе logout + показать «Open in Telegram»
- `401` на `/auth/telegram` → показать ошибку входа (не refresh)

---

## 9. Рекомендуемая структура Flutter-кода

```
lib/
├── core/
│   ├── config/api_config.dart       # API_BASE_URL
│   ├── network/api_client.dart      # Dio/http + interceptors
│   └── auth/token_storage.dart      # access + refresh + expires_at
├── features/
│   ├── auth/
│   │   ├── auth_repository.dart     # login, refresh, logout
│   │   └── auth_bloc.dart           # или Riverpod notifier
│   ├── profile/
│   └── dashboard/                   # bot status, stats (public API)
└── main.dart                        # bootstrap: init Telegram → auth → Home
```

### ApiClient interceptor (псевдокод)

```dart
onRequest: add Authorization if accessToken != null
onError 401:
  if path starts with /auth/ → pass through
  else await refreshTokens()
  else clear session → AuthRequired
```

### Token storage (web)

- `access_token`, `refresh_token`, `access_expires_at`, `session_id`
- Proactive refresh за 1–2 мин до `access_expires_at`
- Refresh token храни persistently (localStorage / shared_preferences)

---

## 10. UI/UX для Mini App

1. **Splash** → `Telegram.WebApp.ready()` + `expand()`
2. **Auth gate** — если нет valid access token → login via initData
3. **Home** — данные из `bootstrap` (не дублируй 6 запросов на старте)
4. **Profile screen** — PATCH profile/preferences по необходимости
5. **Referral** — показывай `bootstrap.referral.link`, шаринг через `Telegram.WebApp.openTelegramLink`
6. **Theme** — `Telegram.WebApp.themeParams` для dark/light
7. **Back button** — `Telegram.WebApp.BackButton` для nested routes

---

## 11. Что НЕ делать

- ❌ Не использовать Telegram user id как primary key в Flutter state — только `bootstrap.user.id` (UUID)
- ❌ Не хранить initData как session — одноразовый login
- ❌ Не считать `/bot/status` personal account пользователя
- ❌ Не hardcode HTTP API — только HTTPS в prod
- ❌ Не добавлять свой JWT secret на клиент

---

## 12. Cursor prompt для Flutter-репо

Скопируй в чат Cursor во Flutter-проекте:

```text
Implement Bablo Telegram Mini App auth against production API.

Backend Phase 1 is live:
- Base URL: https://api.bablochatik.com/api/v1
- Login: POST /auth/telegram with Telegram.WebApp.initData
- Store access_token + refresh_token, Bearer on /users/me/*
- Refresh on 401 via POST /auth/refresh (token rotation)
- Use bootstrap from auth response for home dashboard
- Include telegram-web-app.js in web/index.html
- Bot: @Artem_Bablo_Bot

Full backend doc: (paste docs/flutter-integration.md or link)
API catalog: auth + users/me endpoints in backend docs/api.json

Do NOT implement per-user trading yet (Phase 2).
Public bot endpoints (/bot/status, /stats) are global, not user-scoped.
```

---

## 13. Чеклист Phase 1 (Flutter)

- [ ] `telegram-web-app.js` в `web/index.html`
- [ ] `--dart-define=API_BASE_URL=https://api.bablochatik.com/api/v1`
- [ ] Auth on startup: initData → `/auth/telegram`
- [ ] Token storage + refresh interceptor
- [ ] Home screen from `bootstrap`
- [ ] Profile edit → `PATCH /users/me/profile`
- [ ] Referral share from `bootstrap.referral.link`
- [ ] Graceful fallback outside Telegram
- [ ] Firebase deploy → проверить открытие из @Artem_Bablo_Bot Menu Button

---

## 14. Связанные документы (backend repo)

- [`docs/api.json`](./api.json) — все 33 endpoint
- [`docs/bablo-user-platform-v2.md`](./bablo-user-platform-v2.md) — полная спека платформы
- [`README.md`](../README.md) — deploy, env vars
