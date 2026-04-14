# docs/knowledge — Project state for Gunawan Santoso Corp

This is the project's knowledge base, per the framework rule: "Read `docs/knowledge/README.md` before starting any task. It contains current state, guardrails, and the ADR index."

Every agent (Santoso and the seven specialists) reads this file on wake.

---

## Current state (as of Phase 0 ship)

### Company

- **Name:** Gunawan Santoso Corp
- **Paperclip company id:** `2822e5f8-455f-4576-8b82-4cabdda1903e`
- **Roster:** 8 agents (Santoso CEO + 7 specialists), all reporting to Santoso. Names and IDs in `agents/ceo/role.md`.

### Deployment

- **Cluster:** k3s single-node on the same VPS (`84.247.150.72`, Ubuntu 24.04)
- **Public hostnames:**
  - `gunawan-paperclip.digital-lab.ai` — Paperclip dashboard + API
  - `gunawan-bridge.digital-lab.ai` — Telegram webhook (santoso-telegram-bridge)
- **TLS:** Let's Encrypt prod via cert-manager, Traefik ingress
- **Authentication:** the Paperclip pod's `claude` CLI is bound to the operator's Claude.ai Max subscription via host-mounted `~/.claude/` (no console credit consumed)

### Brain service

- **Name:** `santoso-mind` (planned, not yet shipped)
- **Status:** SPEC.md drafted; implementation queued for Quinn in Phase 1
- **What it provides:** SQLite memory store (3-tier), MCP tools, automatic reflection consumer, anticipation loop, maturity state tracker
- **Path on disk (when shipped):** `services/santoso-mind/` in this repo

### Santoso's level

- **Current:** Level 0 (Born). Capability profile: `jarvis-fresh-boot`.
- **Source of truth:** `.claude/roles/active.md` (also mirrored in PVC)
- **Promotion rules:** see `agents/ceo/success-metrics.md`. Only the board can promote.

---

## Active guardrails

These apply to every agent on every task. They override anything else.

1. **Newborn Gate is law.** Every substantive task runs the gate from `.gunawan/.claude/skills/newborn-gate/SKILL.md`.
2. **Santoso's name is constant.** He is Santoso at every level. The JARVIS → EDITH arc is capability inspiration, never a rename.
3. **No console credit.** Anthropic API calls go through the host-mounted Claude.ai Max session inside the Paperclip pod. Setting `ANTHROPIC_API_KEY` on the pod would override OAuth and is forbidden.
4. **Protected files** (never modified without explicit board approval):
   - `webapp-gunawan/.gunawan/**` (the framework, symlinked into this project)
   - `CLAUDE.md`, `SANTOSO-PROTOCOL-PROJECT.md`
   - `.env*`
   - `k8s/manifests/**` (modify only when deploying changes Santoso has approved)
   - Anything containing secrets, credentials, or auth material
5. **Three-beat narration minimum** for any non-trivial Telegram interaction. Receipt → Processing → Output.
6. **Always reflect.** Every closed task → reflection entry in `docs/knowledge/reflections/`.
7. **Never self-promote.** Maturity is granted by the board via `/promote santoso N`.

---

## ADR index

Architecture Decision Records live in `architecture-decisions/`. None yet — Phase 1 will produce the first ones (santoso-mind schema, MCP tool contract, anticipation cadence).

When you write an ADR, name it `ADR-NNN-<slug>.md` and append a row here:

| ADR | Title | Date | Status |
|---|---|---|---|

---

## Pattern + postmortem index

- `patterns/` — successful approaches worth keeping. Populated by the reflection consumer (Phase 1+).
- `anti-patterns/` — known failure modes. Populated as we hit them.
- `postmortems/` — task failures with root cause. Populated by the reflection consumer (Phase 1+).
- `reflections/` — every task's reflection entry, dated and slugged. The raw feed.

---

## How to write a reflection (Phase 0 manual fallback)

Until the brain service is online, reflections are hand-written to `reflections/REFLECTION-<YYYY-MM-DD>-<slug>.md` using this template:

```markdown
# REFLECTION — <slug>

**Date:** <ISO>
**Agent:** <name>
**Issue:** GUN-<id>
**Classification:** pattern | postmortem | observation

## Expected outcome
What the task was supposed to produce.

## Actual outcome
What actually happened.

## What worked
Bullet points. Specific.

## What failed
Bullet points. Specific.

## Root cause
One sentence.

## Missing context
What did I not know that I should have?

## Assumption errors
Which declared assumptions turned out wrong?

## Proposed improvement
Specific change to a rule, prompt, file, or behaviour. Goes to the improvement-proposals queue, never applied directly.
```

---

## See also

- `agents/ceo/role.md` — Santoso's role definition
- `.claude/voice/santoso.md` — how Santoso talks
- `.claude/roles/active.md` — Santoso's current level
- `services/santoso-mind/SPEC.md` — Quinn's engineering brief for the brain service
- `.gunawan/foundation/feedback-os/` — the framework's reflection and learning rules
