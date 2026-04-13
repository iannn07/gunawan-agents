# Design: Cursor ↔ Claude Code Behavioral Alignment

**Date:** 2026-04-13
**Status:** Approved — executing

---

## Problem

Cursor and Claude Code share the same project but speak different dialects:

- Cursor's THINKER phase outputs `[THINKER] Analysing task...` — unreadable by Claude Code
- Claude Code's newborn-gate skill outputs a structured `NEWBORN GATE: PASSED/BLOCKED` block
- When a session is handed from one tool to the other, gate results and task boundaries are lost
- Cursor's foundation loading order is underspecified vs CLAUDE.md's 8-layer sequence
- Documentation write obligations have exact paths in the governance doc but the ship checklist omits them, so agents skip writing

## Goal

Both tools emit and consume the same gate format, load context in the same order, and write documentation to the same canonical paths — making sessions truly handoff-able.

## Approach

Surgical in-place rewrites to three cursor rule files. No new files created. No restructuring of existing sections.

---

## Changes

### 1. `swe-gunawan-governance-v1.mdc` — Gate Format + Docs

**Section 7 — Phase 1 (THINKER):**
Replace `[THINKER] Analysing task...` declaration with the exact `NEWBORN GATE: PASSED/BLOCKED` output block used by Claude Code's newborn-gate skill. Same fields: Role, Task type, Maturity level, Foundation loaded, Assumptions, Protected files in scope, Approval required, Proceeding with.

**Section 7 — Phase 3 (REVIEWER):**
Add `NEWBORN GATE: CLOSED` output at end of reviewer phase. Signals task boundary to the other tool.

**Section 9 — Ship Checklist:**
- `Documentation written` → explicit paths: `docs/plan/<feature>.md` + `docs/implementation/<feature>.md`
- `Task reflection logged` → explicit paths: `docs/knowledge/reflections/REFLECTION-YYYY-MM-DD-<task-slug>.md` (project) + `.gunawan/foundation/feedback-os/reflections/YYYY-MM-DD-<task-slug>.md` (foundation, propose-only)

**Section 10 — Documentation Standard:**
Add both reflection paths with clear distinction between project-level and foundation-level reflections.

### 2. `swe-gunawan-session-v1.mdc` — Foundation Loading Order

**Section 1 Step 3:**
Expand collapsed "Governance / foundation files" step into CLAUDE.md's exact 8-layer sequence. Add the guard rule: if layers 1–4 are missing, stop and report.

### 3. `swe-gunawan-v1.mdc` — Cross-Tool Compatibility Addendum

**New Section 13.8:**
State the four cross-tool contracts:
- Gate format: always NEWBORN GATE, never free-form
- Role state: `.claude/roles/` is the single shared store
- Documentation: canonical paths are the handoff artefact
- Ship checklist: neither tool may skip doc/reflection items

---

## Shared Documentation Model

| Doc type | Path | Written by |
|---|---|---|
| Feature plan | `docs/plan/<feature>.md` | Thinker phase |
| Implementation notes | `docs/implementation/<feature>.md` | After Builder phase |
| Project state | `docs/knowledge/README.md` | After any significant task |
| Architecture decisions | `docs/knowledge/architecture-decisions/ADR-NNN-<title>.md` | When a key decision is made |
| Postmortems | `docs/knowledge/postmortems/` | After failure or near-miss |
| Task reflection (project) | `docs/knowledge/reflections/REFLECTION-YYYY-MM-DD-<task-slug>.md` | Reviewer phase |
| Task reflection (foundation) | `.gunawan/foundation/feedback-os/reflections/YYYY-MM-DD-<task-slug>.md` | Reviewer phase (propose-only) |

---

## Gate Format (canonical)

```
NEWBORN GATE: PASSED

Role:                     [active role]
Task type:                [Discovery / Design / Implementation / Review / Debug / Deployment]
Maturity level:           [0–5]
Foundation loaded:        yes
Assumptions:              [numbered list, or "none"]
Protected files in scope: [list, or "none"]
Approval required:        [yes/no — and for what]

Proceeding with: [one-sentence description]
```

```
NEWBORN GATE: BLOCKED

Reason: [specific item that failed]
Required action: [what must happen before proceeding]
```

```
NEWBORN GATE: CLOSED

Task:                [one-sentence description]
Checklist:           PASSED
Documentation:       [list of files written, or "none"]
Reflection written:  [path, or "none"]
```
