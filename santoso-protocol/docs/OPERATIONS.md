# Gunawan Operations Runbook

> Live state of the Paperclip/Santoso stack on this VPS, how to run it, and how to talk to Gunawan via Telegram. Last updated: 2026-04-14.

---

## 1. What's installed

### Paperclip (Santoso)
- **Installed globally:** `paperclipai@2026.403.0` at `/home/santoso/.nvm/versions/node/v24.14.1/bin/paperclipai`. No longer dependent on the npx cache.
- **Instance data:** `~/.paperclip/instances/default/` (embedded Postgres, secrets, config, logs — all persistent).
- **Config highlights** (`~/.paperclip/instances/default/config.json`):
  - API + dashboard on `127.0.0.1:3100`
  - Embedded Postgres on `127.0.0.1:54329`
  - Deployment mode: `local_trusted` (local callers are treated as board)
  - Backups: hourly, 30-day retention

### Patches applied to the global install
The upstream `AGENT_ROLES` enum only had `researcher` / `designer` / `qa` / `devops` / `engineer` — no `analyst` or `marketing`. We added both:

- `…/paperclipai/dist/index.js` (CLI bundle) — added `analyst`, `marketing` to `AGENT_ROLES`.
- `…/paperclipai/node_modules/@paperclipai/shared/dist/constants.js` (server validator, authoritative) — added `analyst`, `marketing` to `AGENT_ROLES` **and** matching `"Analyst"` / `"Marketing"` to `AGENT_ROLE_LABELS`.

⚠️ If `paperclipai` is ever re-installed or upgraded, both patches must be re-applied, or any PATCH that touches `role=analyst|marketing` will be rejected by the zod validator.

### Company & org chart (`Gunawan Santoso Corp`, id `2822e5f8-455f-4576-8b82-4cabdda1903e`)

| Agent | Role | Title | Budget/mo | reportsTo | Agent ID |
|---|---|---|---|---|---|
| Santoso | ceo | — | — | (root) | `84514569-645a-4acc-9501-188ac9c12aa5` |
| Dharmawan | researcher | — | $5 | Santoso | `5ffb7533-7c6c-4da0-ab87-ff498fb5272f` |
| Gunawan | analyst | Analyst | $5 | Santoso | `7c480932-6191-47a7-8f23-ca2bdfdfb61d` |
| Langston | designer | — | $5 | Santoso | `fb4abbfb-d0d2-4968-9183-5f62932fbf84` |
| Quinn | engineer | — | $15 | Santoso | `56ba505a-8b2c-491b-9666-0149ad7743e1` |
| Hendrawan | qa | — | $5 | Santoso | `ecbbeab9-2a51-4e4d-836a-5027fe63a3a6` |
| Alpha | devops | — | $5 | Santoso | `2bd86174-7d39-4fe0-b76a-73a5f34d0ea6` |
| Linawati | marketing | Marketing | $5 | Santoso | `2bb84070-2b33-4e58-b650-9fa1115cab24` |

All agents use adapter `claude_local` / model `claude-sonnet-4-6`. Budget values are monthly caps in Paperclip (the protocol's per-task figures mapped as monthly — bump if agents run >1 task/mo).

### Quinn ↔ webapp-gunawan framework
- **Symlink:** `santoso-protocol/.gunawan → ../webapp-gunawan/.gunawan` (live — framework changes flow through instantly).
- **Quinn's cwd:** `adapterConfig.cwd = /home/santoso/gunawan-agents/santoso-protocol`. Every heartbeat run starts in the protocol project, so relative paths in his managed `AGENTS.md` resolve (`.gunawan/foundation/…`, `../webapp-gunawan/CLAUDE.md`, `design/ui-spec.md`, `analysis/recommendation-matrix.md`, `data/xlsmart-products.json`).
- **Other agents:** no `cwd` set yet — consider setting them to the same path if you want Langston/Dharmawan/etc. outputs to land in the protocol tree.

---

## 2. Services and how to run them

| Service | Purpose | Port | Status as of last check |
|---|---|---|---|
| Paperclip | Orchestration, API, dashboard, embedded Postgres | 3100 (API/UI), 54329 (DB) | Running in tmux `paperclipai-session` |
| ngrok | Public HTTPS tunnel to Paperclip | — → 3100 | Running on a loose terminal; current URL: `https://04f9-2407-3640-2322-9394-00-1.ngrok-free.app` |
| telegram-bridge | Relays Telegram ↔ Paperclip | 3200 | **Not running** |

### Paperclip
```bash
# Attach to live logs
tmux attach -t paperclipai-session

# Cold start (idempotent — safe to re-run after reboot)
paperclipai onboard --yes

# Normal restart after Paperclip is already onboarded
paperclipai start

# Stop — inside the tmux session
Ctrl+C
# Or from outside
kill $(lsof -ti :3100)

# Health check
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:3100/   # expect 200
paperclipai company list
paperclipai agent list -C 2822e5f8-455f-4576-8b82-4cabdda1903e
```

### ngrok
Free-tier URLs **rotate on every restart** — if you restart ngrok, update `WEBHOOK_URL` in `.env` and re-register the Telegram webhook.
```bash
# Start (preferably in its own tmux session)
tmux new -d -s ngrok 'ngrok http 3100'

# Get the current public URL
curl -s http://127.0.0.1:4040/api/tunnels \
  | python3 -c "import json,sys;print(json.load(sys.stdin)['tunnels'][0]['public_url'])"

# Stop
kill $(pgrep -f 'ngrok http 3100')
```

### Telegram bridge
```bash
cd /home/santoso/gunawan-agents/santoso-protocol

# Start in a dedicated tmux session (loads .env, runs npm start on :3200)
tmux new -d -s bridge \
  'cd /home/santoso/gunawan-agents/santoso-protocol && set -a && source .env && set +a && cd telegram-bridge && npm start'

# Watch logs
tmux attach -t bridge

# Stop
tmux kill-session -t bridge

# Verify it's listening
lsof -i :3200
```

### One-shot health check
```bash
cd /home/santoso/gunawan-agents/santoso-protocol && ./scripts/verify-setup.sh
```

### Cold-boot order (after a reboot)
1. `tmux new -d -s paperclipai-session 'paperclipai start'`
2. `tmux new -d -s ngrok 'ngrok http 3100'`
3. Get the new ngrok URL and update `WEBHOOK_URL` in `.env` if it changed.
4. `tmux new -d -s bridge '…bridge startup line above…'`
5. Verify:
   - `curl -s http://127.0.0.1:3100/` → 200
   - `curl -s http://127.0.0.1:4040/api/tunnels` → tunnel active
   - `lsof -i :3200` → bridge listening
   - `curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getWebhookInfo"` → `url` field matches your ngrok URL + `/telegram/webhook`

---

## 3. Talking to Gunawan via Telegram

The flow once everything is up:

1. Open the **`Gunawan HQ`** Telegram group (the one the `@Santoso` bot is a member of).
2. Send a goal, addressed to Santoso. Example (straight from the protocol doc):
   > Hey Santoso. Our target client is PT XLSMART Telecom Sejahtera Tbk. We're building the XLSMART Package Advisor — a single-page tool where an SME owner answers 3 questions and gets a personalized package recommendation. Dharmawan should start by researching their products from xlsmart.co.id/bisnis. Go.
3. The bridge posts `POST $PAPERCLIP_API_URL/api/issues` with title=first line, body=full message. An issue appears in `Gunawan Santoso Corp`.
4. Santoso (Paperclip) breaks it down and assigns to the right agent.
5. Agents pick up tasks on their heartbeat (default 1h, wake-on-demand enabled). Each runs via `claude_local` in its own Claude Code session under the configured `cwd`.
6. Agent updates flow back to the Telegram group via the bridge.
7. Approvals gate sensitive actions. When Santoso escalates ("Quinn wants to deploy — APPROVE?"), reply in the group with `APPROVE` or `REJECT`; the bridge routes it to `/api/approvals/:id/approve` or `/reject`.

### Sanity checks before your first message
- [ ] ngrok URL in `.env WEBHOOK_URL` matches the live tunnel.
- [ ] `lsof -i :3200` shows the bridge listening.
- [ ] `getWebhookInfo` on Telegram returns the right `url`.
- [ ] `paperclipai agent list -C 2822e5f8-455f-4576-8b82-4cabdda1903e` shows all 8 agents (Santoso + 7 specialists), all reporting to Santoso.

---

## 4. Open items (flagged, not done)

- **Santoso's `status=error`** in Paperclip. Worth digging into the run logs before depending on him routing tasks.
- **Other agents have no `cwd`.** Only Quinn is pinned to `santoso-protocol/`. Consider setting the same for Langston/Dharmawan/Hendrawan/Alpha/Linawati/Gunawan so their outputs land in `design/`, `data/`, `analysis/`, `test/`, `marketing-assets/` under the protocol tree.
- **`webapp-gunawan/.claude/agents/` doesn't exist.** `santoso-protocol/CLAUDE.md` tells agents to `cp -r ../webapp-gunawan/.claude/agents ./.claude/agents-framework`, which would fail if run literally. Either add the directory to webapp-gunawan or update the instruction.
- **Patches are not a package.** If `paperclipai` is re-installed, the `AGENT_ROLES` enum + label patches must be re-applied. A small post-install wrapper would make this automatic.
