#!/usr/bin/env bash
# Check whether /casino/spin returns a board.
# Usage:
#   export BABLO_TOKEN='eyJ...'   # access_token from DevTools → Network → any /users/me request
#   ./scripts/check_casino_spin.sh
set -euo pipefail

API="${API_BASE_URL:-https://api.bablochatik.com/api/v1}"
TOKEN="${BABLO_TOKEN:-${1:-}}"

if [[ -z "$TOKEN" ]]; then
  echo "Missing token."
  echo "1) Open bablo-bot.web.app in browser (logged in via Telegram)"
  echo "2) DevTools → Network → any request to api.bablochatik.com"
  echo "3) Copy Authorization: Bearer <token>"
  echo "4) BABLO_TOKEN='...' $0"
  exit 1
fi

REQ_ID="term-$(date +%s)-$$"
BODY=$(cat <<EOF
{
  "game_id": "bablo_classic",
  "bet": 1,
  "currency": "DEMO",
  "action": "SPIN",
  "client_request_id": "$REQ_ID"
}
EOF
)

echo "POST $API/users/me/casino/spin"
echo "client_request_id=$REQ_ID"
echo

RESP=$(curl -sS -w '\n__HTTP__%{http_code}' -X POST "$API/users/me/casino/spin" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "$BODY")

HTTP=$(echo "$RESP" | sed -n 's/^__HTTP__//p')
JSON=$(echo "$RESP" | sed '/^__HTTP__/d')

echo "HTTP $HTTP"
echo "body_bytes=${#JSON}"
if [[ -z "$JSON" ]]; then
  echo "Empty response body (HTTP $HTTP but no JSON)."
  exit 2
fi

# IMPORTANT: do not use `python3 - <<EOF` with a pipe — heredoc steals stdin.
python3 -c '
import json, sys
raw = sys.stdin.read().strip()
try:
    d = json.loads(raw)
except Exception:
    print("Not JSON:", raw[:500])
    raise SystemExit(2)

print("top-level keys:", sorted(d.keys()) if isinstance(d, dict) else type(d))
board = None
if isinstance(d, dict):
    board = d.get("board")
    if board is None and isinstance(d.get("result"), dict):
        board = d["result"].get("board")
    if board is None and isinstance(d.get("spin"), dict):
        board = d["spin"].get("board")
    if board is None and isinstance(d.get("data"), dict):
        board = d["data"].get("board")

events = d.get("events") if isinstance(d, dict) else None
spin_id = d.get("spin_id") if isinstance(d, dict) else None
print("spin_id:", spin_id)
print("events count:", len(events) if isinstance(events, list) else None)
print("board present:", board is not None)
if isinstance(board, list):
    print("board rows:", len(board))
    for i, row in enumerate(board):
        print(f"  row[{i}]:", row)
elif board is not None:
    print("board type:", type(board), board)

if isinstance(events, list):
    for ev in events:
        if isinstance(ev, dict) and ev.get("type") in ("BOARD_GENERATED", "NEW_SYMBOLS_DROPPED"):
            b = (ev.get("data") or {}).get("board")
            print("event", ev.get("type"), "board:", b)
' <<<"$JSON"
