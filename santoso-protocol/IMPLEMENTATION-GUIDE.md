# Santoso Protocol — Implementation & Validation Guide

> **Purpose:** Complete reference for validating the `santoso-protocol/` scaffold
> and deploying it to a Ubuntu VPS. Read this top-to-bottom before cloning.
>
> **Last updated:** April 2026
> **Repo:** `gunawan-agentic-ai/santoso-protocol/`

---

## Table of Contents

1. [What Was Built](#1-what-was-built)
2. [Directory Structure](#2-directory-structure)
3. [File-by-File Reference](#3-file-by-file-reference)
4. [The 7-Agent Chain](#4-the-7-agent-chain)
5. [Telegram Bridge — How It Works](#5-telegram-bridge--how-it-works)
6. [webapp-gunawan Framework Integration](#6-webapp-gunawan-framework-integration)
7. [VPS Setup — Step-by-Step](#7-vps-setup--step-by-step)
8. [First Run Walkthrough](#8-first-run-walkthrough)
9. [Budget & Time Estimates](#9-budget--time-estimates)
10. [Validation Checklist](#10-validation-checklist)

---

## 1. What Was Built

The `santoso-protocol/` directory is a **VPS-ready scaffold** for the Gunawan AI
Company. It is the git repo you clone onto your Ubuntu VPS to deploy a zero-human
software company orchestrated by Paperclip (Santoso) and accessible via Telegram.

### The demo product

**XLSMART Package Advisor** — a single-page Next.js web tool where an Indonesian
SME owner answers 3 questions (industry, company size, needs) and receives an
AI-generated connectivity package recommendation from XLSMART for BUSINESS.

This is the first POC of the Gunawan AI Company. The same scaffold can be adapted
for any future project by updating the agent prompt files in `.claude/agents/`.

### What this scaffold does NOT include

- The Next.js application source code — Quinn scaffolds that on the VPS when
  Santoso assigns the task.
- Compiled binaries or `node_modules/` — installed on VPS post-clone.
- Any secrets — all provided via `.env` after cloning.

---

## 2. Directory Structure

```
santoso-protocol/
│
├── SANTOSO-PROTOCOL-PROJECT.md     ← Single source of truth. Full company
│                                      context, agent roster, architecture,
│                                      sprint plan, success criteria.
│                                      READ ONLY — do not modify.
│
├── CLAUDE.md                       ← Operating manual auto-loaded by Claude
│                                      Code at every session start. Defines
│                                      agents, tech stack, standards, and
│                                      references webapp-gunawan as framework.
│
├── .env.example                    ← Template for all required env vars.
│                                      Copy to .env and fill in on VPS.
│
├── .gitignore                      ← Excludes .env, node_modules, .next, etc.
│
├── .claude/
│   ├── settings.json               ← Marks CLAUDE.md and PROJECT.md as
│   │                                  protected (read-only for agents).
│   └── agents/                     ← System prompts loaded into Paperclip.
│       │                              One file per agent.
│       ├── dharmawan-researcher.md
│       ├── gunawan-analyst.md
│       ├── langston-designer.md
│       ├── quinn-engineer.md       ← Contains Step 0: webapp-gunawan bootstrap
│       ├── hendrawan-qa.md
│       ├── alpha-devops.md
│       └── linawati-marketing.md
│
├── telegram-bridge/
│   ├── index.js                    ← Express server on port 3200.
│   │                                  The critical integration: Telegram ↔ Paperclip.
│   ├── package.json                ← express + node-fetch dependencies.
│   └── Dockerfile.bridge           ← Minimal Node 20 Alpine image for the bridge.
│
├── Dockerfile                      ← Multi-stage Next.js build (deps→build→runtime).
│                                      Used by Quinn/Alpha after app is scaffolded.
│
├── docker-compose.yml              ← Runs two services:
│                                      advisor (port 3000) + telegram-bridge (3200).
│
├── README.md                       ← Quick-start + post-clone VPS commands.
│
└── scripts/
    └── verify-setup.sh             ← Checks Node, npm, .env, Paperclip, Docker.
                                       Run after cloning to confirm readiness.
```

---

## 3. File-by-File Reference

### 3.1 `CLAUDE.md`

**Auto-loaded by Claude Code at every session start.**

| Section | Content |
|---------|---------|
| Project context | XLSMART Package Advisor description, link to PROJECT.md |
| Agents table | 7 agents, roles, output locations |
| Framework standard | Points to `../webapp-gunawan/`. Bootstrap command: `cp -r ../webapp-gunawan/.gunawan ./.gunawan` |
| Tech stack | Next.js latest, TypeScript strict, Tailwind 4.x, shadcn/ui, Anthropic SDK, Zod |
| Code standards | safeParse() only, no `any`, server-side API routes, mobile-first |
| File output conventions | Maps each agent to their output directory |
| Communication model | Paperclip issues → Telegram bridge → HQ group |
| Protected files | SANTOSO-PROTOCOL-PROJECT.md, CLAUDE.md |

**Key decision:** `webapp-gunawan` is referenced as the governing framework, not
re-implemented. Quinn copies `.gunawan/` into the project — this means all
foundation OS, build standards, and QA strategy come from the same source as
all other Gunawan projects.

---

### 3.2 `.claude/settings.json`

```json
{
  "permissions": { "deny": [] },
  "protectedFiles": [
    "SANTOSO-PROTOCOL-PROJECT.md",
    "CLAUDE.md"
  ]
}
```

Prevents any agent from modifying the two governing documents without escalation.

---

### 3.3 `.claude/agents/` — Agent System Prompts

Each file is the system prompt configured in Paperclip for that agent. Structure
is identical across all 7:

```
Identity     → name, role, what to read first
Responsibilities → general capabilities
Current project  → XLSMART-specific task, inputs, output file/format
Rules            → what the agent must/must not do
Budget guidance  → cost ceiling for this task
```

#### Dharmawan — Researcher
- **Input:** Web (xlsmart.co.id/bisnis and sub-pages)
- **Output:** `data/xlsmart-products.json`
- **Schema:** `{ id, name, category, target_industries, target_company_size, key_features, use_cases, tagline, contact_cta }`
- **Constraint:** No invented data. If a page is inaccessible, move on.
- **Budget:** $3–5

#### Gunawan — Analyst
- **Input:** `data/xlsmart-products.json`
- **Output:** `analysis/recommendation-matrix.md`
- **Contains:** Decision matrix (industry × size × need → product) + Claude API prompt template
- **Constraint:** No code. Matrix must cover all industry/size/need combinations.
- **Budget:** $3–5

#### Langston — Designer
- **Input:** `data/xlsmart-products.json` + `analysis/recommendation-matrix.md`
- **Output:** `design/ui-spec.md`
- **Contains:** Brand guidelines, page layout, all 3 wizard steps spec'd, component inventory
- **Constraint:** No JSX, no CSS, no code. Markdown descriptions only.
- **Budget:** $3–5

#### Quinn — Engineer
- **Input:** `../webapp-gunawan/CLAUDE.md`, `.gunawan/`, `design/ui-spec.md`, `analysis/recommendation-matrix.md`, `data/xlsmart-products.json`, `marketing-assets/`
- **Output:** `src/` (complete Next.js application)
- **Step 0:** `cp -r ../webapp-gunawan/.gunawan ./.gunawan` — bootstrap framework
- **Step 1:** `npx create-next-app@latest . --typescript --tailwind --app --src-dir --import-alias "@/*"` *(Note 2: pin version for deterministic builds — run `npm view next version` first)*
- **Components:** IndustrySelector, BusinessProfile, RecommendationResult, WizardProgress
- **API route:** `POST /api/recommend` — Zod validation → Claude API → JSON response
- **Constraint:** TypeScript strict, `safeParse()` only, no `any`, server-side API calls only
- **Budget:** $10–15

#### Hendrawan — QA
- **Input:** Running app at `http://localhost:3000` + `.gunawan/qa-os/strategy.md`
- **Output:** `test/test-report.md`
- **Runs:** 5 business profile scenarios, 3 mobile breakpoints, 4 edge cases
- **Constraint:** No code changes — file bugs as Paperclip issues assigned to Quinn
- **Budget:** $3–5

#### Alpha — DevOps
- **Input:** Hendrawan's signed-off test report + `.gunawan/deployment-os/`
- **Output:** Live HTTPS URL
- **Options:** Docker Compose (recommended) or direct Node.js + PM2
- **Public URL:** ngrok (demo) or Caddy (permanent)
- **Constraint:** Deploy only after QA PASS. HTTPS required. `restart: always`.
- **Budget:** $3–5

#### Linawati — Marketing/Sales
- **Input:** `data/xlsmart-products.json` (Phase 1), live URL from Alpha (Phase 2)
- **Output:** `marketing-assets/` — 5 files (hero-copy.md, linkedin-post.md, cold-email.md, seo-meta.json, one-pager.md)
- **Timing:** Phase 1 runs in parallel with Gunawan (Analyst). Phase 2 after Alpha deploys.
- **Constraint:** No invented XLSMART claims. Use `[LIVE_URL]` placeholder in Phase 1.
- **Budget:** $3–5 (Phase 1) + $1–2 (Phase 2)

---

### 3.4 `telegram-bridge/index.js`

The critical integration layer. Routes messages between Telegram and Paperclip.

**Port:** 3200 (no conflict: Paperclip=3100, Next.js app=3000)

**Routes:**

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/telegram/webhook` | Receives Telegram updates. Creates a Paperclip issue from each text message in the Gunawan HQ group. |
| `POST` | `/notify` | Called by Paperclip agents to post status updates back to the Telegram group. Payload: `{ text: string }` |
| `GET` | `/health` | Returns service status, Paperclip URL, webhook URL, chat config. Used by Docker, verify-setup.sh, and Alpha. |

**On startup:** Calls `POST https://api.telegram.org/bot{TOKEN}/setWebhook` with
`WEBHOOK_URL/telegram/webhook` — no manual webhook registration needed.

> **Note 3 — Verify Paperclip API endpoint shape after install:**
> The bridge's `createPaperclipIssue()` function posts to `PAPERCLIP_API_URL/api/issues`.
> After running `npx paperclipai onboard`, open `http://localhost:3100` and check the
> API docs to confirm the correct endpoint path, required fields, and response shape.
> If the path or payload differs from what's in `telegram-bridge/index.js`, update
> `createPaperclipIssue()` before running the first demo.

**Message flow (incoming):**
```
User types in Telegram group
        ↓
Telegram sends POST to /telegram/webhook
        ↓
Bridge validates it's from TELEGRAM_CHAT_ID
        ↓
createPaperclipIssue(text) → POST PAPERCLIP_API_URL/api/issues
        ↓
Bridge replies to group: "✅ Santoso received. Issue #N created: [title]"
```

**Message flow (outgoing from agents):**
```
Paperclip agent completes task
        ↓
Agent calls POST http://localhost:3200/notify { text: "..." }
        ↓
Bridge calls Telegram sendMessage → message appears in HQ group
```

**Environment variables required:**

| Variable | Required | Default | Purpose |
|---------|----------|---------|---------|
| `TELEGRAM_BOT_TOKEN` | Yes | — | From @BotFather |
| `TELEGRAM_CHAT_ID` | Yes | — | Gunawan HQ group ID |
| `PAPERCLIP_API_URL` | No | `http://localhost:3100` | Paperclip API |
| `WEBHOOK_URL` | Yes* | — | Public HTTPS URL for webhook registration. *Without this, webhook won't auto-register (manual registration needed). |
| `PORT` | No | `3200` | Bridge listen port |

---

### 3.5 `Dockerfile`

Multi-stage Next.js production build. Used after Quinn scaffolds the app.

```
Stage 1 (deps)    → node:20-alpine, npm ci --omit=dev
Stage 2 (builder) → copies deps + source, runs npm run build
Stage 3 (runner)  → minimal runtime, non-root user (nextjs:1001), port 3000
```

Requires `output: 'standalone'` in `next.config.js` — Quinn adds this during scaffolding.

---

### 3.6 `docker-compose.yml`

Two services, both reading from `.env`:

| Service | Image | Port | Restart |
|---------|-------|------|---------|
| `advisor` | Built from `Dockerfile` | 3000 | always |
| `telegram-bridge` | Built from `telegram-bridge/Dockerfile.bridge` | 3200 | always |

Health checks on both services. Bridge depends on `advisor` starting first.

---

### 3.7 `scripts/verify-setup.sh`

Run after cloning. Checks:

| Check | Pass | Warn | Fail |
|-------|------|------|------|
| Node.js ≥ 20 | ✓ version shown | — | version < 20 or missing |
| npm present | ✓ | — | missing |
| `.env` file exists | ✓ | — | missing (with fix command) |
| `ANTHROPIC_API_KEY` set | ✓ | placeholder value | not set |
| `TELEGRAM_BOT_TOKEN` set | ✓ | placeholder value | not set |
| `TELEGRAM_CHAT_ID` set | ✓ | placeholder value | not set |
| `WEBHOOK_URL` set | ✓ | not set | — |
| Bridge `node_modules` | ✓ | missing (with fix) | — |
| Paperclip reachable | ✓ | not running (with fix) | — |
| Docker present | ✓ | missing (with install link) | — |

Exit codes: `0` = all pass or warnings only. `1` = at least one failure.

---

## 4. The 7-Agent Chain

### Execution order and dependencies

```
Phase 1 — Research & Analysis (parallel)
─────────────────────────────────────────
Dharmawan ──→ data/xlsmart-products.json
                      │
                      ├──→ Gunawan ──→ analysis/recommendation-matrix.md
                      │
                      └──→ Linawati (Phase 1) ──→ marketing-assets/ (draft)


Phase 2 — Design & Build
─────────────────────────────────────────
Gunawan output ──→ Langston ──→ design/ui-spec.md
                                        │
          [all previous outputs] ───────┘
                      │
                      └──→ Quinn (Step 0: bootstrap webapp-gunawan)
                                   │
                                   └──→ src/ (Next.js app)


Phase 3 — Test & Deploy (sequential)
─────────────────────────────────────────
Quinn output ──→ Hendrawan ──→ test/test-report.md (PASS)
                                        │
                                        └──→ Alpha ──→ live HTTPS URL


Phase 4 — Marketing finalize
─────────────────────────────────────────
Alpha live URL ──→ Linawati (Phase 2) ──→ marketing-assets/ (final with URL)
                                                  │
                                                  └──→ Telegram HQ: final post
```

### Dependency table

| Agent | Waits for | Can start in parallel with |
|-------|-----------|---------------------------|
| Dharmawan | — (first) | — |
| Gunawan | Dharmawan | Linawati Phase 1 |
| Linawati Phase 1 | Dharmawan | Gunawan |
| Langston | Gunawan | — |
| Quinn | Langston (+ all previous) | — |
| Hendrawan | Quinn | — |
| Alpha | Hendrawan (PASS) | — |
| Linawati Phase 2 | Alpha | — |

### How Santoso routes tasks

Each agent receives their task via a Paperclip issue. Santoso (Paperclip):
1. Creates the issue with the agent's system prompt context loaded
2. Assigns to the appropriate Claude Code instance
3. Agent completes task, comments on issue with output path
4. Santoso notifies you via Telegram through the bridge (`POST /notify`)
5. You confirm or escalate before next phase begins (deployment gate)

---

## 5. Telegram Bridge — How It Works

### Setup flow (one-time, on VPS)

```
1. Create Telegram bot via @BotFather → get TELEGRAM_BOT_TOKEN
2. Create "Gunawan HQ" group → add your bot → get TELEGRAM_CHAT_ID
3. Set up ngrok or Caddy for a public HTTPS URL → set as WEBHOOK_URL
4. Fill .env with all 4 values
5. node telegram-bridge/index.js
   → On startup: calls Telegram setWebhook automatically
   → Logs: "[bridge] Telegram webhook registered: https://your-url/telegram/webhook"
```

### Getting TELEGRAM_CHAT_ID

Add `@userinfobot` to your Gunawan HQ group. It will reply with the chat ID.
The ID for groups is negative (e.g., `-1001234567890`).

### Getting the public URL for WEBHOOK_URL

**For demos (ngrok):**
```bash
ngrok http 3200
# Copy the https://xxxxx.ngrok-free.app URL
# Set WEBHOOK_URL=https://xxxxx.ngrok-free.app in .env
# Restart the bridge
```

**For permanent VPS with a domain (Caddy):**
```
# /etc/caddy/Caddyfile
your-domain.com {
    reverse_proxy localhost:3200
}
```
Set `WEBHOOK_URL=https://your-domain.com` in `.env`.

### Testing the bridge

After starting the bridge, verify it's working:

```bash
# 1. Check health
curl http://localhost:3200/health
# Expected: { "status": "ok", "webhook_url": "https://...", ... }

# 2. Test the notify endpoint (simulates an agent posting to Telegram)
curl -X POST http://localhost:3200/notify \
  -H "Content-Type: application/json" \
  -d '{"text": "Test from bridge"}'
# Expected: message appears in Gunawan HQ Telegram group

# 3. Send a message in the Telegram group
# Expected: bot replies "✅ Santoso received. Paperclip issue #N created: ..."
```

---

## 6. webapp-gunawan Framework Integration

### Why this matters

Without the `webapp-gunawan` framework, Quinn would invent its own coding
conventions. With it, the Package Advisor inherits the same foundation OS,
build standards, and QA strategy used across all Gunawan projects — ensuring
consistency and quality without re-specifying every rule.

### What gets copied

Quinn runs this command as **Step 0** before writing any code:

```bash
# From santoso-protocol/ directory on VPS
cp -r ../webapp-gunawan/.gunawan ./.gunawan
```

This copies the entire Gunawan OS into the project:

```
.gunawan/
├── foundation/
│   ├── human-intent-os/    ← values, decision rules
│   ├── agent-foundation-os/ ← runtime behavior, task lifecycle, Newborn Gate
│   ├── role-definition-os/ ← who does what
│   ├── design-os/          ← design system standards
│   ├── build-os/           ← implementation rules
│   └── feedback-os/        ← reflection and learning
├── architecture-os/
│   ├── schema-conventions.md
│   ├── rpc-standards.md
│   ├── api-contracts.md
│   └── audit-trail.md
├── implementation-os/
│   └── standards.md        ← Quinn's non-negotiable code rules
├── qa-os/
│   └── strategy.md         ← Hendrawan reads this before any test
└── deployment-os/
    ├── ci-cd.md
    ├── environments.md
    └── release-process.md  ← Alpha reads this before deploying
```

### Which agents use which layer

| Agent | Framework layer used |
|-------|---------------------|
| Quinn | All layers (full foundation loading order from webapp-gunawan/CLAUDE.md) |
| Hendrawan | `.gunawan/qa-os/strategy.md` |
| Alpha | `.gunawan/deployment-os/` |
| Others | None directly — their work is pre-code (research, analysis, design, marketing) |

### The Newborn Gate

`webapp-gunawan` enforces a **Newborn Gate** before any substantive workflow.
Quinn runs this gate from `.gunawan/foundation/agent-foundation-os/` before
writing a single line of code. The gate checks:

- Foundation files exist and are non-empty
- Active role is declared
- Task is classified (implementation)
- Assumptions are explicit
- Protected files are identified
- Approval gates are known

This prevents Quinn from making unilateral architecture decisions.

### webapp-gunawan path on VPS

The full repo is cloned to the VPS. Both directories exist:

```
gunawan-agentic-ai/
├── webapp-gunawan/       ← framework source
│   ├── .gunawan/         ← what Quinn copies
│   └── CLAUDE.md         ← Quinn reads this for context
└── santoso-protocol/     ← this repo (working directory)
    └── .gunawan/         ← copied here by Quinn (not committed to git)
```

Note: `.gunawan/` inside `santoso-protocol/` is created at runtime by Quinn.
It is not committed to git (it's in `.gitignore`). Re-running Step 0 always
gets the latest version from `webapp-gunawan`.

---

## 7. VPS Setup — Step-by-Step

### Prerequisites

- Ubuntu 22.04+ VPS (any provider)
- SSH access
- Domain or ngrok for public HTTPS (needed for Telegram webhook)
- Anthropic API key
- Telegram bot token + group chat ID

### Step 1 — Install Node.js 20

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version   # must be v20.x.x
```

### Step 2 — Install Claude Code

> **Note 1 — Verify package name before running:**
> The exact npm package name may differ from what's shown below. Before installing,
> run `npm search @anthropic claude-code` on your VPS to confirm the current
> published package name and version.

```bash
npm install -g @anthropic/claude-code
claude --version
```

### Step 3 — Install Paperclip

```bash
npx paperclipai onboard --yes
npx paperclipai start
# Dashboard: http://localhost:3100
# Keep this running in background (use tmux or pm2)
```

### Step 4 — Install Docker (optional but recommended)

```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
docker --version
```

### Step 5 — Clone the repo

```bash
git clone https://github.com/YOUR_ORG/gunawan-agentic-ai.git
cd gunawan-agentic-ai
```

### Step 6 — Configure environment

```bash
cd santoso-protocol
cp .env.example .env
nano .env
```

Fill in all 4 required values:

```
ANTHROPIC_API_KEY=sk-ant-...
TELEGRAM_BOT_TOKEN=123456789:AAF...
TELEGRAM_CHAT_ID=-1001234567890
WEBHOOK_URL=https://your-ngrok-or-domain-url
```

Leave `PAPERCLIP_API_URL=http://localhost:3100` as-is.

### Step 7 — Expose the bridge publicly

**Option A: ngrok (for the demo)**
```bash
# Install ngrok
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install ngrok
ngrok config add-authtoken YOUR_NGROK_TOKEN

# Start tunnel (run in separate terminal/tmux pane)
ngrok http 3200
# Copy the https URL → update WEBHOOK_URL in .env
```

**Option B: Caddy (permanent)**
```bash
sudo apt install -y caddy
# Edit /etc/caddy/Caddyfile:
# your-domain.com {
#     reverse_proxy localhost:3200
# }
sudo systemctl restart caddy
# Set WEBHOOK_URL=https://your-domain.com in .env
```

### Step 8 — Start the Telegram bridge

```bash
cd telegram-bridge
npm install
node index.js
```

Expected output:
```
[bridge] Santoso Telegram Bridge running on port 3200
[bridge] Paperclip API: http://localhost:3100
[bridge] Health check: http://localhost:3200/health
[bridge] Telegram webhook registered: https://your-url/telegram/webhook
```

### Step 9 — Run verification

```bash
cd ..   # back to santoso-protocol/
bash scripts/verify-setup.sh
```

Expected:
```
✔ Node.js 20.x.x
✔ npm 10.x.x
✔ .env file exists
✔ ANTHROPIC_API_KEY is set
✔ TELEGRAM_BOT_TOKEN is set
✔ TELEGRAM_CHAT_ID is set
✔ WEBHOOK_URL is set: https://...
✔ telegram-bridge/node_modules exists
✔ Paperclip is running at http://localhost:3100
⚠ Docker not found (optional for demo)

Gunawan AI Company — Setup verified. Ready for VPS deployment.
```

### Step 10 — Load agent prompts into Paperclip

In the Paperclip dashboard (`http://localhost:3100`):

1. Create a new project: **XLSMART Package Advisor**
2. For each of the 7 agents, create an agent configuration:
   - Agent name (Dharmawan, Gunawan, etc.)
   - Paste the contents of the corresponding `.claude/agents/*.md` file as the system prompt
   - Set the Claude model: `claude-sonnet-4-6` (default) or `claude-opus-4-6` for Quinn
3. Set the notification webhook for each agent:
   `http://localhost:3200/notify`

---

## 8. First Run Walkthrough

### Sending the first message to Santoso

In the **Gunawan HQ** Telegram group, send:

```
Hey Santoso. Our target client is PT XLSMART Telecom Sejahtera Tbk —
Indonesia's #2 telco, 330+ enterprise clients, 2025 strategy focused on
digitizing Indonesian SMEs.

The problem: SME owners don't know which XLSMART connectivity package fits
their business without calling a sales rep — leading to lost conversions.

We're building the XLSMART Package Advisor — a single-page tool where an
SME owner answers 3 questions and gets an AI-generated package recommendation.

Assign Task 1 to Dharmawan: research xlsmart.co.id/bisnis and produce
data/xlsmart-products.json. Go.
```

> **Note 4 — Semi-manual task assignment is intentional:**
> You manually tell Santoso "assign Task N to Agent X" between phases. This is
> by design for the demo — the audience sees you directing the company in real time,
> which makes the zero-human concept tangible. Automatic heartbeat routing (Santoso
> assigns the next task the moment the previous one closes) is a v2 optimization,
> not needed for the POC.

### What happens next

```
1. Bridge receives message → creates Paperclip issue
2. Bridge replies in Telegram: "✅ Santoso received. Issue #1 created."
3. You open Paperclip dashboard → assign Issue #1 to Dharmawan
4. Dharmawan runs → scrapes xlsmart.co.id → saves data/xlsmart-products.json
5. Dharmawan comments on issue: "6 categories, pricing not public"
6. Bridge posts to Telegram: "Dharmawan completed Task 1."

7. You message Santoso: "Assign Task 2 to Gunawan, Task 3 to Linawati. Go."
8. Gunawan reads xlsmart-products.json → builds recommendation matrix
9. Linawati reads xlsmart-products.json → writes marketing assets (parallel)

10. You message Santoso: "Assign Task 4 to Langston. Go."
11. Langston reads analysis → designs ui-spec.md

12. You message Santoso: "Assign Task 5 to Quinn. Go."
13. Quinn runs Step 0: cp -r ../webapp-gunawan/.gunawan ./.gunawan
14. Quinn scaffolds Next.js, builds 4 components + API route
15. Quinn reports: "npm run build passed. App running at localhost:3000"

16. You message Santoso: "Assign Task 6 to Hendrawan. Go."
17. Hendrawan tests 5 scenarios + mobile → test/test-report.md → PASS

18. You message Santoso: "Assign Task 7 to Alpha. Go."
19. Alpha deploys → configures ngrok/Caddy → posts live URL to Telegram

20. You message Santoso: "Assign Task 8 (Phase 2) to Linawati. Go."
21. Linawati updates marketing assets with live URL → posts LinkedIn post to Telegram
```

### Human approval gates

You manually trigger the next phase by messaging Santoso. You should review:

| Gate | What to check |
|------|--------------|
| After Dharmawan | Does `data/xlsmart-products.json` look complete? Min 6 products? |
| After Gunawan | Does `analysis/recommendation-matrix.md` cover all industries? |
| After Langston | Does `design/ui-spec.md` have all 7 sections? Component inventory complete? |
| After Quinn | Does `npm run build` pass? Does the wizard flow work at localhost:3000? |
| After Hendrawan | Does `test/test-report.md` show PASS? Any critical bugs outstanding? |
| Before Alpha | Are you ready to go live? Is the public URL configured? |

---

## 9. Budget & Time Estimates

### Per-agent cost

| Agent | Task | Est. cost |
|-------|------|-----------|
| Dharmawan | Research XLSMART products | $3–5 |
| Gunawan | Build recommendation matrix | $3–5 |
| Langston | Design 3-step wizard spec | $3–5 |
| Quinn | Build Next.js application | $10–15 |
| Hendrawan | Test 5 scenarios + mobile | $3–5 |
| Alpha | Deploy + configure public URL | $3–5 |
| Linawati | Phase 1 marketing assets | $3–5 |
| Linawati | Phase 2 URL update | $1–2 |
| **Total** | | **$29–47** |

### Time estimates

| Phase | Clock time | Your involvement |
|-------|-----------|-----------------|
| Research + Analysis (parallel) | ~20 min | ~2 min (assign tasks) |
| Design | ~10 min | ~2 min (review + assign) |
| Build | ~25 min | ~3 min (review build output) |
| Test | ~10 min | ~2 min (review report) |
| Deploy | ~10 min | ~2 min (confirm live URL) |
| Marketing final | ~5 min | ~1 min |
| **Total** | **~80 min** | **~12 min** |

---

## 10. Validation Checklist

Use this before deploying to VPS. Check off each item.

### Repo structure
- [ ] `SANTOSO-PROTOCOL-PROJECT.md` exists and is unmodified
- [ ] `CLAUDE.md` references `webapp-gunawan` as framework standard
- [ ] `.claude/settings.json` lists both protected files
- [ ] All 7 agent files exist in `.claude/agents/`
- [ ] `telegram-bridge/index.js` is present
- [ ] `telegram-bridge/package.json` lists `express` and `node-fetch`
- [ ] `telegram-bridge/Dockerfile.bridge` exists
- [ ] `Dockerfile` (multi-stage) exists in root
- [ ] `docker-compose.yml` defines `advisor` (3000) and `telegram-bridge` (3200)
- [ ] `.env.example` has all 5 env vars documented
- [ ] `.gitignore` excludes `.env`, `node_modules/`, `.next/`
- [ ] `scripts/verify-setup.sh` is present

### Agent prompts
- [ ] Dharmawan targets `xlsmart.co.id/bisnis`, outputs `data/xlsmart-products.json`
- [ ] Gunawan outputs `analysis/recommendation-matrix.md` with decision matrix + Claude API prompt
- [ ] Langston outputs `design/ui-spec.md`, does not write code
- [ ] Quinn has Step 0 (`cp -r ../webapp-gunawan/.gunawan ./.gunawan`)
- [ ] Quinn references `safeParse()` and TypeScript strict
- [ ] Hendrawan reads `.gunawan/qa-os/strategy.md`
- [ ] Alpha reads `.gunawan/deployment-os/`, waits for Hendrawan PASS
- [ ] Linawati has Phase 1 (parallel) and Phase 2 (after Alpha) clearly split

### Telegram bridge
- [ ] Bridge listens on port 3200
- [ ] `/telegram/webhook` creates Paperclip issues
- [ ] `/notify` sends messages to Telegram group
- [ ] `/health` returns status JSON
- [ ] Auto-registers Telegram webhook on startup when `WEBHOOK_URL` is set
- [ ] `TELEGRAM_CHAT_ID` filter prevents responding to other chats
- [ ] `node --check telegram-bridge/index.js` passes (no syntax errors)

### Scripts
- [ ] `bash -n scripts/verify-setup.sh` passes (no syntax errors)
- [ ] Script checks Node 20+, npm, .env, API keys, Paperclip, Docker

### webapp-gunawan integration
- [ ] `CLAUDE.md` `cp -r` command has correct relative path (`../webapp-gunawan/.gunawan`)
- [ ] Quinn's `quinn-engineer.md` has Step 0 as the first action
- [ ] Hendrawan references `.gunawan/qa-os/strategy.md`
- [ ] Alpha references `.gunawan/deployment-os/`
- [ ] `.gunawan/` is listed in `.gitignore` (created at runtime, not committed)

---

*End of Implementation & Validation Guide*
