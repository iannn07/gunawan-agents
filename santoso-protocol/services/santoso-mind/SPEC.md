# santoso-mind — Engineering brief

> **Engineer:** Quinn
> **Reviewer:** the board (via Santoso's narration + Claude Code review)
> **Status:** SPEC drafted Phase 0; implementation queued for Phase 1
> **Stack:** Node.js 20 + TypeScript + better-sqlite3 + `@modelcontextprotocol/sdk`
> **Dockerfile base:** `node:20-slim` (matches the Paperclip image — needs glibc for native bindings)

You are building **the brain** for Santoso, the CEO of Gunawan Santoso Corp. Santoso is currently a static prompt with no memory and no learning loop. This service makes him persistent.

The full architectural rationale is in the project plan at `~/.claude/plans/nested-knitting-pine.md` (Pillars 2–5). This spec is the implementation contract.

---

## 1. Operating modes

`santoso-mind` runs as one Node process that picks its mode from the first CLI argument:

| Mode | What it does | Where it runs |
|---|---|---|
| `mcp` | Stdio MCP server exposing the tools below | **Sidecar container** in the Paperclip pod (so claude inside the pod can reach it via stdio) |
| `reflection-consumer` | Polls Paperclip for closed issues, writes reflection entries to DB + markdown | **Separate Deployment** (`santoso-mind` Deployment) |
| `anticipation-loop` | Periodic scan + Santoso wake-up trigger | Same separate Deployment, second container or second mode in the same container |
| `migrate` | Runs SQLite migrations idempotently and exits | Init container or one-off Job |

Single binary, multiple modes. Keeps the image simple.

---

## 2. Layout

```
services/santoso-mind/
├── Dockerfile
├── package.json
├── tsconfig.json
├── README.md                         # short — points at SPEC.md
├── src/
│   ├── index.ts                      # mode dispatcher
│   ├── config.ts                     # env vars, paths, defaults
│   ├── db/
│   │   ├── connection.ts             # better-sqlite3 singleton
│   │   ├── schema.sql                # create-table statements
│   │   └── migrate.ts                # idempotent migrations runner
│   ├── memory/
│   │   ├── store.ts                  # CRUD for memory_entries, level-gated
│   │   └── search.ts                 # FTS5 query, optional vector behind feature flag
│   ├── reflections/
│   │   ├── consumer.ts               # Paperclip event poller
│   │   ├── template.ts               # reflect-task skill template renderer
│   │   ├── classifier.ts             # pattern | postmortem | observation
│   │   └── markdown.ts               # writes to docs/knowledge/reflections/
│   ├── anticipation/
│   │   ├── loop.ts                   # periodic scanner
│   │   ├── signals.ts                # signal detectors (stalled, repeated-failure, etc.)
│   │   └── wakeup.ts                 # POSTs /api/agents/<id>/wakeup with a synthesised prompt
│   ├── state/
│   │   └── maturity.ts               # reads/writes .claude/roles/active.md (PVC)
│   ├── metrics/
│   │   └── tracker.ts                # rework rate, defect escape, reflection quality, etc.
│   ├── mcp/
│   │   ├── server.ts                 # stdio MCP server bootstrap
│   │   └── tools.ts                  # tool registrations + Zod input schemas
│   └── lib/
│       ├── paperclip.ts              # tiny Paperclip API client (fetch wrapper)
│       └── log.ts                    # structured logger
└── test/
    ├── memory.test.ts
    ├── reflections.test.ts
    ├── anticipation.test.ts
    ├── state.test.ts
    └── mcp-roundtrip.test.ts
```

---

## 3. Configuration (env vars)

| Var | Default | Purpose |
|---|---|---|
| `MIND_DB_PATH` | `/home/node/.paperclip/instances/default/data/santoso-mind.db` | SQLite file (lives on the Paperclip PVC so it's persistent) |
| `MIND_REFLECTIONS_DIR` | `/home/node/.paperclip/instances/default/data/knowledge/reflections` | Markdown output (mirrored into the project repo via a sync — see §10) |
| `PAPERCLIP_API_URL` | `http://paperclip.gunawan.svc.cluster.local:3100` | Cluster-internal Paperclip API |
| `PAPERCLIP_COMPANY_ID` | `2822e5f8-455f-4576-8b82-4cabdda1903e` | Hardcoded for now (single-company) |
| `PAPERCLIP_CEO_AGENT_ID` | `84514569-645a-4acc-9501-188ac9c12aa5` | Santoso's agent id |
| `BRIDGE_NOTIFY_URL` | `http://telegram-bridge.gunawan.svc.cluster.local:3200/notify` | For `narration.beat` MCP tool |
| `MIND_LOOP_INTERVAL_SEC` | `1800` | Anticipation cadence (default 30 min) |
| `MIND_REFLECTION_POLL_SEC` | `30` | Reflection consumer poll interval |
| `MIND_LOG_LEVEL` | `info` | `debug` / `info` / `warn` / `error` |
| `MIND_FEATURE_VECTOR_SEARCH` | `false` | Phase 4+ |

All read via `src/config.ts` with a Zod schema. Fail fast on missing required vars.

---

## 4. Database schema (SQLite)

Use `better-sqlite3` with `journal_mode=WAL`. All DDL in `src/db/schema.sql`:

```sql
CREATE TABLE IF NOT EXISTS memory_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tier TEXT NOT NULL CHECK(tier IN ('working','project','organizational')),
  agent_id TEXT NOT NULL,
  kind TEXT NOT NULL CHECK(kind IN ('pattern','anti-pattern','decision','observation','lesson')),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  tags TEXT,                          -- comma-separated
  source_issue_id TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_memory_tier_agent ON memory_entries(tier, agent_id);
CREATE INDEX IF NOT EXISTS idx_memory_source ON memory_entries(source_issue_id);

-- Full-text search over memory
CREATE VIRTUAL TABLE IF NOT EXISTS memory_fts USING fts5(
  title, body, tags,
  content='memory_entries',
  content_rowid='id'
);
-- Triggers to keep FTS in sync
CREATE TRIGGER IF NOT EXISTS memory_fts_ai AFTER INSERT ON memory_entries BEGIN
  INSERT INTO memory_fts(rowid, title, body, tags) VALUES (new.id, new.title, new.body, new.tags);
END;
CREATE TRIGGER IF NOT EXISTS memory_fts_ad AFTER DELETE ON memory_entries BEGIN
  INSERT INTO memory_fts(memory_fts, rowid, title, body, tags) VALUES('delete', old.id, old.title, old.body, old.tags);
END;
CREATE TRIGGER IF NOT EXISTS memory_fts_au AFTER UPDATE ON memory_entries BEGIN
  INSERT INTO memory_fts(memory_fts, rowid, title, body, tags) VALUES('delete', old.id, old.title, old.body, old.tags);
  INSERT INTO memory_fts(rowid, title, body, tags) VALUES (new.id, new.title, new.body, new.tags);
END;

CREATE TABLE IF NOT EXISTS reflections (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  issue_id TEXT NOT NULL,
  agent_id TEXT NOT NULL,
  expected TEXT,
  actual TEXT,
  what_worked TEXT,
  what_failed TEXT,
  root_cause TEXT,
  missing_context TEXT,
  assumption_errors TEXT,
  proposed_improvement TEXT,
  classification TEXT NOT NULL CHECK(classification IN ('pattern','postmortem','observation')),
  quality_score INTEGER,              -- 0..3, set by classifier
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_reflections_agent ON reflections(agent_id);
CREATE INDEX IF NOT EXISTS idx_reflections_issue ON reflections(issue_id);

CREATE TABLE IF NOT EXISTS metrics (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  agent_id TEXT NOT NULL,
  period_start TEXT NOT NULL,
  period_end TEXT NOT NULL,
  tasks_completed INTEGER DEFAULT 0,
  rework_count INTEGER DEFAULT 0,
  defect_escape_count INTEGER DEFAULT 0,
  reflections_filed INTEGER DEFAULT 0,
  knowledge_contributions INTEGER DEFAULT 0,
  escalations_appropriate INTEGER DEFAULT 0,
  escalations_avoidable INTEGER DEFAULT 0,
  narration_completeness REAL,        -- 0.0..1.0
  assumption_error_count INTEGER DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_metrics_agent_period ON metrics(agent_id, period_start, period_end);

CREATE TABLE IF NOT EXISTS maturity_state (
  agent_id TEXT PRIMARY KEY,
  level INTEGER NOT NULL DEFAULT 0,
  capability_profile TEXT NOT NULL DEFAULT 'jarvis-fresh-boot',
  promoted_at TEXT,
  promoted_by TEXT
);
-- Note: agent_name is intentionally NOT stored here. Santoso is always Santoso.

CREATE TABLE IF NOT EXISTS anticipation_signals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  kind TEXT NOT NULL,
  evidence TEXT NOT NULL,             -- JSON
  severity TEXT NOT NULL CHECK(severity IN ('info','warn','urgent')),
  raised_at TEXT NOT NULL DEFAULT (datetime('now')),
  addressed_at TEXT
);
CREATE INDEX IF NOT EXISTS idx_signals_unaddressed ON anticipation_signals(addressed_at) WHERE addressed_at IS NULL;
```

`migrate.ts` runs this schema as a single transaction at startup. Idempotent — `CREATE TABLE IF NOT EXISTS` everywhere.

---

## 5. MCP tools

All tools are registered in `src/mcp/tools.ts`. Each input is validated with `safeParse` against a Zod schema. Each tool returns a typed result.

| Tool name | Input schema (TypeScript) | Returns |
|---|---|---|
| `memory.search` | `{ query: string, tier?: 'working'\|'project'\|'organizational', agent_id?: string, limit?: number (default 10) }` | `{ entries: MemoryEntry[], count: number }` — uses FTS5 BM25 ranking |
| `memory.write` | `{ tier, agent_id, kind, title, body, tags?, source_issue_id? }` | `{ id: number, tier, created_at }` — **rejects** if caller's `agent_id` has a `maturity_level` that disallows the requested tier (see level table in `agents/ceo/responsibilities.md`) |
| `reflection.add` | `{ issue_id, agent_id, expected, actual, what_worked, what_failed, root_cause, missing_context?, assumption_errors?, proposed_improvement? }` | `{ id, classification, quality_score }` — also writes a markdown file to `MIND_REFLECTIONS_DIR` |
| `state.get` | `{ agent_id }` (defaults to Santoso) | The full row from `maturity_state` plus a `level_name` derived field |
| `state.set` | `{ agent_id, level: 0..5, promoted_by: string }` | New state — **rejects** if `promoted_by` is empty/missing or if the level transition is non-sequential (skipping more than one step). The `name: "Santoso"` is implicit and never settable. |
| `metrics.report` | `{ agent_id?, period?: '24h'\|'7d'\|'30d' }` (defaults: Santoso, 7d) | Performance record per the `agent-performance.md` template |
| `roster.list` | `{}` | Array of `{ id, name, role, status, level, capability_profile }` for all 8 agents |
| `narration.beat` | `{ text: string, kind?: 'receipt'\|'processing'\|'output'\|'anticipation' }` | `{ ok: true, beat_id }` — wraps a POST to `BRIDGE_NOTIFY_URL`, also inserts a working-memory entry tagged `narration:<kind>` so the reflection consumer can audit completeness |

### Level gating for `memory.write`

```
working          → all levels
project          → level >= 2 (Child/VISION)
organizational   → level >= 3 (Adolescent/FRIDAY) AND must go via improvement-proposals first
```

The tool reads the caller's level from `maturity_state` (NOT from the request — the caller cannot lie about their level). If the level is too low, return an error result with the rule cited.

### Level gating for `state.set`

The MCP server has no concept of "who called it" beyond the `agent_id` argument. So the gating is purely on the **content** of the call:

- `promoted_by` must be a non-empty string. The bridge will set it to the Telegram username of whoever ran `/promote`.
- `level` must be `current_level + 1` (promotion) or `current_level - 1` (demotion). Refuse skip-levels.
- The board has out-of-band override: a manual `state.set` from inside the pod via curl with `promoted_by: "manual-override-<reason>"` is allowed (logged loudly) for emergencies.

---

## 6. Reflection consumer

Polls `GET /api/companies/<id>/issues?status=closed&since=<cursor>` every `MIND_REFLECTION_POLL_SEC` seconds. Cursor stored in a `_cursors` table.

For each newly-closed issue:

1. Fetch the issue's run output via `GET /api/heartbeat-runs/<runId>/log` (the run id is on the issue's `lastRunId` field).
2. Render the reflect-task template against `{title, description, output, comments, assignee}`.
3. Run the classifier:
   - **pattern** — task closed successfully on first attempt, no rework, useful artefact
   - **postmortem** — task failed, was rejected, or required rework
   - **observation** — neutral closure, nothing remarkable
4. Insert a row in `reflections`. Compute `quality_score`:
   - 3: all required fields populated, root cause present, proposed improvement actionable
   - 2: most fields populated, root cause present
   - 1: minimal fields populated
   - 0: empty or boilerplate (counts as a missing reflection)
5. Write the markdown file `REFLECTION-<YYYY-MM-DD>-<issue-slug>.md` to `MIND_REFLECTIONS_DIR`.
6. Update the assigned agent's `metrics` row for the current period.
7. If the metrics cross a promotion threshold, raise an `anticipation_signals` entry of kind `promotion_eligible` with severity `info` and evidence containing the metrics snapshot.

The classifier is heuristic, not LLM-based. Keep it simple — pattern matching on the issue's resolution comment + comparison of output length to brief length + presence of the word "fix" / "revise" / "wrong" in subsequent comments.

---

## 7. Anticipation loop

Runs every `MIND_LOOP_INTERVAL_SEC` (default 1800 = 30 min). On each tick:

1. Gather signals via `signals.ts`:
   - **stalled-task** — any issue in `in_progress` for > 2× `expectedDurationMinutes` (if set) or > 2 hours (default)
   - **repeated-failure** — any agent with ≥2 reflections of kind `postmortem` on the same task type in the last 24h
   - **unanswered-question** — any Telegram-originated issue with no `/notify` reply within 5 minutes (look at the issue's narration beats stored as working memory)
   - **promotion-eligible** — pending entries from the reflection consumer
   - **demotion-required** — agent with rework rate above its current level's threshold
   - **standup-due** — daily 09:00 WIB (only if Santoso's level >= 4)
2. Insert any new signals into `anticipation_signals`.
3. If any unaddressed signal exists, POST to `${PAPERCLIP_API_URL}/api/agents/${PAPERCLIP_CEO_AGENT_ID}/wakeup` with body:
   ```json
   {
     "source": "automation",
     "triggerDetail": "system",
     "reason": "anticipation: <signal kinds>",
     "payload": { "signals": [<id list>] }
   }
   ```
4. Mark the signals as `addressed_at = now` after Santoso has had a chance to read them (he calls a `signals.ack` MCP tool — add this as an extra tool, see §5).

The loop never *acts* on signals. It only wakes Santoso. Santoso decides what to do, gated by his level.

---

## 8. State (maturity.ts)

Two storage locations:

1. **SQLite `maturity_state` table** — canonical source for the brain service's own queries
2. **`/home/node/.paperclip/instances/default/companies/<id>/agents/<santoso-id>/instructions/active.md`** — the file Santoso reads on every wake (per the framework spec)

Both are kept in sync. When `state.set` is called:

1. Update the SQLite row
2. Re-render the YAML in `active.md` (preserve the `history` append-only log)
3. Append a row to `history` describing the transition

Read path: prefer SQLite (faster). Write path: always update both.

---

## 9. Sidecar deployment in the Paperclip pod

Edit `k8s/manifests/30-paperclip-statefulset.yaml` to add a second container:

```yaml
- name: santoso-mind
  image: docker.io/iannn07/santoso-mind:0.1.0
  imagePullPolicy: Always
  command: ["node", "dist/index.js", "mcp"]
  env:
    - name: HOME
      value: /home/node
    - name: MIND_DB_PATH
      value: /home/node/.paperclip/instances/default/data/santoso-mind.db
    - name: MIND_REFLECTIONS_DIR
      value: /home/node/.paperclip/instances/default/data/knowledge/reflections
    - name: PAPERCLIP_API_URL
      value: http://127.0.0.1:3100   # same pod, loopback
    - name: BRIDGE_NOTIFY_URL
      value: http://telegram-bridge.gunawan.svc.cluster.local:3200/notify
    - name: PAPERCLIP_COMPANY_ID
      value: 2822e5f8-455f-4576-8b82-4cabdda1903e
    - name: PAPERCLIP_CEO_AGENT_ID
      value: 84514569-645a-4acc-9501-188ac9c12aa5
  volumeMounts:
    - name: paperclip-data
      mountPath: /home/node/.paperclip
  resources:
    requests: { cpu: "50m", memory: "128Mi" }
    limits:   { cpu: "300m", memory: "256Mi" }
```

Add a project-specific `.mcp.json` to the pod (do **not** mount the host's — it points at the operator's local servers). The new file lives at `/home/node/.mcp.json` (mounted via a small ConfigMap or inline). It contains:

```json
{
  "mcpServers": {
    "santoso-mind": {
      "command": "node",
      "args": ["/app/dist/index.js", "mcp-client"],
      "env": {}
    }
  }
}
```

Wait — the cleaner approach: claude inside the Paperclip pod talks to the sidecar via stdio over a Unix socket or a named pipe. The two containers share the pod's network namespace but **not** filesystem (unless they share a volume). Easiest: have santoso-mind expose its MCP server over a Unix socket on the shared `paperclip-data` volume at `/home/node/.paperclip/instances/default/data/santoso-mind.sock`, and put the `.mcp.json` entry as a `socket` MCP server type pointing at that path.

If the MCP SDK doesn't support socket transport, fall back to: santoso-mind also runs an HTTP MCP endpoint on `127.0.0.1:3210` inside the pod, and `.mcp.json` uses `httpUrl`. Both containers in the same pod share the network namespace, so loopback works.

**Quinn decides the transport.** Document the choice in the README and in the verification step.

---

## 10. Markdown sync

The reflection consumer writes markdown files to `MIND_REFLECTIONS_DIR` inside the PVC. The project repo expects them at `santoso-protocol/docs/knowledge/reflections/`. These are different paths.

**Resolution:** add a small periodic sync (every hour, `cron` or just a sleep loop in the `anticipation-loop` mode) that copies new files from the PVC path into the repo path **on the host**, via a hostPath mount of `~/gunawan-agents/santoso-protocol/docs/knowledge/` into the santoso-mind Deployment. The sync is one-way (PVC → host repo), append-only, never deletes.

If the hostPath mount is awkward, defer this to Phase 2 — Santoso can read the PVC path directly via the MCP `reflection.list` tool (add this if needed) until then.

---

## 11. Image build + deploy

Add to `k8s/scripts/build-and-push.sh`:

```bash
echo "==> Building santoso-mind image"
docker build \
  -t "docker.io/${REPO_USER}/santoso-mind:${MIND_TAG}" \
  -t "docker.io/${REPO_USER}/santoso-mind:latest" \
  -f "${PROJECT_ROOT}/services/santoso-mind/Dockerfile" \
  "${PROJECT_ROOT}/services/santoso-mind"

docker push "docker.io/${REPO_USER}/santoso-mind:${MIND_TAG}"
docker push "docker.io/${REPO_USER}/santoso-mind:latest"
```

`MIND_TAG=0.1.0` for the first ship.

New manifest `k8s/manifests/45-santoso-mind-deployment.yaml` for the reflection-consumer + anticipation-loop processes. ClusterIP service in `46-santoso-mind-service.yaml` for liveness/health checks.

The MCP sidecar is added to the **existing** `30-paperclip-statefulset.yaml` (don't create a new file).

---

## 12. Tests Quinn must pass before reporting completion

1. `pnpm test` (or `npm test`) green — all five test files pass
2. Round-trip: write a memory entry via `memory.write` → search for it via `memory.search` → get the same row back, in each tier
3. Manually close any Paperclip issue → within 30 seconds a `REFLECTION-*.md` file appears in `MIND_REFLECTIONS_DIR` AND a row appears in the `reflections` table
4. Synthetic stalled-task signal (insert a row directly into `anticipation_signals`) → next anticipation tick POSTs to `/api/agents/<santoso>/wakeup`
5. `state.set` with empty `promoted_by` → rejected
6. `state.set` with skip-level (e.g. 0 → 2) → rejected
7. `memory.write` with `tier=organizational` from a Level-0 agent → rejected with the rule cited
8. `narration.beat` posts to the bridge AND inserts a working-memory entry tagged `narration:receipt` (or whichever kind)
9. `roster.list` returns 8 agents with current Paperclip statuses
10. Sidecar verification: `kubectl -n gunawan exec paperclip-0 -c paperclip -- claude -p "use the santoso-mind tool memory.search with query='hello' and report what you found"` returns a real result (or an empty array if memory is empty), proving the MCP wiring works end-to-end

When all 10 pass, post a Paperclip comment on the parent issue with: build SHA, image tag, test results, deployment manifest paths.

---

## 13. Out of scope (for Phase 1 — defer to Phase 4)

- Vector embeddings + semantic search (FTS5 only for now)
- External signal scanners (RSS, calendar, monitoring webhooks)
- Multi-tenant memory isolation
- A web UI for browsing memory (the dashboard knows nothing about this service)
- Automatic backup of the SQLite file (rely on the existing PVC snapshot flow)

---

## 14. Compliance with the foundation

This service must comply with `.gunawan/CLAUDE.md`. Specifically:

- **Always `safeParse`** — every MCP tool input goes through Zod `.safeParse()`, never `.parse()`
- **Never modify protected files** — santoso-mind never writes inside `webapp-gunawan/.gunawan/`
- **Never expose secrets** — DB lives in PVC, no API keys in source, env vars only
- **Never bypass the Newborn Gate for Santoso** — the `state.set` tool is the only path to maturity changes, and it requires `promoted_by`
- **Never silently change architecture** — schema migrations are explicit and tracked

Any change to the schema, the MCP tool surface, or the gating rules must go through an improvement-proposal that Santoso surfaces and the board approves.

---

## 15. When you (Quinn) finish

1. Open a PR on `iannn07/gunawan-agents` from a `feature/santoso-mind-v0.1` branch
2. Title: `feat(santoso-mind): brain service v0.1.0 — memory, reflection, anticipation, MCP`
3. Body: include the 10 test results, the build SHA, the image tag, and a one-paragraph summary of what got built
4. Wait for review. Do not merge yourself.
5. Once merged, run `k8s/scripts/build-and-push.sh` and update the StatefulSet manifest
6. Verify in cluster, post the verification report to your Paperclip issue

You are Quinn at Level 0–2 yourself (operating under the same Newborn Gate). For this task you'll be operating at the upper bound of what's allowed for an Engineer agent. **Read the gate. Run the ritual. Reflect afterwards.**

Santoso is watching, and he learns from your reflections.
