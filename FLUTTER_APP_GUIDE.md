# Flutter: Bablo Trading Service — инструкция

Гайд, как на этом Python API собрать полноценное трейдинг-приложение.  
Бэкенд уже торгует, считает статистику и отдаёт REST. Flutter = кабинет клиента/админа.

**Swagger (живой сервер):** http://18.197.147.209:8000/docs  
**Base URL:** `http://18.197.147.209:8000/api/v1`  
**API version:** `2.1.0`

> Локально: `http://<host>:8000/api/v1` после `python main.py api`.

---

## 1. Цель продукта

Приложение должно уметь:

1. Показывать, **жив ли бот** и биржа.
2. Показывать **equity / балансы / открытую позицию бота**.
3. Отличать **позицию бота** от **idle** монет на кошельке.
4. Показывать **сигнал MACD** и причину.
5. Показывать **статистику эпохи** (PnL, win rate, fills).
6. Показывать **историю сделок**.
7. (Админ) стартовать / стопать бота, менять риск, adopt idle.

Telegram-канал остаётся лентой для участников. Flutter — панель управления и аналитики.

## 3. Карта экранов (MVP → полный сервис)

### MVP (обязательно)

```
┌─────────────┐  ┌──────────────┐  ┌─────────────┐  ┌────────────┐
│  Dashboard  │  │  Portfolio   │  │   Trades    │  │   Stats    │
│ health+MACD │  │ bot vs idle  │  │   history   │  │  epoch PnL │
└─────────────┘  └──────────────┘  └─────────────┘  └────────────┘
```

### Полный сервис (+ админ)

```
Settings (config) · Start/Stop/Panic · Adopt idle · Pair picker
```

| Экран          | API                                                  | Polling                  |
| -------------- | ---------------------------------------------------- | ------------------------ |
| Dashboard      | `GET /bot/status`, `GET /bot/health`                 | 5–10 сек                 |
| Portfolio      | `GET /portfolio`                                     | 10–15 сек                |
| Stats          | `GET /stats`                                         | 15–30 сек                |
| Trades         | `GET /trades?limit=50`                               | pull-to-refresh + 30 сек |
| Settings       | `GET/PATCH /config`                                  | по действию              |
| Admin controls | `POST /bot/start\|stop\|emergency-stop`              | по действию              |
| Sync / Adopt   | `POST /portfolio/reconcile`, `POST /portfolio/adopt` | по действию              |
| Pairs          | `GET /pairs?quote=USDT`                              | редко / кэш              |

---

Один `TradingRepository` — все экраны ходят через него, не дергают Dio напрямую.

---

## 5. API-контракт (что парсить)

Все денежные/qty поля приходят **строками** (`"1799.84"`) — в Flutter держи `String` или парси в `Decimal`-подобное (`package:decimal`), **не** в `double` для денег без нужды.

### `GET /bot/health`

```json
{
  "status": "ok",
  "binance_connected": true,
  "bot_running": true,
  "testnet": true,
  "error": null
}
```

UI: зелёный/красный индикатор «Биржа», бейдж `TESTNET` / `MAINNET`.

### `GET /bot/status`

Ключевые поля:

- `is_running`, `symbol`, `interval`
- `last_signal` = `BUY` | `SELL` | `HOLD`
- `last_signal_reason`, `last_macd`, `last_signal_line`, `last_price`
- `position`: `{ side, entry_price, quantity, entry_time, unrealized_pnl? }`
- `portfolio`: `{ sync_status, sync_note, idle_base, wallet_base }`
- `balances`: `{ base_asset, quote_asset, base_balance, quote_balance, price, equity }`
- `risk`: `{ is_halted, halt_reason, daily_pnl_pct, last_trade_at }`

### `GET /portfolio`

Источник правды по позиции:

| Поле                                               | Смысл                                                   |
| -------------------------------------------------- | ------------------------------------------------------- |
| `bot_position.open`                                | есть ли открытая позиция **бота**                       |
| `bot_position.quantity/entry_price/unrealized_pnl` | tracked LONG                                            |
| `wallet.base_balance`                              | всё base на бирже                                       |
| `wallet.idle_base`                                 | base **вне** позиции бота                               |
| `sync_status`                                      | `ok` / `ok_with_idle` / `idle_base` / `short_inventory` |
| `sync_note`                                        | текст для UI                                            |

**Важно для UX:**  
`idle_base > 0` и `bot_position.open == false` ≠ «открытая сделка».  
Показывать два блока: **Позиция бота** и **Кошелёк (idle)**.

### `GET /stats`

Эпоха статистики (с момента деплоя/старта эпохи, не вся история Binance):

- `epoch_started_at`, `baseline_equity`
- `current_equity`, `equity_pnl`, `equity_pnl_pct`
- `realized_pnl`, `unrealized_pnl`
- `total_fills`, `buys`, `sells`
- `closed_trades`, `wins`, `losses`, `win_rate_pct`
- `includes_pre_epoch_exchange_history: false` — покажи disclaimer в UI

### `GET /trades?limit=50&symbol=ETHUSDT`

Элемент:

```json
{
  "id": "bot_...",
  "symbol": "ETHUSDT",
  "side": "BUY",
  "quantity": "1.01",
  "price": "1750.62",
  "status": "FILLED",
  "created_at": "2026-07-11T...",
  "order_id": 123,
  "reason": "Bullish MACD crossover",
  "realized_pnl": null,
  "entry_price": null
}
```

На `SELL` часто есть `realized_pnl` и `entry_price`.

### `GET /config` / `PATCH /config`

```json
{
  "symbol": "ETHUSDT",
  "interval": "15m",
  "macd_fast": 5,
  "macd_slow": 13,
  "macd_signal": 2,
  "position_size_pct": 25,
  "stop_loss_pct": 1.5,
  "take_profit_pct": 2,
  "max_daily_loss_pct": 10,
  "trade_cooldown_minutes": 30,
  "use_crossover_signals": true,
  "require_macd_above_zero_for_buy": false
}
```

`PATCH` — только изменённые поля (`null` не слать).

### `POST /bot/start`

```json
{ "symbol": "ETHUSDT", "interval": "15m" }
```

Допустимые интервалы Binance:  
`1m 3m 5m 15m 30m 1h 2h 4h 6h 8h 12h 1d` — **не `3h`**.

### Admin portfolio

- `POST /portfolio/reconcile` — сверка
- `POST /portfolio/adopt` — весь wallet base → tracked LONG по рынку (опасно, только админ + confirm dialog)

---

## 6. Dio-клиент (шаблон)

```dart
// lib/core/dio_client.dart
import 'package:dio/dio.dart';

Dio createDio(String baseUrl) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl, // e.g. http://18.197.147.209:8000/api/v1
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  return dio;
}
```

`.env` / `--dart-define`:

```
API_BASE_URL=http://18.197.147.209:8000/api/v1
```

На iOS Simulator/Android emulator:

- Android emulator → `http://10.0.2.2:8000/api/v1` только если API на той же машине.
- Для AWS IP — обычный `http://18.197.147.209:8000/api/v1`.
- Android: разрешить cleartext HTTP в `AndroidManifest` / network security config (пока нет HTTPS).
- iOS: `NSAppTransportSecurity` → `NSAllowsArbitraryLoads` или exception для IP (пока HTTP).

---

## 7. Пример репозитория

```dart
class TradingRepository {
  TradingRepository(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> health() async =>
      (await _dio.get('/bot/health')).data as Map<String, dynamic>;

  Future<Map<String, dynamic>> status() async =>
      (await _dio.get('/bot/status')).data as Map<String, dynamic>;

  Future<Map<String, dynamic>> portfolio() async =>
      (await _dio.get('/portfolio')).data as Map<String, dynamic>;

  Future<Map<String, dynamic>> stats() async =>
      (await _dio.get('/stats')).data as Map<String, dynamic>;

  Future<List<dynamic>> trades({int limit = 50, String? symbol}) async {
    final res = await _dio.get('/trades', queryParameters: {
      'limit': limit,
      if (symbol != null) 'symbol': symbol,
    });
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getConfig() async =>
      (await _dio.get('/config')).data as Map<String, dynamic>;

  Future<Map<String, dynamic>> patchConfig(Map<String, dynamic> body) async =>
      (await _dio.patch('/config', data: body)).data as Map<String, dynamic>;

  Future<Map<String, dynamic>> start({
    required String symbol,
    required String interval,
  }) async =>
      (await _dio.post('/bot/start', data: {
        'symbol': symbol,
        'interval': interval,
      })).data as Map<String, dynamic>;

  Future<Map<String, dynamic>> stop() async =>
      (await _dio.post('/bot/stop')).data as Map<String, dynamic>;

  Future<Map<String, dynamic>> panic() async =>
      (await _dio.post('/bot/emergency-stop')).data as Map<String, dynamic>;

  Future<Map<String, dynamic>> reconcile() async =>
      (await _dio.post('/portfolio/reconcile')).data as Map<String, dynamic>;

  Future<Map<String, dynamic>> adopt() async =>
      (await _dio.post('/portfolio/adopt')).data as Map<String, dynamic>;
}
```

После стабилизации моделей замени `Map` на freezed-классы.

---

## 8. UI-требования по экранам

### Dashboard

1. Шапка: `TESTNET` / `MAINNET` + online/offline (health).
2. Крупно: **Equity** + дневной `daily_pnl_pct`.
3. Пара / интервал / Running chip.
4. Карточка сигнала: BUY/SELL/HOLD + reason + MACD / Signal.
5. Мини-блок позиции: open? qty @ entry · uPnL.
6. Если `sync_status == idle_base` — жёлтый баннер: «На кошельке есть ETH вне позиции бота».

### Portfolio

Две колонки/секции:

- **Bot position** — только tracked.
- **Wallet** — base, quote, idle_base, equity.
- Badge sync + `sync_note`.
- Админ: кнопки Reconcile / Adopt (с Confirm).

### Stats

- Дата старта эпохи.
- Baseline vs current equity, Δ.
- Realized / Unrealized.
- Win rate, W/L, fills.
- Текст: «История Binance до эпохи не входит».

### Trades

Список: время, side color, qty, price, reason, pnl если есть.  
Pull-to-refresh.

### Settings (admin)

Форма config + Save → PATCH.  
Валидация интервала (dropdown из whitelist Binance).

### Admin bar

Start (symbol+interval) / Stop / Panic (красный, double confirm).

---

## 9. Состояния и ошибки

| HTTP | Когда                          | UI                        |
| ---- | ------------------------------ | ------------------------- |
| 200  | ок                             | показать данные           |
| 400  | bad symbol / adopt без баланса | snackbar `detail`         |
| 503  | Binance недоступен             | «Биржа недоступна», retry |

`detail` в ошибках FastAPI часто строка или объект — читай `response.data['detail']`.

Оффлайн: кэш последнего status/stats (optional `shared_preferences`).

---

## 10. Безопасность (обязательно до «настоящих» денег)

Сейчас API **открыт** по IP. Для полноценного сервиса:

1. **HTTPS** (nginx + Let’s Encrypt / Cloudflare Tunnel).
2. **API key / JWT** на бэкенде (добавим в Python позже) + хранение в `flutter_secure_storage`.
3. Роли: `viewer` (read-only) / `admin` (start/stop/config/adopt).
4. Не светить ключи Binance во Flutter — только ваш backend.
5. Panic и Adopt — только admin + confirm.

Пока testnet — можно шить base URL и читать всё; write-эндпоинты спрятать за «Admin PIN» локально как временную меру.

---

## 11. Порядок разработки (спринты)

### Sprint 1 — Read-only кабинет

- [ ] Dio + base URL
- [ ] Dashboard (health + status)
- [ ] Portfolio
- [ ] Stats
- [ ] Trades list
- [ ] Polling / pull-to-refresh

### Sprint 2 — Admin

- [ ] Settings PATCH
- [ ] Start / Stop / Panic
- [ ] Reconcile / Adopt
- [ ] Pair picker из `/pairs`

### Sprint 3 — Продукт

- [ ] Auth + HTTPS
- [ ] Push (FCM) на сделки (или polling + local notification)
- [ ] Простой график equity по stats/trades
- [ ] Dark/light, локализация RU/EN
- [ ] App icons, testnet watermark

### Sprint 4 — Сервис

- [ ] Мультипользовательский режим (если появится на бэке)
- [ ] Экспорт CSV сделок
- [ ] Онбординг «что такое idle / эпоха статистики»

---

## 12. Чеклист «приложение = полноценный трейд-сервис»

Считать готовым, когда:

- [ ] Видно running / halted / testnet
- [ ] Видно equity и PnL эпохи
- [ ] Позиция бота и idle не путаются
- [ ] История сделок с причинами и PnL
- [ ] Админ может безопасно стартовать/стопать
- [ ] Ошибки Binance/сети понятны пользователю
- [ ] Нет прямого доступа Flutter → Binance keys
- [ ] Канал Telegram и приложение показывают согласованные цифры

---

## 13. Быстрая проверка API перед кодом

```bash
curl -s http://18.197.147.209:8000/api/v1/bot/health | jq
curl -s http://18.197.147.209:8000/api/v1/bot/status | jq
curl -s http://18.197.147.209:8000/api/v1/portfolio | jq
curl -s http://18.197.147.209:8000/api/v1/stats | jq
curl -s 'http://18.197.147.209:8000/api/v1/trades?limit=5' | jq
curl -s http://18.197.147.209:8000/api/v1/config | jq
```

Или открой http://18.197.147.209:8000/docs и прогони Try it out.

---

## 14. Чего пока нет на бэке (не жди в Flutter)

- WebSocket стрим в приложение (только REST polling)
- Auth / API keys для клиентов
- Свечной график с сервера (можно позже `/klines` или брать публичный Binance)
- Мультиаккаунт / мультибот в одном API
- Депозит/вывод (и не надо — только spot-торговля через бота)

Если чего-то из этого не хватает для экрана — сначала дописываем Python, потом Flutter.

---

## 15. Связь с репо

- Backend: https://github.com/RomanDevelop/macd-trading-bot
- Этот файл: `docs/FLUTTER_APP_GUIDE.md`
- Живой Swagger: `/docs` на сервере бота

Когда Sprint 1 готов — можно подключать к тому же API, что уже кормит Telegram-канал.
