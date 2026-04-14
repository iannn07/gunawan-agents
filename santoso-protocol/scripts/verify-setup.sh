#!/usr/bin/env bash
# verify-setup.sh
# Verifies that the Gunawan AI Company environment is ready for VPS deployment.
# Run after cloning the repo and configuring .env.

set -euo pipefail

PASS=0
WARN=0
FAIL=0

green()  { echo -e "\033[0;32m✔ $*\033[0m"; }
yellow() { echo -e "\033[0;33m⚠ $*\033[0m"; }
red()    { echo -e "\033[0;31m✘ $*\033[0m"; }

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  Gunawan AI Company — Setup Verification"
echo "═══════════════════════════════════════════════════════"
echo ""

# ── 1. Node.js version ──────────────────────────────────────────────────────
echo "[ Node.js ]"
if command -v node &>/dev/null; then
  NODE_VERSION=$(node -e "process.stdout.write(process.versions.node)")
  MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
  if [ "$MAJOR" -ge 20 ]; then
    green "Node.js $NODE_VERSION (≥20 required)"
    ((PASS++))
  else
    red "Node.js $NODE_VERSION — version 20+ required"
    ((FAIL++))
  fi
else
  red "Node.js not found — install from nodejs.org"
  ((FAIL++))
fi

# ── 2. npm ──────────────────────────────────────────────────────────────────
echo ""
echo "[ npm ]"
if command -v npm &>/dev/null; then
  green "npm $(npm --version)"
  ((PASS++))
else
  red "npm not found"
  ((FAIL++))
fi

# ── 3. Environment file ─────────────────────────────────────────────────────
echo ""
echo "[ Environment ]"
if [ -f ".env" ]; then
  green ".env file exists"
  ((PASS++))

  # Load .env for checking
  set -a
  # shellcheck disable=SC1091
  source .env 2>/dev/null || true
  set +a

  # ANTHROPIC_API_KEY
  if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
    red "ANTHROPIC_API_KEY is not set"
    ((FAIL++))
  elif [[ "${ANTHROPIC_API_KEY}" == *"your-"* ]]; then
    yellow "ANTHROPIC_API_KEY still contains placeholder value — replace before running"
    ((WARN++))
  else
    green "ANTHROPIC_API_KEY is set"
    ((PASS++))
  fi

  # TELEGRAM_BOT_TOKEN
  if [ -z "${TELEGRAM_BOT_TOKEN:-}" ]; then
    red "TELEGRAM_BOT_TOKEN is not set"
    ((FAIL++))
  elif [[ "${TELEGRAM_BOT_TOKEN}" == *"your-"* ]]; then
    yellow "TELEGRAM_BOT_TOKEN still contains placeholder value"
    ((WARN++))
  else
    green "TELEGRAM_BOT_TOKEN is set"
    ((PASS++))
  fi

  # TELEGRAM_CHAT_ID
  if [ -z "${TELEGRAM_CHAT_ID:-}" ]; then
    red "TELEGRAM_CHAT_ID is not set"
    ((FAIL++))
  elif [[ "${TELEGRAM_CHAT_ID}" == *"your-"* ]]; then
    yellow "TELEGRAM_CHAT_ID still contains placeholder value"
    ((WARN++))
  else
    green "TELEGRAM_CHAT_ID is set"
    ((PASS++))
  fi

  # WEBHOOK_URL
  if [ -z "${WEBHOOK_URL:-}" ] || [[ "${WEBHOOK_URL}" == *"your-"* ]]; then
    yellow "WEBHOOK_URL is not set — Telegram webhook will not auto-register"
    yellow "Set WEBHOOK_URL to your ngrok URL or domain, then restart the bridge"
    ((WARN++))
  else
    green "WEBHOOK_URL is set: ${WEBHOOK_URL}"
    ((PASS++))
  fi

else
  red ".env file not found — run: cp .env.example .env && nano .env"
  ((FAIL++))
fi

# ── 4. Bridge dependencies ──────────────────────────────────────────────────
echo ""
echo "[ Telegram Bridge ]"
if [ -f "telegram-bridge/package.json" ]; then
  green "telegram-bridge/package.json found"
  ((PASS++))
  if [ -d "telegram-bridge/node_modules" ]; then
    green "telegram-bridge/node_modules exists"
    ((PASS++))
  else
    yellow "telegram-bridge/node_modules missing — run: cd telegram-bridge && npm install"
    ((WARN++))
  fi
else
  red "telegram-bridge/package.json not found"
  ((FAIL++))
fi

# ── 5. Paperclip ───────────────────────────────────────────────────────────
echo ""
echo "[ Paperclip ]"
PAPERCLIP_URL="${PAPERCLIP_API_URL:-http://localhost:3100}"
if curl -sf "${PAPERCLIP_URL}" &>/dev/null; then
  green "Paperclip is running at ${PAPERCLIP_URL}"
  ((PASS++))
else
  yellow "Paperclip not reachable at ${PAPERCLIP_URL}"
  yellow "Start it with: npx paperclipai start"
  ((WARN++))
fi

# ── 6. Docker ──────────────────────────────────────────────────────────────
echo ""
echo "[ Docker ]"
if command -v docker &>/dev/null; then
  green "Docker $(docker --version | cut -d' ' -f3 | tr -d ',')"
  ((PASS++))
  if command -v docker-compose &>/dev/null || docker compose version &>/dev/null 2>&1; then
    green "Docker Compose available"
    ((PASS++))
  else
    yellow "Docker Compose not found — install it to use docker-compose.yml"
    ((WARN++))
  fi
else
  yellow "Docker not found — needed for production deployment"
  yellow "Install from: https://docs.docker.com/engine/install/ubuntu/"
  ((WARN++))
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  Results: ${PASS} passed, ${WARN} warnings, ${FAIL} failed"
echo "═══════════════════════════════════════════════════════"
echo ""

if [ "$FAIL" -gt 0 ]; then
  red "Setup incomplete — fix the errors above before proceeding."
  exit 1
elif [ "$WARN" -gt 0 ]; then
  yellow "Gunawan AI Company — Setup mostly ready. Address warnings before going live."
  exit 0
else
  green "Gunawan AI Company — Setup verified. Ready for VPS deployment."
  exit 0
fi
