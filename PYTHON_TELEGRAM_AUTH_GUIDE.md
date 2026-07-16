# Python FastAPI: Telegram Auth → JWT → Roles → Protect Bot API

Инструкция для бэкенда **Bablo Trading Bot** (FastAPI).  
Передаётся Python-проекту как ТЗ на внедрение авторизации.

**Текущий API:** `http://<host>:8000/api/v1`  
**Swagger:** `http://<host>:8000/docs`  
**Клиент:** Flutter Web с кнопкой **Telegram Login Widget**

---

## 1. Цель

Закрыть открытый REST API:

1. Пользователь входит через **Telegram** (Login Widget на Flutter Web).
2. Backend **проверяет подпись** Telegram на сервере.
3. Backend выдаёт **JWT** (сессия).
4. Все запросы к bot API идут с `Authorization: Bearer <token>`.
5. **Роли:**
   - `viewer` — read-only (dashboard, portfolio, stats, trades, config read)
   - `admin` — + start/stop/panic, PATCH config, reconcile, adopt

---

## 2. Архитектура

```
Flutter Web (Telegram Login Widget)
        │
        │  POST /api/v1/auth/telegram
        │  { "hash", "auth_date", "user": { "id", "first_name", ... } }
        ▼
FastAPI
  ├─ verify_telegram_login_widget()   ← HMAC, bot token
  ├─ upsert user by telegram_id
  ├─ issue JWT (sub=user_id, role, exp)
  └─ return { token, user_id, role }

Flutter Web
        │
        │  GET/POST /api/v1/bot/* ...
        │  Authorization: Bearer <JWT>
        ▼
FastAPI
  ├─ verify_jwt()
  ├─ load user + role
  └─ allow / deny by route policy
```

**Опционально (позже):** поддержка `initData` от Telegram Mini App — отдельная функция проверки (другой алгоритм HMAC). Для Flutter Web в браузере достаточно Login Widget.

---

## 3. Переменные окружения

Добавить в `.env`:

```env
# Telegram (получить у @BotFather)
TELEGRAM_BOT_TOKEN=123456789:AA...

# JWT
JWT_SECRET=change-me-to-long-random-string-min-32-chars
JWT_TTL_HOURS=24

# Роли: telegram_id через запятую
ADMIN_TELEGRAM_IDS=123456789,987654321

# Feature flag: false = старое поведение (API открыт), true = требуется JWT
AUTH_ENABLED=true

# CORS (домен Flutter Web)
CORS_ORIGINS=https://app.example.com,http://localhost:8080

# Dev only: принимать mock hash для локальной разработки
DEV_MODE=false
```

---

## 4. Зависимости Python

```txt
# requirements.txt (добавить)
python-jose[cryptography]   # или PyJWT
passlib[bcrypt]             # опционально, если пароли не нужны — не ставить
sqlalchemy                  # если ещё нет ORM
alembic                     # миграции
```

Минимальный набор для auth:

```txt
PyJWT>=2.8
httpx                       # если уже есть — ok
```

---

## 5. Модель пользователя (БД)

### Таблица `users`

| Поле | Тип | Описание |
|------|-----|----------|
| `id` | UUID PK | внутренний id |
| `telegram_id` | BIGINT UNIQUE | id из Telegram |
| `username` | VARCHAR nullable | @username |
| `first_name` | VARCHAR nullable | |
| `last_name` | VARCHAR nullable | |
| `role` | ENUM `viewer`/`admin` | по умолчанию `viewer` |
| `created_at` | TIMESTAMPTZ | |
| `updated_at` | TIMESTAMPTZ | |
| `last_login_at` | TIMESTAMPTZ nullable | |

### Правило роли при login

```python
role = "admin" if telegram_id in ADMIN_TELEGRAM_IDS else "viewer"
```

Admin из whitelist **всегда** получает `admin` при входе (даже если раньше был viewer).

### SQL (PostgreSQL пример)

```sql
CREATE TYPE user_role AS ENUM ('viewer', 'admin');

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    telegram_id BIGINT NOT NULL UNIQUE,
    username TEXT,
    first_name TEXT,
    last_name TEXT,
    role user_role NOT NULL DEFAULT 'viewer',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_login_at TIMESTAMPTZ
);

CREATE INDEX idx_users_telegram_id ON users(telegram_id);
```

---

## 6. Проверка Telegram Login Widget

**Документация:** https://core.telegram.org/widgets/login#checking-authorization

Flutter Web после нажатия кнопки получает объект и отправляет на backend:

```json
{
  "hash": "abc123...",
  "auth_date": "1710000000",
  "user": {
    "id": 279058397,
    "first_name": "Roman",
    "last_name": "Dev",
    "username": "romandev",
    "photo_url": "https://..."
  }
}
```

### Алгоритм (Login Widget)

```python
import hashlib
import hmac
import json
from collections import OrderedDict


def build_check_string(data: dict[str, str]) -> str:
    """Все поля кроме hash, ключи отсортированы, формат key=value через \\n."""
    items = sorted((k, v) for k, v in data.items() if k != "hash")
    return "\n".join(f"{k}={v}" for k, v in items)


def verify_telegram_login_widget(
    *,
    auth_date: str,
    user: dict,
    received_hash: str,
    bot_token: str,
    dev_mode: bool = False,
    max_age_seconds: int = 86400,
) -> bool:
    if dev_mode and received_hash.startswith("mock_hash_for_development_"):
        return True

    import time
    if int(auth_date) < int(time.time()) - max_age_seconds:
        raise ValueError("auth_date expired")

    # user должен быть JSON-строкой в том виде, как Telegram его подписал
    user_json = json.dumps(user, separators=(",", ":"), ensure_ascii=False)

    data = {
        "auth_date": str(auth_date),
        "user": user_json,
    }
    check_string = build_check_string(data)

    secret_key = hashlib.sha256(bot_token.encode()).digest()
    computed = hmac.new(
        secret_key,
        check_string.encode(),
        hashlib.sha256,
    ).hexdigest()

    if not hmac.compare_digest(computed, received_hash):
        raise ValueError("Invalid telegram signature")

    return True
```

> **Важно:** Flutter должен отправлять `user` как объект; backend сам сериализует в JSON для проверки.  
> Если подпись не сходится — попробовать варианты сериализации `user` (порядок ключей).  
> Надёжнее на Flutter передавать **сырой callback** от Telegram widget без пересборки полей.

### Pydantic request

```python
from pydantic import BaseModel, Field


class TelegramUserPayload(BaseModel):
    id: int
    first_name: str
    last_name: str | None = None
    username: str | None = None
    photo_url: str | None = None
    language_code: str | None = None


class TelegramAuthRequest(BaseModel):
    hash: str
    auth_date: str
    user: TelegramUserPayload

    # Опционально для Mini App (второй этап):
    init_data: str | None = Field(default=None, alias="initData")
```

---

## 7. JWT

### Claims

```python
{
  "sub": "<user_uuid>",
  "telegram_id": 279058397,
  "role": "viewer" | "admin",
  "iat": 1710000000,
  "exp": 1710086400
}
```

### Код (PyJWT)

```python
import time
import jwt


def create_access_token(
    *,
    user_id: str,
    telegram_id: int,
    role: str,
    secret: str,
    ttl_hours: int = 24,
) -> str:
    now = int(time.time())
    payload = {
        "sub": user_id,
        "telegram_id": telegram_id,
        "role": role,
        "iat": now,
        "exp": now + ttl_hours * 3600,
    }
    return jwt.encode(payload, secret, algorithm="HS256")


def decode_access_token(token: str, secret: str) -> dict:
    return jwt.decode(token, secret, algorithms=["HS256"])
```

---

## 8. Новые эндпоинты

### `POST /api/v1/auth/telegram`

**Request:** см. `TelegramAuthRequest`  
**Response 200:**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "role": "admin",
  "telegram_id": 279058397,
  "username": "romandev"
}
```

**Errors:**
- `400` — нет полей / невалидный JSON user
- `401` — неверная подпись или просроченный `auth_date`
- `500` — внутренняя ошибка

### `GET /api/v1/auth/me`

**Auth:** Bearer JWT  
**Response 200:**

```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "telegram_id": 279058397,
  "username": "romandev",
  "first_name": "Roman",
  "role": "admin"
}
```

### `POST /api/v1/auth/logout` (опционально)

Для stateless JWT достаточно удалить токен на клиенте.  
Если нужен server-side logout — blacklist таблица `revoked_tokens(jti, exp)`.

---

## 9. FastAPI: dependency + middleware

### Current user dependency

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

security = HTTPBearer(auto_error=False)


class CurrentUser:
    def __init__(self, id: str, telegram_id: int, role: str):
        self.id = id
        self.telegram_id = telegram_id
        self.role = role

    @property
    def is_admin(self) -> bool:
        return self.role == "admin"


async def get_current_user(
    creds: HTTPAuthorizationCredentials | None = Depends(security),
) -> CurrentUser:
    if not settings.AUTH_ENABLED:
        # backward compat: synthetic admin for internal tools
        return CurrentUser(id="system", telegram_id=0, role="admin")

    if creds is None or creds.scheme.lower() != "bearer":
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Missing bearer token")

    try:
        payload = decode_access_token(creds.credentials, settings.JWT_SECRET)
    except jwt.PyJWTError:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid token")

    return CurrentUser(
        id=payload["sub"],
        telegram_id=payload["telegram_id"],
        role=payload["role"],
    )


def require_admin(user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
    if not user.is_admin:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Admin only")
    return user
```

### Подключение к роутам

```python
from fastapi import APIRouter, Depends

router = APIRouter(prefix="/api/v1")

@router.get("/bot/status")
async def bot_status(user: CurrentUser = Depends(get_current_user)):
    ...

@router.post("/bot/start")
async def bot_start(body: StartRequest, user: CurrentUser = Depends(require_admin)):
    ...

@router.patch("/config")
async def patch_config(body: ConfigPatch, user: CurrentUser = Depends(require_admin)):
    ...
```

---

## 10. Матрица доступа к существующим эндпоинтам

| Endpoint | Method | Роль |
|----------|--------|------|
| `/auth/telegram` | POST | public |
| `/auth/me` | GET | authenticated |
| `/bot/health` | GET | authenticated (viewer+) |
| `/bot/status` | GET | viewer+ |
| `/portfolio` | GET | viewer+ |
| `/stats` | GET | viewer+ |
| `/trades` | GET | viewer+ |
| `/pairs` | GET | viewer+ |
| `/config` | GET | viewer+ |
| `/config` | PATCH | **admin** |
| `/bot/start` | POST | **admin** |
| `/bot/stop` | POST | **admin** |
| `/bot/emergency-stop` | POST | **admin** |
| `/portfolio/reconcile` | POST | **admin** |
| `/portfolio/adopt` | POST | **admin** |

`/docs` и `/openapi.json` — оставить public на dev, закрыть basic auth / VPN в prod.

---

## 11. CORS для Flutter Web

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PATCH", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "Accept"],
)
```

---

## 12. Роут `POST /auth/telegram` (скелет)

```python
@auth_router.post("/telegram", response_model=AuthResponse)
async def authenticate_telegram(
    payload: TelegramAuthRequest,
    db: Session = Depends(get_db),
):
    verify_telegram_login_widget(
        auth_date=payload.auth_date,
        user=payload.user.model_dump(exclude_none=True),
        received_hash=payload.hash,
        bot_token=settings.TELEGRAM_BOT_TOKEN,
        dev_mode=settings.DEV_MODE,
    )

    role = (
        "admin"
        if payload.user.id in settings.ADMIN_TELEGRAM_ID_SET
        else "viewer"
    )

    user = upsert_user(
        db,
        telegram_id=payload.user.id,
        username=payload.user.username,
        first_name=payload.user.first_name,
        last_name=payload.user.last_name,
        role=role,
    )

    token = create_access_token(
        user_id=str(user.id),
        telegram_id=user.telegram_id,
        role=user.role,
        secret=settings.JWT_SECRET,
        ttl_hours=settings.JWT_TTL_HOURS,
    )

    return AuthResponse(
        token=token,
        user_id=str(user.id),
        role=user.role,
        telegram_id=user.telegram_id,
        username=user.username,
    )
```

---

## 13. Feature flag `AUTH_ENABLED`

Порядок миграции без простоя:

1. **Deploy 1:** добавить auth endpoints + таблицу users, `AUTH_ENABLED=false` — всё работает как раньше.
2. **Deploy 2:** Flutter Web начинает слать Bearer; backend принимает JWT, но без JWT тоже пускает.
3. **Deploy 3:** `AUTH_ENABLED=true` — JWT обязателен.

---

## 14. Настройка Telegram Bot (BotFather)

1. Создать бота: `/newbot` → получить `TELEGRAM_BOT_TOKEN`.
2. Привязать домен для Login Widget:
   ```
   /setdomain
   @YourBotName
   app.example.com
   ```
3. Flutter Web должен быть на **HTTPS** с этим доменом.
4. На странице login вставить widget:
   ```html
   <script async src="https://telegram.org/js/telegram-widget.js?22"
     data-telegram-login="YourBotName"
     data-size="large"
     data-onauth="onTelegramAuth(user)"
     data-request-access="write">
   </script>
   ```

Callback `onTelegramAuth(user)` → POST на `/api/v1/auth/telegram`.

---

## 15. Контракт для Flutter-клиента

### Login

```http
POST /api/v1/auth/telegram
Content-Type: application/json

{
  "hash": "...",
  "auth_date": "1710000000",
  "user": {
    "id": 279058397,
    "first_name": "Roman",
    "username": "romandev"
  }
}
```

### Все остальные запросы

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Accept: application/json
```

### Обработка ошибок на клиенте

| HTTP | Действие Flutter |
|------|------------------|
| `401` | очистить токен → экран Login |
| `403` | snackbar «Недостаточно прав» |
| `200` | обычный flow |

---

## 16. Тесты (curl)

### Login (после реального callback от widget)

```bash
curl -s -X POST http://localhost:8000/api/v1/auth/telegram \
  -H 'Content-Type: application/json' \
  -d '{
    "hash": "REAL_HASH_FROM_TELEGRAM",
    "auth_date": "1710000000",
    "user": {"id": 279058397, "first_name": "Test", "username": "testuser"}
  }' | jq
```

### Protected endpoint

```bash
TOKEN="eyJ..."
curl -s http://localhost:8000/api/v1/bot/status \
  -H "Authorization: Bearer $TOKEN" | jq
```

### Admin-only (viewer → 403)

```bash
curl -s -X POST http://localhost:8000/api/v1/bot/stop \
  -H "Authorization: Bearer $VIEWER_TOKEN"
```

### Dev mock (только DEV_MODE=true)

```bash
curl -s -X POST http://localhost:8000/api/v1/auth/telegram \
  -H 'Content-Type: application/json' \
  -d '{
    "hash": "mock_hash_for_development_1",
    "auth_date": "'$(date +%s)'",
    "user": {"id": 1, "first_name": "Dev"}
  }'
```

---

## 17. Безопасность (обязательно в prod)

- [ ] **HTTPS** (nginx / Cloudflare / Let's Encrypt)
- [ ] `JWT_SECRET` — случайная строка ≥ 32 символов, не в git
- [ ] `TELEGRAM_BOT_TOKEN` — только на сервере
- [ ] `DEV_MODE=false` в production
- [ ] `auth_date` не старше 24 часов
- [ ] Rate limit на `POST /auth/telegram` (например 10 req/min/IP)
- [ ] Логировать login attempts без полного token/hash
- [ ] Admin actions (start/stop/adopt) — audit log: `user_id`, action, timestamp

---

## 18. Структура файлов (рекомендация)

```
app/
  auth/
    __init__.py
    router.py          # /auth/telegram, /auth/me
    schemas.py         # TelegramAuthRequest, AuthResponse
    service.py         # upsert_user, authenticate
    telegram.py        # verify_telegram_login_widget (+ initData позже)
    jwt_utils.py       # create/decode token
    dependencies.py    # get_current_user, require_admin
  models/
    user.py
  middleware/
    cors.py            # или в main.py
  config.py            # Settings с env
  main.py              # include auth router + protect existing routers
migrations/
  xxx_create_users.sql
tests/
  test_telegram_verify.py
  test_auth_routes.py
  test_rbac.py
```

---

## 19. Опционально: Mini App initData (этап 2)

Если позже приложение откроют **внутри Telegram** как Mini App:

- Flutter шлёт `{ "initData": "<original query string>" }`
- Backend проверяет по алгоритму WebApp:
  - `secret_key = HMAC_SHA256(key=b"WebAppData", msg=bot_token)`
  - параметры из initData (кроме `hash`) → sort → `check_string`
  - сравнить HMAC

Можно добавить второй путь в тот же `POST /auth/telegram`:

```python
if payload.init_data:
    verify_telegram_webapp_init_data(...)
elif payload.hash and payload.user:
    verify_telegram_login_widget(...)
else:
    raise HTTPException(400, "Invalid auth payload")
```

Референс реализации: https://github.com/RomanDevelop/alien-tap-backend (`src/utils/telegram.rs`, `src/routes/auth.rs`).

---

## 20. Чеклист готовности

- [ ] Таблица `users` + миграция
- [ ] `POST /auth/telegram` работает с реальным Telegram widget
- [ ] `GET /auth/me` возвращает профиль
- [ ] JWT dependency подключена ко всем `/api/v1/*` кроме `/auth/telegram`
- [ ] Admin routes возвращают `403` для viewer
- [ ] CORS настроен под Flutter Web origin
- [ ] `AUTH_ENABLED` протестирован в обоих режимах
- [ ] Документация Swagger обновлена (security scheme Bearer)
- [ ] Prod: HTTPS + домен в BotFather

---

## 21. Swagger security scheme

```python
from fastapi.openapi.utils import get_openapi

def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    schema = get_openapi(...)
    schema["components"]["securitySchemes"] = {
        "BearerAuth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
        }
    }
    app.openapi_schema = schema
    return app.openapi_schema
```

На защищённых роутах:

```python
@router.get("/bot/status", dependencies=[Depends(get_current_user)])
```

---

*Документ подготовлен для интеграции с Flutter-клиентом Bablo Trading. Вопросы по контракту — сверяться с `FLUTTER_APP_GUIDE.md`.*
