# Bablo Trading (Flutter)

Flutter-кабинет **Bablo Community**: Telegram Mini App + web dashboard для MACD trading bot, RSV rewards, контента и сервисов.

| | |
|---|---|
| **Web / Mini App** | https://bablo-bot.web.app |
| **API** | https://api.bablochatik.com/api/v1 |
| **Swagger** | https://api.bablochatik.com/docs |
| **Telegram bot** | `@Artem_Bablo_Bot` → Menu Button → Mini App |
| **Firebase** | project `bablo-bot` (Hosting, Spark) |

---

## Что внутри

### Trading (глобальный бот — Phase 1)

Эндпоинты `/bot/*`, `/portfolio`, `/stats` **не привязаны к user** — это данные общего бота, не personal PnL.

| Экран | Назначение |
|-------|------------|
| **Home** | Баланс бота, позиция, scanner, BABLO DAILY, user bootstrap (RSV) |
| **Chart** | Свечи + Alligator / MACD |
| **Market** | Рынок |
| **History** | История сделок бота |
| **Stats** | Epoch PnL (кнопка в AppBar Home) |
| **Admin** | Start / Stop / config |

### User Platform (Phase 1 — live)

| Функция | Детали |
|---------|--------|
| **Telegram auth** | `POST /auth/telegram` с `Telegram.WebApp.initData` |
| **JWT sessions** | access (~15 мин) + refresh (~30 дней), rotation |
| **Bootstrap** | user, subscription, stats, rewards, wallet, referral |
| **Profile** | RSV balance, referral share, sign in/out |
| **Microloans** | RSV advance tiers (UI + local apply) |

Phase 2 (ещё нет): per-user trading accounts, user-scoped bot API, on-chain RSV payout.

### Меню (sidebar)

Courses · Currency Exchange · Microloans · Profile · Signals · AI · Temki · Premium leisure · Partner · Subscriptions · About / Help / Documents

---

## Auth flow (Mini App)

```text
Telegram открывает bablo-bot.web.app
        ↓
telegram-web-app.js → initData
        ↓
POST /api/v1/auth/telegram
        ↓
access_token + refresh_token + bootstrap
        ↓
Bearer на /users/me/*
        ↓
401 → POST /auth/refresh → retry
```

- SDK подключён в `web/index.html` **до** Flutter bootstrap.
- Вне Telegram: guest mode + кнопка «Open @Artem_Bablo_Bot».
- Полная спека: [`docs/flutter-integration.md`](docs/flutter-integration.md).

---

## Требования

- Flutter через **FVM** (SDK `3.44.0`, см. `.fvm/fvm_config.json`)
- Node.js **≥ 20** (Firebase CLI)
- Аккаунт Google с доступом к Firebase project `bablo-bot`

---

## Локальный запуск

```bash
cd "/Users/anymacstore/Flutter development/crypto_trading_bot"

fvm flutter pub get
.fvm/flutter_sdk/bin/flutter run -d chrome \
  --dart-define=API_BASE_URL=https://api.bablochatik.com/api/v1
```

Production API задан по умолчанию в `lib/core/constants/api_constants.dart`.  
Локальный backend:

```bash
.fvm/flutter_sdk/bin/flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

> Auth через Telegram работает только внутри Mini App. В Chrome без Telegram — guest / Profile sign-in stub.

---

## Web → Firebase Hosting

### Сборка

```bash
.fvm/flutter_sdk/bin/flutter build web --release \
  --dart-define=API_BASE_URL=https://api.bablochatik.com/api/v1
```

### Деплой

```bash
nvm use 20

# если токен протух:
firebase login --reauth --no-localhost

firebase deploy --only hosting --project bablo-bot
```

Альтернатива через npx (если кэш npm сломался — см. troubleshooting):

```bash
rm -rf ~/.npm/_npx/ba4f1959e38407b5   # при ENOTEMPTY
npx --yes firebase-tools@latest deploy --only hosting --project bablo-bot
```

Конфиг: `firebase.json` → `public: build/web`, SPA rewrite на `index.html`.

После деплоя: https://bablo-bot.web.app

> Telegram WebView кэширует Mini App — после деплоя закрой и открой бота заново.

---

## Архитектура

**MWWM**: Widget → WidgetModel → Repository → DataProvider → Dio.

```
lib/
  main.dart
  app/                    # AuthInitializer
  core/
    auth/                 # AuthSession, TokenStorage
    network/              # NetworkClient, AuthInterceptor
    telegram/             # WebApp initData (web + stub)
    theme/ navigation/ errors/ constants/
  data_management/        # AppServices, DataManager
  features/
    auth/                 # models, AuthRepository
    trading/              # dashboard, chart, daily, courses, …
  components/
web/
  index.html              # telegram-web-app.js + Flutter
firebase.json
```

Подробнее: `ARCHITECTURE_GUIDE.md`.

---

## Данные и кэш

| Слой | Источник |
|------|----------|
| Bot status / trades / config | `TradingDataProvider` → `/bot/*`, `/trades`, … |
| User profile / RSV | `AuthRepository` → `/users/me` (Bearer) |
| Свечи (Chart) | Coinbase / OKX + `CandleCache` (на web без CORS Binance) |
| BABLO DAILY | `DailyRepository` → `/articles` |
| Tokens / bootstrap | `TokenStorage` (`shared_preferences`) |

---

## Telegram

| Способ | Как |
|--------|-----|
| **Mini App** | BotFather → `@Artem_Bablo_Bot` → Menu Button → `https://bablo-bot.web.app` |
| **Inline web_app** | Кнопка под постами в trade channel (backend) |

Подписчики **канала** не видят Menu Button — только посты или прямую ссылку на бота.

---

## Troubleshooting

| Проблема | Решение |
|----------|---------|
| `Authentication Error` при deploy | `firebase login --reauth --no-localhost` |
| `npm ENOTEMPTY` при npx | `rm -rf ~/.npm/_npx/...` или глобальный `firebase deploy` |
| Mixed Content | API только HTTPS (`api.bablochatik.com`) |
| Mini App не логинится | Открыть через бота, не напрямую URL; initData живёт ~5 мин |
| Медленная первая загрузка | Flutter Web ~40–50 MB — норм на слабом инете, повторное быстрее |
| Старая версия в Telegram | Закрыть Mini App полностью и открыть снова |

---

## Документация

| Файл | Содержание |
|------|------------|
| [`docs/flutter-integration.md`](docs/flutter-integration.md) | Backend Phase 1, auth, bootstrap, endpoints |
| `ARCHITECTURE_GUIDE.md` | MWWM, слои, DI |
| `api.json` | OpenAPI snapshot (bot endpoints) |

---

## Важно

- Сайт и API только **HTTPS**.
- CORS на backend должен разрешать `https://bablo-bot.web.app`.
- Не коммить bot tokens, JWT secrets, Firebase auth codes.
- Primary user id в клиенте — `bootstrap.user.id` (UUID), не Telegram id.
