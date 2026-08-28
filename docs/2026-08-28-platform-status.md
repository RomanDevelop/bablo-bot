# Bablo Platform — статус на 28.08.2026

> Снимок после деплоя Phase 1: Telegram Mini App auth + user bootstrap на production.  
> Web: https://bablo-bot.web.app · API: https://api.bablochatik.com/api/v1 · Bot: `@Artem_Bablo_Bot`

---

## Сделано (Flutter + backend Phase 1)

### Telegram Mini App auth

- [x] `telegram-web-app.js` в `web/index.html` (до Flutter bootstrap)
- [x] Чтение `Telegram.WebApp.initData` на Web
- [x] `POST /auth/telegram` → `access_token` + `refresh_token` + `bootstrap`
- [x] Хранение tokens в `SharedPreferences` (`TokenStorage`)
- [x] Bearer на все `/users/me/*`
- [x] Refresh на 401 через `POST /auth/refresh` (token rotation)
- [x] Proactive refresh за ~2 мин до expiry access token
- [x] Logout: `POST /auth/logout` + очистка storage
- [x] Auth при старте приложения (`AuthInitializer`)
- [x] Guest mode вне Telegram + CTA «Open @Artem_Bablo_Bot»
- [x] Production deploy на Firebase Hosting (28.08.2026)

### User bootstrap (данные с API)

После login клиент получает один объект `bootstrap` (то же, что `GET /users/me`):

| Блок | Поля |
|------|------|
| **user** | `id` (UUID), `display_name`, `avatar_url`, `locale`, `timezone`, `role`, `status`, `created_at`, `last_login_at` |
| **telegram** | `telegram_user_id`, `username` |
| **subscription** | `plan`, `status`, `expires_at`, `limits.max_connected_accounts` |
| **stats** | `points`, `lifetime_points`, `level`, `rating`, `activity_score`, `rank` |
| **rewards** | `earned_rsv`, `pending_rsv`, `paid_rsv` |
| **wallet** | `network`, `address`, `verified` (или `null`) |
| **referral** | `code`, `link`, `invited_count`, `active_invited_count` |
| **trading** | `accounts_count`, `active_accounts`, `total_pnl` |
| **permissions** | массив строк, напр. `VIEW_TRADING_STATS`, `USE_ANGELA` |

> Primary key в клиенте — **`bootstrap.user.id` (UUID)**, не Telegram user id.

### UI — что уже показываем

| Экран / зона | Что видит user |
|--------------|----------------|
| **Home — bootstrap strip** | имя, RSV paid, plan, level, referrals → tap → Profile |
| **Home — trading block** | глобальный бот: balance, position, scanner (сворачивается) |
| **Home — BABLO DAILY** | карусель (3) + горизонтальные картоchки, фильтры категорий |
| **Profile (auth)** | имя, @username, plan, RSV paid/earned, referral share, level/points/rating, sign out |
| **Profile (guest)** | Sign in / Open in Telegram |
| **Microloans** | tiers RSV advance; apply требует auth; заявка в Telegram |
| **Sidebar** | Microloans, Profile, Exchange, Courses, Signals, Temki, Premium, … |

### Trading / публичные endpoints (глобальные, не user-scoped)

- [x] `/bot/health`, `/bot/status` — дашборд «живого бота»
- [x] `/stats`, `/portfolio`, `/trades` — аналитика общего бота
- [x] `/articles` — BABLO DAILY
- [x] Admin: start/stop/config (Settings)

**Важно:** equity / position / scanner на Home — это **не personal PnL пользователя**.

### Прочий функционал кабинета

- [x] Midnight Signal theme (dark navy)
- [x] Courses (карусель менторов + detail)
- [x] Currency Exchange (RSV swap UI → Telegram)
- [x] Temki / mutki marketplace
- [x] Signals (demo feed)
- [x] Stats, Chart, Portfolio, Trades, History
- [x] About, Help, Documents, Partner, Subscriptions
- [x] PWA icons / favicon Bablo branding
- [x] README + `docs/flutter-integration.md` обновлены

---

## Предстоит (Phase 2+)

### Backend / продукт

- [ ] Per-user trading accounts (привязка биржи к user)
- [ ] User-scoped bot API (personal PnL, personal positions)
- [ ] On-chain RSV payout на crypto wallet пользователя
- [ ] Microloans backend (контракт, квоты, enforcement referrals)
- [ ] KYC / wallet verification flow
- [ ] Subscription billing / entitlements из API (Premium gates)
- [ ] Angela / rewards automation полностью через API

### Flutter UI (есть API, нет экрана)

- [ ] `PATCH /users/me/profile` — редактирование display_name, bio, locale, avatar
- [ ] `GET/PATCH /users/me/preferences` — notifications, privacy flags
- [ ] `GET /users/me/wallets` — список кошельков, primary wallet
- [ ] `GET /users/me/subscription` — отдельный экран тарифа / limits
- [ ] Avatar из `bootstrap.user.avatar_url`
- [ ] Wallet address + verified badge в Profile
- [ ] Subscription expiry / upgrade CTA
- [ ] Permissions-based UI (скрывать фичи без права)
- [ ] `Telegram.WebApp.themeParams` — sync theme с Telegram
- [ ] `Telegram.WebApp.BackButton` для nested routes
- [ ] Referral через `openTelegramLink` нативно в TG

### Trading UI (Phase 2)

- [ ] Personal dashboard вместо / рядом с global bot block
- [ ] Connect exchange из Mini App
- [ ] User trades / user portfolio

### DevOps / quality

- [ ] E2E тест auth flow в Telegram WebView
- [ ] Error telemetry (Sentry / logs) для `/auth/telegram` failures
- [ ] Сужение CORS до `https://bablo-bot.web.app`
- [ ] Web bundle size / lazy loading (слабый инет)

---

## Все возможности кабинета (карта)

### Навигация

| Раздел | Route | Auth | Статус |
|--------|-------|------|--------|
| Home (Dashboard) | `/` | опционально | live |
| Market | tab | нет | live |
| History | tab | нет | live |
| Chart | `/chart` | нет | live |
| Stats | `/stats` | нет | live |
| Portfolio | `/portfolio` | нет | live (global) |
| Trades | `/trades` | нет | live |
| Signals | `/signals` | Premium gate UI | live |
| Profile | `/profile` | да для данных | live |
| Microloans | `/microloans` | да для apply | UI live, backend soon |
| Currency Exchange | `/exchange` | нет | UI live, swap backend soon |
| Courses | `/courses` | нет | live |
| Temki | `/temki` | нет | live |
| BABLO DAILY | `/daily/:id` | нет | live |
| AI Assistant | `/ai` | нет | live |
| Subscriptions | `/subscriptions` | нет | live |
| Partner | `/partner` | нет | live |
| Settings (Admin) | `/settings` | нет | live |
| About / Help / Docs | `/about` … | нет | live |
| US Stocks | `/us-stocks` | нет | live |
| Search | `/search` | нет | live |

### Sidebar — Premium leisure

PokerStars, Casino, Sports Betting — Premium badge → dialog → Subscriptions.

### Auth matrix

| Контекст | Поведение |
|----------|-----------|
| Mini App (@Artem_Bablo_Bot) | auto login via initData |
| Browser без Telegram | guest, Profile → Open bot |
| Valid refresh token | silent refresh + `/users/me` |
| Expired refresh | logout, «Session expired» |
| initData expired (~5 min) | re-open Mini App |

---

## Как проверить auth (чеклист)

1. Открыть **@Artem_Bablo_Bot** → Menu Button (не просто URL в браузере).
2. Home: полоска с **именем** и RSV (не «Sign in via Telegram»).
3. Profile: logged in, referral link, level/points.
4. Sign out → guest → Sign in снова.
5. Global bot block на Home работает **без** auth (это отдельно).

---

## Известные ограничения

- Первая загрузка Flutter Web ~40–50 MB — на слабом инете 2–5 мин.
- Telegram WebView кэширует версию — после deploy перезапустить Mini App.
- `api.json` в repo описывает в основном **bot** endpoints; user/auth — см. `docs/flutter-integration.md`.
- Microloan tier apply сохраняется **локально** до backend Phase 2.

---

## Связанные документы

| Файл | Назначение |
|------|------------|
| [`flutter-integration.md`](./flutter-integration.md) | Полная спека backend ↔ Flutter |
| [`../README.md`](../README.md) | Запуск, deploy, troubleshooting |
| [`../ARCHITECTURE_GUIDE.md`](../ARCHITECTURE_GUIDE.md) | MWWM, слои |

---

*Автор: Cursor session · 28.08.2026*
