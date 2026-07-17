# Flutter Web на Firebase (бесплатно, без Blaze)

## Проблема

- Firebase Hosting: `https://bablo-bot.web.app` (HTTPS)
- AWS Python API: `http://18.197.147.209:8000` (HTTP)
- Браузер блокирует HTTPS → HTTP (**Mixed Content**)

APK и localhost работают — там нет этого ограничения.

## Решение (бесплатно)

**Cloudflare Worker** — HTTPS-прокси между Firebase Web и AWS:

```
bablo-bot.web.app  →  Cloudflare Worker (HTTPS)  →  AWS :8000 (HTTP)
```

Firebase **Blaze не нужен**.

---

## Шаг 1 — Cloudflare Worker (5 мин)

1. Аккаунт: https://dash.cloudflare.com/sign-up (бесплатно)
2. В терминале:

```bash
cd cloudflare-worker
npx wrangler login
npx wrangler deploy
```

3. Скопируй URL из вывода, например:
   ```
   https://bablo-bot-api.roman-dev.workers.dev
   ```

4. Проверка:

```bash
curl -s https://bablo-bot-api.YOUR_SUBDOMAIN.workers.dev/api/v1/bot/health
```

Должен вернуть JSON бота.

---

## Шаг 2 — config.json

Отредактируй `web/config.json`:

```json
{
  "apiBaseUrl": "https://bablo-bot-api.YOUR_SUBDOMAIN.workers.dev/api/v1"
}
```

На Firebase Web приложение читает этот файл и подставляет HTTPS API URL.

---

## Шаг 3 — Build + Deploy Firebase

```bash
nvm use 20
chmod +x scripts/deploy_web_free.sh
./scripts/deploy_web_free.sh
```

Или вручную:

```bash
.fvm/flutter_sdk/bin/flutter build web --release
npx --yes firebase-tools@latest deploy --only hosting --project bablo-bot
```

---

## Шаг 4 — Проверка

1. Открой https://bablo-bot.web.app
2. DevTools → Network → запросы идут на `*.workers.dev/api/v1/...`
3. Dashboard загружается

---

## AWS — что проверить

На EC2 `18.197.147.209`:

- Python слушает `0.0.0.0:8000`
- Security Group: inbound **8000** от `0.0.0.0/0` (Worker ходит с Google IP)

```bash
curl -s http://18.197.147.209:8000/api/v1/bot/health
```

---

## Локальная разработка

| Команда | API |
|---------|-----|
| `fvm flutter run -d chrome` | `http://18.197.147.209:8000/api/v1` (default) |
| `python3 -m http.server 8080` в `build/web` | то же |
| `bablo-bot.web.app` | Worker URL из `web/config.json` |

---

## Обновление Worker (если сменился IP AWS)

Отредактируй `BACKEND` в `cloudflare-worker/src/index.js` → `npx wrangler deploy`.

---

## Стоимость

| Сервис | План |
|--------|------|
| Firebase Hosting | Spark (free) |
| Cloudflare Worker | Free (100k req/day) |
| AWS EC2 | как было |
