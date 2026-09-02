# Backtest Lab — Flutter integration

> Public API · no auth · route `/lab` · sidebar **Trading → Backtest Lab**

Base URL: `https://api.bablochatik.com/api/v1`

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/backtest/config` | Strategy params + day limits (7–365) |
| GET | `/backtest/symbols?quote=USDT` | Symbol list for picker |
| POST | `/backtest/run` | Run simulation `{ "symbol": "AVAXUSDT", "days": 90 }` |

### Errors

| HTTP | Code | UI message |
|------|------|------------|
| 400 | `invalid_symbol` | Пара не найдена |
| 400 | `invalid_symbol_format` | Формат: AVAXUSDT |
| 503 | `binance_unavailable` | Попробуй позже |

## Architecture (MWWM)

```
lib/features/trading/pages/lab/
  lab_page.dart          # UI
  lab_wm.dart            # state + actions
  di/lab_wm_builder.dart

lib/features/trading/
  dto/backtest_dto.dart
  models/backtest_model.dart
  data_providers/backtest_data_provider.dart  # skipAuth: true
  repositories/backtest_repository.dart

lib/core/constants/backtest_constants.dart
```

Wired via `DataManager.backtestRepository` in `app_services.dart`.

## Symbol normalization

User input `AVAX` → `AVAXUSDT` before POST. Full symbols pass through unchanged.

## UI

- Symbol field + suggestion chips from `/symbols`
- Day presets: 30 / 90 / 180 (from config when available)
- Run → loading 10–30s (receive timeout 90s)
- Summary: Total PnL%, Win rate, Trades, Max DD
- Trades list: side, pnl_pct, exit_reason, dates
- Disclaimer: no fees/slippage, past ≠ future

## Strategy

Live Alligator H1 profile: SL 1.5×ATR, TP 3×ATR. Single symbol — not the scanner basket.

## Deploy

No extra env vars. Rebuild web as usual:

```bash
.fvm/flutter_sdk/bin/flutter build web --release \
  --dart-define=API_BASE_URL=https://api.bablochatik.com/api/v1
firebase deploy
```
