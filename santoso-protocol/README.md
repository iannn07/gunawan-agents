# XLSMART Package Advisor

A single-page web tool where an SME owner answers 3 questions about their
business and receives a personalized XLSMART connectivity package recommendation
powered by the Claude API. Built by the Gunawan AI Company — a zero-human
software company where 7 AI agents handle every function from research to deployment.

> Full documentation: [SANTOSO-PROTOCOL-PROJECT.md](./SANTOSO-PROTOCOL-PROJECT.md)

---

## Environment variables

| Variable | Required | Description |
|---|---|---|
| `ANTHROPIC_API_KEY` | Yes | Claude API key from console.anthropic.com |
| `TELEGRAM_BOT_TOKEN` | Yes | Bot token from @BotFather |
| `TELEGRAM_CHAT_ID` | Yes | Chat ID of the Gunawan HQ Telegram group |
| `PAPERCLIP_API_URL` | No | Paperclip API URL (default: `http://localhost:3100`) |
| `WEBHOOK_URL` | Yes | Public HTTPS URL for the Telegram webhook (ngrok or domain) |

Copy `.env.example` to `.env` and fill in all values before running.

---

## Run locally (development)

```bash
# 1. Install bridge dependencies
cd telegram-bridge && npm install && cd ..

# 2. Configure environment
cp .env.example .env
# Edit .env — fill in your API keys

# 3. Start the Telegram bridge
node telegram-bridge/index.js

# 4. In a separate terminal, start the Next.js app (after Quinn scaffolds it on VPS)
npm run dev
```

---

## Deploy (production)

```bash
# Build and start both services
docker-compose up -d --build

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

---

## Post-clone VPS setup

After cloning this repo onto your Ubuntu VPS, run these commands in order:

```bash
# 1. Install Paperclip (orchestration layer — Santoso)
npx paperclipai onboard --yes

# 2. Start Paperclip
npx paperclipai start
# Dashboard available at http://localhost:3100

# 3. Configure environment
cp .env.example .env
nano .env  # fill in: ANTHROPIC_API_KEY, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID, WEBHOOK_URL

# 4. Expose the bridge publicly (for Telegram webhook)
# Option A: ngrok (for demos)
ngrok http 3200
# Copy the HTTPS URL → update WEBHOOK_URL in .env

# Option B: Caddy (permanent)
# Add to /etc/caddy/Caddyfile:
#   your-domain.com { reverse_proxy localhost:3200 }
# sudo systemctl restart caddy

# 5. Install bridge dependencies and start
cd telegram-bridge
npm install
node index.js
# Bridge registers Telegram webhook automatically on startup

# 6. Verify setup
bash scripts/verify-setup.sh

# 7. Send your first message to Santoso in Gunawan HQ Telegram group:
#    "Hey Santoso. Our target client is PT XLSMART Telecom Sejahtera Tbk..."
#    (See SANTOSO-PROTOCOL-PROJECT.md Section 6 for the full first message)

# 8. (After Santoso assigns tasks) Scaffold the Next.js app for Quinn:
npx create-next-app@latest . --typescript --tailwind --app --src-dir --import-alias "@/*"
npm install @anthropic-ai/sdk zod
npx shadcn@latest init -d
npx shadcn@latest add button card input label badge checkbox slider
```

---

## Agent team

| Agent | Role |
|---|---|
| Dharmawan | Researcher — scrapes product data, produces structured JSON |
| Gunawan | Analyst — builds recommendation logic and Claude API prompts |
| Langston | Designer — creates UI specifications (no code) |
| Quinn | Engineer — builds the Next.js application |
| Hendrawan | QA — tests the app, files bugs, signs off |
| Alpha | DevOps — deploys to VPS, configures public URL |
| Linawati | Marketing/Sales — writes copy, emails, social posts |

Orchestrated by **Santoso** (Paperclip) via the Telegram bridge.
