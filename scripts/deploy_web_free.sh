#!/usr/bin/env bash
# Build Flutter Web + deploy to Firebase Hosting (Spark / free plan).
# Requires web/config.json with your Cloudflare Worker HTTPS URL.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CONFIG="$ROOT/web/config.json"
if grep -q "YOUR_SUBDOMAIN" "$CONFIG" 2>/dev/null; then
  echo "❌ Edit web/config.json first — set apiBaseUrl to your Worker URL."
  echo "   Deploy worker: cd cloudflare-worker && npx wrangler deploy"
  exit 1
fi

echo "▶ Flutter web release build..."
.fvm/flutter_sdk/bin/flutter build web --release

echo "▶ Firebase Hosting deploy..."
if command -v nvm >/dev/null 2>&1; then
  # shellcheck disable=SC1090
  source "$HOME/.nvm/nvm.sh" 2>/dev/null || true
  nvm use 20 >/dev/null 2>&1 || true
fi

npx --yes firebase-tools@latest deploy --only hosting --project bablo-bot

echo "✅ Done: https://bablo-bot.web.app"
