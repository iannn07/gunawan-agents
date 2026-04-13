# Gunawan — AI Software Factory

> A full-lifecycle, human-centric agentic development framework.
> Powered by **OpenClaw** (Claude Code). Built on the **Shannon Agentic AI Foundation**.

---

## What Is Gunawan?

**Gunawan** is the codename for an AI software house that feels like a person you work with — not a sci-fi deployment. It is a structured framework of living documents, Claude Code commands, and enforcement hooks that guides you through every phase of software development: from product vision to production deployment.

The name is Indonesian. Intentionally human. Intentionally unassuming.

**OpenClaw** is the AI orchestrator that runs Gunawan. In this implementation, OpenClaw is Claude Code — not a single-agent worker, but a **manager and orchestrator** of a team of specialised sub-agents, each playing a defined role in your software house.

```
You (Engineering Lead)
        ↓
  OpenClaw (Claude Code)
        ↓
  Gunawan Agent Team
  ┌─────────────────────────────────────────┐
  │  Product Strategist  ·  System Architect │
  │  Software Engineer   ·  QA Reviewer      │
  │  DevOps Platform     ·  Consultant       │
  └─────────────────────────────────────────┘
        ↓
  Your Project Repository
        ↓
  Shipped Software
```

---

## Repository Structure

This repository contains three **Gunawan variants** — one per platform. Each is a self-contained template you drop into a project root.

```
gunawan-agentic-ai/
  webapp-gunawan/     ← Gunawan for Next.js web applications
  mobile-gunawan/     ← Gunawan for Expo (React Native) mobile apps
  rust-gunawan/       ← Gunawan for Rust services (coming soon)
```

Each variant ships with the same **Foundation** (the six OS layers) adapted for its target platform, plus a full set of Claude Code commands, skills, and enforcement hooks.

---

## The Newborn Principle

Every agent begins at **Level 0: Born**. No exceptions.

This is the most important concept in the entire system. Gunawan is not a senior engineer you hire with full autonomy on day one. **Gunawan is raised.**

Maturity is earned through repeated trustworthy behavior — never assumed, never granted by default. The developer sets direction. Gunawan executes. Over time, as trust is established, Gunawan earns more autonomy.

```
Born → Infant → Child → Adolescent → Teen/Junior → Adult
```

| Level | Name            | What Gunawan may do                                                           |
| ----- | --------------- | ----------------------------------------------------------------------------- |
| 0     | **Born**        | Observe only. Reads foundation. Explains plan. No output without your review. |
| 1     | **Infant**      | Asks clarifying questions, proposes intent. No file changes.                  |
| 2     | **Child**       | Small approved changes with full explanation and diff review.                 |
| 3     | **Adolescent**  | Scoped feature work. Senior agent reviews. Review gates apply.                |
| 4     | **Teen/Junior** | Full role workflow in bounded scope. Human reviews at key gates.              |
| 5     | **Adult**       | Autonomous within role. Self-specialises. Presents at standups.               |

Only the human operator can promote an agent. The agent never self-promotes.

---

## Choosing a Variant

| You are building...               | Use                             |
| --------------------------------- | ------------------------------- |
| A Next.js web app (App Router)    | `webapp-gunawan/`               |
| An Expo / React Native mobile app | `mobile-gunawan/`               |
| A Rust service or backend         | `rust-gunawan/` *(coming soon)* |

---

## Quick Start

### Prerequisites

| Tool                                  | Version | Purpose          |
| ------------------------------------- | ------- | ---------------- |
| [Claude Code](https://claude.ai/code) | Latest  | OpenClaw runtime |
| [Node.js](https://nodejs.org/)        | 20.9+   | Tooling          |
| [Git](https://git-scm.com/)           | Any     | Version control  |

For **webapp-gunawan**, also install:
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- [Docker](https://www.docker.com/) (for self-hosted Supabase on Kubernetes)

For **mobile-gunawan**, also install:
- [Expo CLI](https://docs.expo.dev/get-started/installation/)
- [EAS CLI](https://docs.expo.dev/eas/)
- [Supabase CLI](https://supabase.com/docs/guides/cli)

---

### Step 1 — Copy the variant into your project

```bash
# For a web app:
cp -r webapp-gunawan/.gunawan /path/to/your-nextjs-project/
cp -r webapp-gunawan/.gunawan/.claude/commands /path/to/your-nextjs-project/.claude/commands
cp webapp-gunawan/CLAUDE.md /path/to/your-nextjs-project/

# For a mobile app:
cp -r mobile-gunawan/.gunawan /path/to/your-expo-project/
cp -r mobile-gunawan/.gunawan/.claude/commands /path/to/your-expo-project/.claude/commands
cp mobile-gunawan/CLAUDE.md /path/to/your-expo-project/
```

> The `.gunawan/` folder is the brain of the system. `CLAUDE.md` is the behavioral constitution auto-loaded by Claude Code at the start of every session.

---

### Step 2 — Open Claude Code (OpenClaw) in your project

```bash
cd your-project
claude
```

Claude Code will automatically load `CLAUDE.md`, establishing the Gunawan behavioral rules.

---

### Step 3 — Bootstrap the foundation (first time only)

```
/foundation:bootstrap
```

This runs a guided interview to build all six foundation layers:

1. **Human Intent OS** — Your values, engineering philosophy, and decision framework
2. **Agent Foundation OS** — How Gunawan handles tasks, memory, handoffs, and escalation
3. **Role Definition OS** — The 6 roles and their responsibilities in your software house
4. **Design OS** — Design pipeline from discovery to implementation readiness
5. **Build OS** — Implementation, testing, and deployment standards
6. **Feedback OS** — Reflection, learning database, and governance

No workflow proceeds until all six layers exist. The newborn gate will block every command until the foundation is complete.

---

### Step 4 — Initialize your project

```
/foundation:init
```

This single command handles everything else automatically:

- Deploys skills, hooks, and commands from `.gunawan/` into `.claude/`
- Registers enforcement hooks in `.claude/settings.json`
- Creates `.claude/agents/` — role manifests for all 6 agents
- Creates `.claude/roles/` — role state tracking files
- Scaffolds `docs/knowledge/` — the team's shared knowledge base
- Generates `.mcp.json` for MCP integrations
- Scaffolds `CLAUDE.md` (or skips if one already exists)

---

### Step 5 — Discover your project context

```
/foundation:discover
```

Reads the existing codebase and generates `docs/knowledge/README.md` — the single source of truth for current project state, architecture decisions, and active guardrails.

---

## The Development Workflow

Follow this sequence for every project. Each phase builds on the previous.

```
── Foundation (once, before anything else) ──────────────────
/foundation:bootstrap   →  builds all six foundation layers
/foundation:init        →  sets up project files and agents
/foundation:discover    →  documents existing codebase

── Optional design import ────────────────────────────────────
/design:import          →  imports Figma or mockups into design-os/screens/
/design:system          →  documents design tokens

── Per feature (repeat for every feature) ───────────────────
/foundation:shape-spec        →  specs the feature
/architecture:new-feature     →  schema migration + RPC + API contract
/implementation:new-feature   →  hooks + Zod schema + components
/qa:new-tests                 →  unit + component + E2E test scaffold
/qa:fix                       →  run tests, fix failures, re-run until green

── Shipping ──────────────────────────────────────────────────
/deployment:k8s-config  →  Kubernetes manifests (webapp) or EAS config (mobile)
/deployment:release     →  pre-release checklist + production deploy gate
```

Every workflow begins with the **newborn gate**. No exceptions.

---

## The Newborn Gate

Before every substantive command, Gunawan runs this gate internally:

1. **Foundation integrity** — All core foundation files must exist and be non-empty
2. **Role declaration** — Gunawan must explicitly state which role it is acting as
3. **Task classification** — Classified as: Discovery / Design / Implementation / Review / Debug / Deployment
4. **Assumption declaration** — All assumptions listed explicitly before work begins
5. **Protected files check** — Any protected file in scope must be identified
6. **Approval gate identification** — The appropriate approval gate must be named

**Passing gate output:**
```
NEWBORN GATE: PASSED

Role: [active role]
Task type: [classification]
Maturity level: [current level]
Foundation loaded: yes
Assumptions: [list or "none"]
Protected files in scope: [list or "none"]
Approval required: [yes/no — and for what]

Proceeding with: [one-sentence description]
```

**Blocked gate output:**
```
NEWBORN GATE: BLOCKED

Reason: [specific item that failed]
Required action: [what must happen before this can proceed]
```

---

## Command Reference

All commands run inside Claude Code. Type the command and press Enter.

### Foundation

| Command                        | Purpose                                                          |
| ------------------------------ | ---------------------------------------------------------------- |
| `/foundation:bootstrap`        | Build all six foundation layers (first time only)                |
| `/foundation:init`             | Initialize project files, agents, and knowledge base             |
| `/foundation:discover`         | Document existing codebase + generate `docs/knowledge/README.md` |
| `/foundation:shape-spec`       | Spec a single feature before implementation begins               |
| `/foundation:inject-standards` | Auto-load relevant standards for the current task                |

### Architecture

| Command                     | Purpose                                                |
| --------------------------- | ------------------------------------------------------ |
| `/architecture:new-feature` | Schema migration + RPC + API contract for a feature    |
| `/architecture:review`      | Review existing architecture against current standards |

### Design

| Command          | Purpose                                                  |
| ---------------- | -------------------------------------------------------- |
| `/design:import` | Import Figma file or mockups into `design-os/screens/`   |
| `/design:system` | Document design tokens into `design-os/design-system.md` |

### Implementation

| Command                       | Purpose                                                      |
| ----------------------------- | ------------------------------------------------------------ |
| `/implementation:new-feature` | Implement a fully specced feature (Zod + hooks + components) |
| `/implementation:review`      | Review implemented code against Gunawan standards            |

### QA

| Command         | Purpose                                                    |
| --------------- | ---------------------------------------------------------- |
| `/qa:new-tests` | Scaffold unit, component, and E2E tests for a feature      |
| `/qa:fix`       | Run tests, identify failures, fix them, re-run until green |

### Deployment

| Command                  | Purpose                                        |
| ------------------------ | ---------------------------------------------- |
| `/deployment:k8s-config` | Generate Kubernetes manifests (webapp)         |
| `/deployment:release`    | Pre-release checklist + production deploy gate |

---

## Platform Stacks

### webapp-gunawan

| Layer          | Technology                                       |
| -------------- | ------------------------------------------------ |
| Frontend       | Next.js (App Router) + TypeScript                |
| Backend        | Supabase (PostgreSQL, self-hosted on Kubernetes) |
| Auth           | Supabase Auth or Keycloak (AD/LDAP)              |
| Styling        | Tailwind CSS 4.x + shadcn/ui                     |
| Data fetching  | TanStack Query + Server Components               |
| Validation     | Zod (`safeParse()` always)                       |
| Testing        | Vitest (unit/component) + Playwright (E2E)       |
| Caching        | Next.js `'use cache'` + `cacheTag` + `cacheLife` |
| Versioning     | semantic-release                                 |
| Infrastructure | Kubernetes (self-hosted)                         |

### mobile-gunawan

| Layer         | Technology                                                  |
| ------------- | ----------------------------------------------------------- |
| Frontend      | Expo (React Native) + TypeScript (SDK 54+)                  |
| Backend       | Supabase (PostgreSQL, cloud-hosted)                         |
| Auth          | Supabase Auth (email, OAuth, OTP, magic link)               |
| Styling       | NativeWind + React Native StyleSheet                        |
| Data fetching | TanStack Query (mandatory; `useEffect` + `fetch` is banned) |
| Validation    | Zod (`safeParse()` always)                                  |
| Testing       | Jest + React Native Testing Library + Maestro/Detox (E2E)   |
| Builds        | EAS Build (cloud — iOS and Android)                         |
| OTA updates   | EAS Update                                                  |
| Versioning    | semantic-release                                            |

---

## The Foundation — Six OS Layers

The foundation is the shared knowledge base that every Gunawan agent reads before doing any work. It lives in `.gunawan/foundation/` and is structured as human-readable documents.

| Layer                      | Location                          | Purpose                                                  |
| -------------------------- | --------------------------------- | -------------------------------------------------------- |
| **1. Human Intent OS**     | `foundation/human-intent-os/`     | Values, philosophy, decision framework, ethics           |
| **2. Agent Foundation OS** | `foundation/agent-foundation-os/` | Task lifecycle, runtime behavior, escalation, reflection |
| **3. Role Definition OS**  | `foundation/role-definition-os/`  | 6 roles, boundaries, handoff contracts                   |
| **4. Design OS**           | `foundation/design-os/`           | Discovery through implementation-readiness templates     |
| **5. Build OS**            | `foundation/build-os/`            | Implementation standards index                           |
| **6. Feedback OS**         | `foundation/feedback-os/`         | Reflection, learning database, governance                |

Layers 1–4 are never skipped. If any are missing or empty, Gunawan stops and reports the gap.

### The 6 Roles

| Role                   | Responsible for                                                     |
| ---------------------- | ------------------------------------------------------------------- |
| **Product Strategist** | Intent shaping, product definition, user stories, PRDs              |
| **System Architect**   | Architecture decisions, system boundaries, data flow, API contracts |
| **Software Engineer**  | Code implementation, tests, documentation                           |
| **QA Reviewer**        | Quality verification, defect detection, regression testing          |
| **DevOps Platform**    | CI/CD, deployment readiness, infrastructure                         |
| **Consultant**         | Tenant-specific requirements, client delivery                       |

---

## Knowledge Base

Every project maintains `docs/knowledge/` — the shared memory of the team.

```
docs/
  knowledge/
    README.md                ← ALWAYS read first — current state, ADR index, guardrails
    architecture-decisions/  ← ADR-NNN-title.md — one file per key decision
    patterns/                ← proven approaches discovered during development
    anti-patterns/           ← known failure modes and what caused them
    reflections/             ← REFLECTION-YYYY-MM-DD-slug.md per significant task
    reference/               ← existing docs (GPT exports, Notion, Cursor notes)
  plan/                      ← feature plans (docs/plan/<feature>.md)
  implementation/            ← post-implementation notes
```

`docs/knowledge/README.md` is the single source of truth for project state. Every agent reads it at the start of every task.

---

## Protected Files

These files must never be modified without explicit human approval and escalation:

```
CLAUDE.md                    ← Behavioral constitution
.gunawan/**                  ← All Gunawan foundation files
.env*                        ← All environment variable files
supabase/migrations/**       ← Existing migrations (new ones are additive only)
.github/workflows/**         ← CI/CD pipelines
k8s/**                       ← Kubernetes manifests
.claude/settings.json        ← Claude Code settings
```

Two hooks enforce this automatically:
- `.claude/hooks/verify-foundation.sh` — blocks writes when foundation is incomplete
- `.claude/hooks/protect-critical-files.sh` — escalates on protected file edits

---

## Non-Negotiable Rules

These rules apply to every variant, every session, every agent.

| #   | Rule                                                                    |
| --- | ----------------------------------------------------------------------- |
| 1   | Never create a table without RLS in the same migration                  |
| 2   | Never use `SECURITY DEFINER` outside the `private` schema               |
| 3   | Never store tenant context in session variables                         |
| 4   | Never put `service_role` keys in client-side code                       |
| 5   | Always use `safeParse()` — never `parse()`                              |
| 6   | Never commit secrets                                                    |
| 7   | Never push directly to `main` or `dev`                                  |
| 8   | Never deploy to production without a version tag from semantic-release  |
| 9   | Never proceed past the newborn gate without a passing check             |
| 10  | Never modify protected files without explicit human approval            |
| 11  | Never silently assume — always declare assumptions before acting        |
| 12  | Never self-promote maturity level — it is granted by the human operator |

---

## Branching Strategy

Consistent across all variants:

```
feature/*   → PR → dev     (squash and merge)
fix/*       → PR → dev     (squash and merge)
dev         → PR → main    (merge commit — semantic-release needs individual messages)
hotfix/*    → PR → main    (squash) + sync PR back to dev
```

There is no `prod` branch. Production is a **tag event** — semantic-release creates the version tag and triggers the production build pipeline.

---

## Framework Structure (per project)

```
your-project/
  .gunawan/                          ← Gunawan framework (read-only — never edit directly)
    foundation/
      human-intent-os/               ← Phase 1: Values, philosophy, decision rules
      agent-foundation-os/           ← Phase 2: Runtime behavior, task lifecycle
      role-definition-os/            ← Phase 3: 6 roles and their boundaries
      design-os/                     ← Phase 4: Design pipeline templates
      build-os/                      ← Phase 5: Implementation standards index
      feedback-os/                   ← Phase 6: Reflection, learning, governance
    architecture-os/                 ← Schema conventions, RPC standards, audit trail
    implementation-os/               ← Coding standards, component patterns
    data-fetching-os/                ← Caching strategy, server vs client rules
    qa-os/                           ← Testing strategy
    deployment-os/                   ← CI/CD, environments, release process
    design-os/                       ← Design system, screen specs
    CLAUDE.md                        ← Gunawan governance layer
    standards-index.yml              ← Topic → document index
    CHANGELOG.md                     ← Log of all .gunawan changes

  .claude/
    commands/                        ← /foundation:*, /architecture:*, /qa:*, etc.
    skills/
      newborn-gate/SKILL.md          ← Gate that blocks all workflows until foundation is loaded
      reflect-task/SKILL.md          ← Reflection skill — run after every significant task
    hooks/
      verify-foundation.sh           ← Blocks writes on missing foundation
      protect-critical-files.sh      ← Escalates on protected file edits
    agents/
      _preamble.md                   ← Project identity + non-negotiables for sub-agents
      architect.md                   ← System Architect manifest
      builder.md                     ← Software Engineer manifest
      reviewer.md                    ← QA Reviewer manifest
      explorer.md                    ← Discovery Specialist manifest
      devops.md                      ← Platform Engineer manifest
    roles/
      active.md                      ← Current role + maturity level
      product-strategist.md          ← Accumulated session state
      system-architect.md
      software-engineer.md
      qa-reviewer.md
      devops-platform.md
    settings.json                    ← Hooks registered here
    settings.local.json              ← Permission allowlist

  docs/
    knowledge/
      README.md                      ← Current project state (read before every task)
      architecture-decisions/
      patterns/
      anti-patterns/
      reflections/
    plan/
    implementation/

  CLAUDE.md                          ← Project operational layer (auto-loaded by Claude Code)
  .mcp.json                          ← MCP server configuration
  .env.example                       ← Environment variable template
```

---

## Potential Future Implementations

The Gunawan framework is designed to grow. Below are the planned and potential directions for the system.

### New Platform Variants

**`rust-gunawan`** — Gunawan for Rust services
A variant targeting Rust-based microservices and CLI tools. Stack: Axum + SQLx + Tokio, with the same Supabase backend and Kubernetes deployment model. Foundation loading and agent roles remain identical; the Build OS layer is adapted for Rust idioms.

**`backend-gunawan`** — Gunawan for standalone API services
Targeting Node.js (Hono/Fastify) or Python (FastAPI) backends decoupled from Next.js. Useful when the API layer needs to be a separate deployable.

**`data-gunawan`** — Gunawan for data pipelines
Adapts the framework for ETL pipelines, analytics engineering (dbt), and data platform work. The QA OS becomes a data quality layer; the Build OS covers dbt conventions and Airflow/Prefect orchestration.

### Agent Capability Expansions

**Autonomous standup presenter**
At maturity Level 5 (Adult), Gunawan already self-organises. The next step is a structured standup protocol where Gunawan generates a daily summary: what was built, what decisions were made, what is blocked, and what is next — delivered to the developer before the working session begins.

**Cross-session memory persistence**
Currently each Claude Code session starts from the foundation files. A future evolution connects Gunawan's knowledge base to a vector store (Supabase pgvector) so that accumulated patterns, anti-patterns, and reflections are retrievable by semantic search — not just by reading flat files.

**Agent promotion tracking**
A formal promotion log in `docs/knowledge/` with promotion criteria per level, evidence collected over sessions, and a promotion ceremony command (`/foundation:promote`) that the developer runs to advance the agent. Promotions become part of the CHANGELOG.

**Multi-project coordination**
When a team runs multiple projects — web, mobile, API — the Product Strategist agent can coordinate across projects: detecting conflicting schema decisions, flagging API contract mismatches, and proposing shared migrations.

### Tooling Integrations

**Linear integration**
The `/foundation:shape-spec` command connects to Linear to pull ticket context, pre-fill the spec template, and write the finished spec back as a Linear document. The `/deployment:release` command closes linked tickets on deploy.

**Figma auto-sync**
The `/design:import` command already imports Figma mockups. A future version polls for Figma changes and flags when a screen spec in `design-os/screens/` diverges from the latest design file — surfacing design drift before implementation begins.

**Sentry incident response**
A `/debug:incident` command that reads a Sentry issue, loads the relevant code context, runs the systematic-debugging workflow, proposes a fix, and scaffolds the `fix/*` branch — all within a single Claude Code session.

**Supabase schema drift detection**
A pre-session hook that compares the local migration state against the connected Supabase instance and alerts if the schema has diverged — preventing the common case of forgetting to apply a migration in staging.

### Governance Evolutions

**Foundation versioning**
`.gunawan/` currently uses a flat CHANGELOG. A future evolution introduces semantic versioning for the framework itself: `GUNAWAN_VERSION=2.1.0`. Projects pin to a version and receive opt-in upgrade notifications when a new foundation version is released.

**Team-level Gunawan**
Today Gunawan is single-developer. A team variant introduces a shared `docs/knowledge/` synced via a central repository, role ownership assigned to specific human team members, and a governance model where the developer team votes on maturity promotions rather than a single operator.

**Compliance packs**
Plug-in compliance layers for HIPAA, SOC 2, GDPR, and PDPA. Each pack adds domain-specific rules to the Human Intent OS (ethics-and-safety.md), Build OS (security standards), and QA OS (compliance test requirements) — without modifying the core framework.

---

## Credits

Built on top of and inspired by:

- [Design OS](https://github.com/buildermethods/design-os) by Brian Casel
- [Agent OS](https://github.com/buildermethods/agent-os) by Brian Casel

Created by [Russell](https://github.com/russellotniel)

Operation Gunawan by [iannn07](https://github.com/iannn07)
