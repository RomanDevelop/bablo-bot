# Bablo Trading Bot (Flutter)

Flutter-кабинет для MACD trading bot (Binance spot).  
Управление и аналитика бота: статус, equity, график, портфель, сделки, admin.

| | |
|---|---|
| **Web** | https://bablo-bot.web.app |
| **API** | https://api.bablochatik.com/api/v1 |
| **Swagger** | https://api.bablochatik.com/docs |
| **Telegram** | `@Artem_Bablo_Bot` → кнопка **Marketplace** |
| **Firebase** | project `bablo-bot` (Hosting, Spark) |

---

## Экраны

| Tab | Назначение |
|-----|------------|
| **Home** | Equity, MACD-сигнал, позиция бота, health / TESTNET |
| **Chart** | Свечи + MACD 5/13/2, маркеры entry/crossover |
| **Portfolio** | Bot position vs idle wallet, Reconcile / Adopt |
| **Trades** | История сделок |
| **Admin** | Start / Stop / Panic, PATCH config |
| **Stats** | Эпоха PnL (кнопка в AppBar Home) |

Архитектура: **MWWM** (Widget → WidgetModel → Repository → DataProvider → Dio).  
См. `ARCHITECTURE_GUIDE.md`.

---

## Требования

- Flutter через **FVM** (SDK `3.44.0`, см. `.fvm/fvm_config.json`)
- Node.js **≥ 20** (для Firebase CLI)
- Для Android/iOS — стандартный Flutter toolchain

---

## Локальный запуск

```bash
cd "/Users/anymacstore/Flutter development/crypto_trading_bot"

fvm flutter pub get
fvm flutter run -d chrome
# или
.fvm/flutter_sdk/bin/flutter run -d chrome
```

API по умолчанию: `https://api.bablochatik.com/api/v1`  
(`lib/core/constants/api_constants.dart`)

Другой backend:

```bash
fvm flutter run -d chrome \
  --dart-define=API_BASE_URL=https://api.bablochatik.com/api/v1
```

### Android APK

```bash
fvm flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.bablochatik.com/api/v1
```

APK: `build/app/outputs/flutter-apk/app-release.apk`

---

## Web → Firebase Hosting

### Сборка

```bash
nvm use 20   # обязательно Node ≥ 20

.fvm/flutter_sdk/bin/flutter build web --release \
  --dart-define=API_BASE_URL=https://api.bablochatik.com/api/v1
```

### Деплой

```bash
npx --yes firebase-tools@latest login          # или login --reauth
npx --yes firebase-tools@latest deploy --only hosting --project bablo-bot
```

Конфиг: `firebase.json` → `public: build/web`, SPA rewrite на `index.html`.  
После деплоя: https://bablo-bot.web.app

> Telegram Mini App / Marketplace кэширует WebView — после деплоя закрой и открой бота заново.

---

## Данные и кэш

- **Bot API** (status, portfolio, trades, config…) — Dio → `TradingDataProvider` + `ApiCache` (`shared_preferences`)
- **Свечи (Chart)** — публичные биржи (Coinbase / OKX; на native ещё Binance/Kraken) + `CandleCache`
- На **Web** Binance/Kraken часто режет CORS → приоритет Coinbase/OKX и кэш
- Опционально backend: `GET /api/v1/market/klines` (см. обсуждения / backend docs)

---

## Telegram

| Способ | Где | Как |
|--------|-----|-----|
| **Menu Button Marketplace** | ЛС с `@Artem_Bablo_Bot` | BotFather → Menu Button → `https://bablo-bot.web.app` |
| **Кнопка под постами** | Канал Bablo Chatik | Backend: `InlineKeyboardButton(url=...)` |

Подписчики **канала** не видят Menu Button — только посты.  
Кабинет: открыть бота / ссылку / кнопку под постом.

Auth через Telegram (JWT) — план в `PYTHON_TELEGRAM_AUTH_GUIDE.md` (backend).

---

## Структура проекта

```
lib/
  main.dart
  core/                 # theme, network, MWWM, errors, constants
  data_management/      # DataManager (DI)
  components/           # UI chips, brand, cards
  features/trading/
    cache/              # ApiCache
    data_providers/     # TradingDataProvider
    market/             # candles, MACD, CandleCache
    repositories/
    pages/              # dashboard, chart, portfolio, trades, settings, stats, shell
    dto/ models/
web/
  config.json           # apiBaseUrl для hosted web (если используется)
firebase.json
.firebaserc             # default project: bablo-bot
```

---

## Документация

| Файл | Содержание |
|------|------------|
| `ARCHITECTURE_GUIDE.md` | MWWM, слои, DI |
| `FLUTTER_APP_GUIDE.md` | Продукт / API-контракт для клиента |
| `PYTHON_TELEGRAM_AUTH_GUIDE.md` | ТЗ: Telegram Login → JWT → roles (backend) |

---

## Важно

- Сайт на **HTTPS** (`bablo-bot.web.app`) → API тоже должен быть **HTTPS** (`api.bablochatik.com`). HTTP с Firebase Web блокируется (Mixed Content).
- CORS на backend должен разрешать `https://bablo-bot.web.app`.
- Не коммить bot tokens / secrets в git.
