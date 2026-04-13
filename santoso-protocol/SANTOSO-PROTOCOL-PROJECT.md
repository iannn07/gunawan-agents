# Gunawan AI Company — Project Declaration

> **Version:** 2.0 — April 2026
> **Status:** Active — Ready for VPS deployment
> **Orchestration:** Paperclip (paperclipai/paperclip)
> **Agents:** Claude Code instances
> **Communication:** Telegram Bot
> **Demo Target:** PT XLSMART Telecom Sejahtera Tbk
> **Demo Product:** XLSMART Package Advisor

---

## 1. What is the Gunawan AI Company?

The Gunawan AI Company is a **zero-human company** — a single founder (you, the Orchestrator) directing a team of AI agents that handle every function of a software company: research, analysis, design, engineering, QA, DevOps, and marketing/sales.

There are no human employees. The agents are Claude Code instances, each with a specialized role, system prompt, and tool access. They are coordinated by **Paperclip**, an open-source orchestration platform that manages org charts, goals, task assignment, budgets, and governance.

**The core idea:** You set a goal. Paperclip (acting as your manager, "Santoso") breaks it into tasks. Agents pick up tasks via heartbeats, execute autonomously, and report back. You make 2-3 key decisions along the way. The result is a deployed, marketed product — built from scratch in roughly 70 minutes.

---

## 2. Architecture

```
You (Orchestrator)
    │
    │  Telegram messages / Paperclip dashboard
    │
    ▼
┌─────────────────────────────────────────────┐
│  Santoso (Paperclip)                        │
│  ─ Org chart, goals, budgets, governance    │
│  ─ Task assignment via heartbeats           │
│  ─ Approval gates for sensitive actions     │
│  ─ Cost tracking per agent per task         │
└──────────────────┬──────────────────────────┘
                   │ heartbeats + task routing
                   ▼
┌─────────────────────────────────────────────┐
│  VPS (Ubuntu CLI)                           │
│  ─ Claude Code installed                    │
│  ─ Paperclip server (localhost:3100)        │
│  ─ Exposed via ngrok or private domain      │
│                                             │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐ │
│  │ Dharmawan │ │  Gunawan  │ │  Langston │ │
│  │Researcher │ │  Analyst  │ │  Designer │ │
│  └───────────┘ └───────────┘ └───────────┘ │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐ │
│  │   Quinn   │ │ Hendrawan │ │   Alpha   │ │
│  │ Engineer  │ │    QA     │ │  DevOps   │ │
│  └───────────┘ └───────────┘ └───────────┘ │
│  ┌───────────┐                              │
│  │ Linawati  │                              │
│  │Marketing  │                              │
│  └───────────┘                              │
│                                             │
│  Optional MCP integrations:                 │
│  ─ Supabase (if product needs a database)   │
│  ─ Notion (if project tracking needed)      │
│  ─ GitHub (if code repo needed)             │
└─────────────────────────────────────────────┘
```

### Key architectural decisions

- **Paperclip IS Santoso.** It is not a separate agent — it is the orchestration layer itself. Santoso is the name we give to the Paperclip system when communicating via Telegram.
- **No OpenClaw.** Paperclip replaces OpenClaw entirely. Paperclip uses Claude Code agents; it does not compete with them.
- **Telegram, not WhatsApp or Slack.** Telegram Bot API is free, instant to set up, and works perfectly with webhooks over ngrok.
- **MCP integrations are optional.** Add Supabase, Notion, or GitHub only when a specific project needs them. The base system works without any MCP servers.
- **Single VPS.** Everything runs on one Ubuntu server. No multi-server architecture needed.

---

## 3. The Team

### Santoso — Manager (Paperclip)

Santoso is not an agent — Santoso is the Paperclip orchestration system personified. When you send a message to the Telegram bot, you're talking to Santoso. When Paperclip assigns a task to an agent, that's Santoso delegating.

**Santoso's responsibilities:**
- Receive your goals and decompose them into tasks
- Assign tasks to the right agent based on their specialization
- Enforce task dependencies (Quinn can't build until Langston designs)
- Track budgets and alert you if an agent approaches its limit
- Send daily standup summaries to Telegram
- Escalate decisions to you when confidence is below 80%
- Report project completion with cost summary

### Dharmawan — Researcher

**Role:** First agent to activate on any new project. Gathers external information.

**What Dharmawan does:**
- Scrapes websites for product/competitor data
- Searches the web for market intelligence
- Reads and summarizes documents, PDFs, annual reports
- Structures raw data into JSON or markdown formats
- Produces research briefs stored in the project repo

**Output format:** JSON data files, markdown research briefs, structured catalogs.

**Tools:** Web search, web scraping, file system read/write.

**Budget guidance:** $3-5 per task.

### Gunawan — Analyst

**Role:** Takes Dharmawan's raw research and turns it into actionable analysis.

**What Gunawan does:**
- Builds feature comparison matrices
- Creates SWOT analyses
- Designs recommendation/decision logic (if industry=X and size=Y then product=Z)
- Writes Claude API prompt templates for AI-powered features
- Validates feasibility of product ideas

**Output format:** Markdown analysis documents, decision matrices, prompt templates.

**Tools:** File system read/write, reasoning over Dharmawan's output.

**Budget guidance:** $3-5 per task.

### Langston — Designer

**Role:** Creates UI specifications that Quinn can build from. Does not write code.

**What Langston does:**
- Designs page layouts and component structures
- Specifies user flows (step 1 → step 2 → step 3)
- Defines color schemes, typography, spacing
- Describes mobile responsive breakpoints
- References brand guidelines when provided

**Output format:** Markdown UI spec documents with detailed component descriptions.

**Tools:** File system read/write. Reads Dharmawan's and Gunawan's output for context.

**Budget guidance:** $3-5 per task.

**Important:** Langston describes the UI in words and structured specs. He does not produce images, Figma files, or runnable code. Quinn translates Langston's specs into code.

### Quinn — Engineer

**Role:** The builder. Writes all code. The heaviest workload in any project.

**What Quinn does:**
- Scaffolds Next.js projects from scratch
- Implements UI components from Langston's specs
- Integrates APIs (Claude API, Supabase, payment gateways, etc.)
- Writes database schemas and backend logic
- Implements responsive design
- Fixes bugs reported by Hendrawan
- Incorporates Linawati's marketing copy into the UI

**Output format:** Working code committed to the project directory. Runnable application.

**Tech stack (default):**
- Frontend: Next.js 14 + Tailwind CSS + shadcn/ui
- Backend: Supabase (when database needed) or API routes in Next.js
- AI: Claude API (via Anthropic SDK)
- Language: TypeScript (strict mode, no `any` types)

**Tools:** Claude Code (full file system access, terminal, package installation).

**Budget guidance:** $8-15 per task (engineering tasks are the most token-intensive).

### Hendrawan — QA

**Role:** Tests what Quinn builds. Reports bugs. Validates against Langston's specs.

**What Hendrawan does:**
- Tests the application with multiple user scenarios
- Validates each user flow against Langston's UI spec
- Checks mobile responsiveness
- Tests edge cases (empty inputs, long text, network errors)
- Files bug reports as Paperclip issues assigned to Quinn
- Re-tests after Quinn fixes bugs
- Produces a test report with pass/fail status

**Output format:** Markdown test reports, bug tickets in Paperclip.

**Tools:** Claude Code (can run the app, execute curl commands, inspect output).

**Budget guidance:** $3-5 per task.

### Alpha — DevOps

**Role:** Makes the product live. Handles deployment and infrastructure.

**What Alpha does:**
- Builds Docker containers (when appropriate)
- Deploys the application to the VPS
- Configures public URLs (via ngrok or domain)
- Sets up SSL certificates
- Configures environment variables
- Monitors application health after deployment
- Sets up CI/CD if GitHub integration is available

**Output format:** Running deployed service with a public URL.

**Tools:** Claude Code (terminal access, Docker, npm, system configuration).

**Budget guidance:** $3-5 per task.

### Linawati — Marketing/Sales

**Role:** Creates all marketing and sales materials. Closes the business loop.

**What Linawati does:**
- Writes hero headlines, subheadings, and CTA text for the product
- Drafts social media posts (LinkedIn, Twitter/X)
- Writes cold outreach emails to target clients
- Creates SEO meta tags (title, description, Open Graph)
- Drafts one-pager PDF pitches
- Writes product descriptions and value propositions
- Can work in parallel with other agents (only needs Dharmawan's research, not the finished product)

**Output format:** Markdown copy documents, JSON for SEO meta tags, email templates.

**Tools:** File system read/write. Reads Dharmawan's research for product context.

**Budget guidance:** $3-5 per task.

---

## 4. Installation Guide

### Prerequisites

- Ubuntu VPS (minimum: 4 vCPU, 8GB RAM, 100GB SSD)
- SSH access with a non-root user
- Node.js 20+ installed
- Claude Code installed and authenticated
- ngrok account (free tier works) or a private domain pointing to the VPS

### Step 1 — Verify the baseline

```bash
# Check Node.js
node --version
# Expected: v20.x.x or higher

# Check Claude Code
claude --version
# Expected: version string confirms installation

# Check npm
npm --version
```

If Node.js is missing:
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Step 2 — Install Paperclip

```bash
npx paperclipai onboard --yes
```

This does everything:
- Installs the Paperclip server
- Creates an embedded PostgreSQL database (no external DB setup needed)
- Starts the API + React dashboard at `http://localhost:3100`

To start Paperclip after reboots:
```bash
npx paperclipai start
```

### Step 3 — Expose Paperclip externally

**Option A: ngrok (quick, for demos)**
```bash
ngrok http 3100
```
Save the HTTPS URL (e.g., `https://abc123.ngrok-free.app`). This is your Paperclip dashboard URL.

**Option B: Private domain (permanent)**
Install Caddy as reverse proxy:
```bash
sudo apt install -y caddy
```
Configure `/etc/caddy/Caddyfile`:
```
your-domain.com {
    reverse_proxy localhost:3100
}
```
```bash
sudo systemctl restart caddy
```

### Step 4 — Create the Telegram bot

This is the ONLY step that requires your phone/Telegram app:

1. Open Telegram on your phone
2. Search for `@BotFather`
3. Send `/newbot`
4. Name: `Santoso`
5. Username: `santoso_gunawan_bot` (or any available username)
6. Copy the API token BotFather gives you
7. Create a Telegram group called `Gunawan HQ`
8. Add your Santoso bot to the group

Back on VPS:
```bash
export TELEGRAM_BOT_TOKEN='your-token-here'
```

### Step 5 — Set up the Telegram-Paperclip bridge

Tell Claude Code:
```
Set up a Telegram webhook bridge.
Bot token: [paste your TELEGRAM_BOT_TOKEN]
Webhook URL: [your ngrok/domain URL]/telegram/webhook
When I send a message in the Gunawan HQ group, create a Paperclip issue or comment.
When agents complete tasks or need approval, post updates to the Telegram group.
Use the Paperclip API at http://localhost:3100.
```

Claude Code will write a ~50-line Node.js bridge script and register the webhook.

### Step 6 — Configure agents in Paperclip

Open the Paperclip dashboard in your browser. Then:

1. Create a company: `Gunawan AI Company`
2. Add 7 agents via the UI:
   - Dharmawan (Researcher)
   - Gunawan (Analyst)
   - Langston (Designer)
   - Quinn (Engineer)
   - Hendrawan (QA)
   - Alpha (DevOps)
   - Linawati (Marketing/Sales)
3. Each agent uses Claude Code as the adapter
4. Set budget limits: $5/task for most agents, $15/task for Quinn
5. Configure heartbeat intervals (default is fine for demos)

### Step 7 — Smoke test

In the Telegram group, send:
```
Santoso, tell Dharmawan to research the top 3 project management tools and give me a comparison in JSON format.
```

Expected flow:
1. Santoso creates an issue in Paperclip
2. Assigns it to Dharmawan
3. Dharmawan wakes up on next heartbeat
4. Does the research
5. Posts result back to Telegram via the bridge

If this works, your entire Gunawan company is operational.

---

## 5. Demo Product — XLSMART Package Advisor

### The client

**PT XLSMART Telecom Sejahtera Tbk** (formerly XL Axiata)
- Indonesia's #2 telco operator
- 2024 gross revenue: Rp34.40 trillion (6% YoY growth)
- 2024 net profit: Rp1.85 trillion (45% YoY growth)
- Enterprise business grew 27% YoY with 43% new contracts
- XL Satu Biz (SME product): 20,000+ clients acquired in 2024
- Brands: XL, Smartfren, Axis, XL Prioritas, XL SATU
- Enterprise arm: XLSMART for BUSINESS — serves 330+ industries
- 2025 strategy: "drive digitization across the customer journey" and "adopt AI to automate processes"

### The problem

XLSMART for BUSINESS sells multiple enterprise products: XL Satu Biz (SME connectivity), Internet Corporate, Smart Transportation, Smart Manufacture, Smart City, and Private Network. But an SME owner in Surabaya doesn't know which package fits their restaurant, factory, or logistics company. Currently they have to call a sales rep, explain their business, and wait for a recommendation. That takes days.

### The product

**XLSMART Package Advisor** — a single-page web tool where an SME owner answers 3 questions and gets a personalized package recommendation powered by AI.

**How it works:**
1. **Step 1 — Industry:** User selects their industry from a grid of clickable cards (F&B, retail, manufacturing, logistics, office/corporate, agriculture, healthcare, etc.)
2. **Step 2 — Profile:** User enters business size (employee count slider) and selects their needs (checkboxes: internet connectivity, IoT monitoring, fleet tracking, smart building, etc.)
3. **Step 3 — Result:** AI analyzes the profile and recommends the best XLSMART package with reasoning. Shows a comparison card with features and a "Contact Sales via Telegram" CTA.

**Tech stack:**
- Next.js 14 (single page, static export possible)
- Tailwind CSS + shadcn/ui for styling
- Claude API for intelligent recommendation logic
- Product data from xlsmart-products.json (scraped by Dharmawan)
- Deployed on the same VPS via Alpha

**What makes this a good demo product:**
- Small enough to build live (~70 minutes total agent work)
- Shows ALL 7 agents working in sequence and parallel
- Uses real AI (Claude API) — not just static HTML
- Directly relevant to XLSMART's stated 2025 strategy
- Linawati's marketing materials close the zero-human company loop

---

## 6. Sprint Plan — The Task Chain

### Phase 1 — Product discovery (you + Santoso, 30 min)

**Your first message to Santoso:**
```
Hey Santoso. Our target client is PT XLSMART Telecom Sejahtera Tbk —
Indonesia's #2 telco. They have an enterprise arm called XLSMART for
BUSINESS that sells connectivity packages to SMEs (XL Satu Biz,
Internet Corporate, Smart Transportation, Smart Manufacture, etc).

The problem: SME owners don't know which package fits their business.

We're building the XLSMART Package Advisor — a single-page web tool
where an SME owner answers 3 questions and gets a personalized
package recommendation.

Dharmawan should start by researching their products from
xlsmart.co.id/bisnis. Go.
```

Santoso creates the project with 7 tasks and assigns Dharmawan.

### Phase 2 — Research + analysis (20 min)

| Task | Agent | Input | Output | Budget |
|------|-------|-------|--------|--------|
| Research XLSMART products | Dharmawan | URL: xlsmart.co.id/bisnis + sub-pages | `xlsmart-products.json` — 6 categories, 12+ variants with features, pricing, target industries | $5 |
| Build recommendation logic | Gunawan | xlsmart-products.json | `recommendation-matrix.md` — decision tree + Claude API prompt template | $5 |
| Draft marketing copy | Linawati (parallel) | xlsmart-products.json | `marketing-assets/` — hero copy, LinkedIn post, cold email, SEO meta tags | $5 |

**Dependencies:** Gunawan depends on Dharmawan. Linawati depends on Dharmawan. Gunawan and Linawati run in parallel.

### Phase 3 — Design + build + test + deploy (40 min)

| Task | Agent | Input | Output | Budget |
|------|-------|-------|--------|--------|
| Design the UI | Langston | Product catalog + recommendation logic | `ui-spec.md` — 3-step wizard layout, component specs, brand colors, mobile breakpoints | $5 |
| Build the application | Quinn | ui-spec.md + recommendation-matrix.md + products JSON + marketing copy | Working Next.js app with wizard, Claude API, result cards, responsive design | $15 |
| Test the application | Hendrawan | Running app | `test-report.md` — 5 business profiles tested, mobile checked, bugs filed | $5 |
| Deploy to production | Alpha | Tested app | Live public URL, SSL configured, health verified | $5 |

**Dependencies:** Langston depends on Gunawan. Quinn depends on Langston. Hendrawan depends on Quinn. Alpha depends on Hendrawan. (If Hendrawan finds bugs, Quinn fixes them before Alpha deploys.)

### Phase 4 — Market + launch (10 min)

| Task | Agent | Input | Output | Budget |
|------|-------|-------|--------|--------|
| Finalize marketing materials | Linawati | Live URL + all previous context | Updated LinkedIn post with URL, finalized email, one-pager PDF, summary to Telegram | $5 |

**Dependency:** Linawati's final task depends on Alpha's deployment.

### Total estimates

- **Agent work time:** ~70 minutes
- **Your involvement:** ~10 minutes (sending the initial goal + 2-3 approval decisions)
- **Total budget:** ~$50 (conservative estimate)
- **Output:** Live deployed web app + full marketing package

---

## 7. How to Monitor Progress

### Three layers of visibility

**Layer 1 — Paperclip dashboard (primary monitoring)**
- Goal and task status: todo → in-progress → done
- Agent activity: who's running, what they're working on, cost per run
- Run history: full transcript of every agent session
- Budget tracking: spend per agent and per project
- Issue timeline: comments, status changes, handoffs

**Layer 2 — Agent run logs (detailed)**
- Every Claude Code session produces a full transcript
- See exact commands executed, files created, APIs called
- Code diffs: see exactly what Quinn wrote
- Error traces for debugging when something fails

**Layer 3 — Telegram notifications (mobile)**
- Task started: "Dharmawan picked up Task 1: Research XLSMART products"
- Task completed: "Gunawan finished analysis. Recommendation matrix ready."
- Approval needed: "Quinn's app is ready. Alpha wants to deploy. Reply APPROVE."
- Daily standup: Santoso sends a morning summary of all tasks
- Budget alert: "Quinn approaching $15 budget on Task 4"

---

## 8. Sprint Ceremonies (Gunawan Style)

### Daily standup (automated)

Configure a Paperclip routine that runs at 09:00 WIB daily. Each agent posts a status update on their current task. The Telegram bridge aggregates these into one message:

```
09:00 Standup Summary:
• Dharmawan: Completed XLSMART product research. No blockers.
• Quinn: Working on wizard step 2/3. Waiting for Langston's result card spec.
• Hendrawan: Idle — waiting for Quinn.
• Linawati: LinkedIn post drafted. Waiting for live URL.
```

### Sprint planning (you + Paperclip)

You create the goal in Paperclip. For each task, set: assigned agent, priority, budget, dependencies, and approval gates. This IS the sprint plan. Santoso handles the scheduling — agents pick up tasks when dependencies are met.

### Sprint review (live walkthrough)

When all tasks complete, you open the deployed product and verify it works. Check the Paperclip dashboard for total cost, time taken, and Hendrawan's test report. This is the moment you demo to stakeholders.

### Retrospective (async via Telegram)

After the demo, send: "Retro time. Each agent: what went well, what was slow, what should change?" Each agent posts a retro comment on their next heartbeat. You read the feedback and adjust system prompts or task structures for the next project.

---

## 9. Demo Script for XLSMART Audience (30 minutes)

### Act 1 — The problem (5 min)

"XLSMART acquired 20,000 SME clients via XL Satu Biz in 2024 — 43% new contracts. Your 2025 strategy says 'drive digitization across the customer journey' and 'adopt AI to automate processes.' But right now, an SME owner who wants your product has to call sales and wait days. What if it took 10 minutes and required zero sales reps?"

### Act 2 — The Gunawan demo (15 min)

Show, don't tell.

1. Open the Paperclip dashboard. Show the completed project: 7 tasks, all green, costs tracked.
2. Open the Telegram conversation. Scroll through the history: your initial message to Santoso, Dharmawan's research completion, Quinn building the app, Alpha deploying it.
3. Click the live URL. Walk through the XLSMART Package Advisor: select "Restaurant" as industry, 30 employees, needs "Internet + POS connectivity." Watch the AI recommend XL Satu Biz with reasoning.
4. Show Linawati's marketing output: the LinkedIn post, the cold email, the one-pager.

### Act 3 — The value proposition (10 min)

"Traditional build: 6-12 months, Rp500M-1.5B, 5-10 developers. Gunawan build: 70 minutes, ~Rp800K in API costs, zero developers. This same system can build your IoT monitoring dashboard, your Smart City portal, your enterprise customer analytics. What do you want to build first?"

---

## 10. What's NOT in Scope

To keep expectations clear, here's what the Gunawan system does NOT do:

- **No OpenClaw.** Removed per manager's directive. Paperclip handles all orchestration.
- **No WhatsApp integration.** Using Telegram instead (free, faster to set up).
- **No Obsidian required.** Knowledge is stored in the project repo and Paperclip issues. Add Obsidian MCP later if needed.
- **No multi-VPS deployment.** Everything runs on one server.
- **No continuous agent runtime.** Agents run on Paperclip heartbeats (scheduled intervals), not 24/7. This is cost-efficient and sufficient for demo purposes.
- **No BizConnect.** The original full SME portal scope was too large for a live demo. We descoped to the Package Advisor — a single-page tool that demonstrates the same agent lifecycle in ~70 minutes instead of 22 days.

---

## 11. File Structure (expected after a project completes)

```
project-root/
├── data/
│   └── xlsmart-products.json       # Dharmawan's research output
├── analysis/
│   └── recommendation-matrix.md     # Gunawan's analysis output
├── design/
│   └── ui-spec.md                   # Langston's design output
├── marketing-assets/
│   ├── hero-copy.md                 # Linawati's landing copy
│   ├── linkedin-post.md             # Linawati's social post
│   ├── cold-email.md                # Linawati's outreach email
│   ├── seo-meta.json                # Linawati's SEO tags
│   └── one-pager.md                 # Linawati's pitch document
├── test/
│   └── test-report.md               # Hendrawan's test results
├── src/                             # Quinn's application code
│   ├── app/
│   │   └── page.tsx                 # Main advisor page
│   ├── components/
│   │   ├── IndustrySelector.tsx
│   │   ├── BusinessProfile.tsx
│   │   └── RecommendationResult.tsx
│   └── lib/
│       ├── xlsmart-products.ts      # Product data loader
│       └── recommend.ts             # Claude API recommendation logic
├── package.json
├── tailwind.config.ts
├── next.config.js
├── Dockerfile                       # Alpha's deployment config
└── README.md                        # Project documentation
```

---

## 12. Success Criteria

The demo is successful when:

1. **Product works:** The XLSMART Package Advisor is live at a public URL. An SME owner can complete the 3-step flow and receive a sensible recommendation.
2. **Full lifecycle visible:** The Paperclip dashboard shows all 7 tasks completed, with agent run histories and cost tracking.
3. **Telegram trail:** The Telegram conversation in Gunawan HQ shows the complete conversation between you and Santoso, from initial goal to final deployment.
4. **Marketing materials exist:** Linawati produced at least: LinkedIn post, cold email, and SEO meta tags.
5. **Total time under 90 minutes:** From your first message to Santoso to the live deployed URL.
6. **Total cost under $60:** All agent API costs combined.
7. **Your involvement under 15 minutes:** You sent the initial goal, made 2-3 decisions, and approved the final product. Everything else was autonomous.

---

*This document is the single source of truth for the Gunawan AI Company project. All agents, configurations, and expectations derive from here. When in doubt, refer to this file.*
