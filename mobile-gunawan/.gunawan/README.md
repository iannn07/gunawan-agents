# AI Software Factory — Gunawan for Mobile

> A full-lifecycle, human-centric agentic software house for React Native / Expo projects.
> Operated under codename **Gunawan**. Powered by **OpenClaw** (Claude Code).

---

## Table of Contents

- [What is Gunawan for Mobile?](#what-is-gunawan-for-mobile)
- [The Newborn Principle](#the-newborn-principle)
- [Prerequisites](#prerequisites)
- [OpenClaw Setup](#openclaw-setup)
  - [1. Clone the template](#1-clone-the-template)
  - [2. Copy into your project](#2-copy-into-your-project)
  - [3. Run setup](#3-run-setup)
  - [4. Open OpenClaw (Claude Code)](#4-open-openclaw-claude-code)
  - [5. Bootstrap the foundation](#5-bootstrap-the-foundation)
  - [6. Initialize your project](#6-initialize-your-project)
- [Nurturing Gunawan](#nurturing-gunawan)
  - [The maturity ladder](#the-maturity-ladder)
  - [How to promote](#how-to-promote)
  - [What to expect at each level](#what-to-expect-at-each-level)
- [The Foundation](#the-foundation)
  - [Loading order](#loading-order)
  - [Phase 1 — Human Intent OS](#phase-1--human-intent-os)
  - [Phase 2 — Agent Foundation OS](#phase-2--agent-foundation-os)
  - [Phase 3 — Role Definition OS](#phase-3--role-definition-os)
  - [Phase 4 — Design OS](#phase-4--design-os)
  - [Phase 5 — Build OS](#phase-5--build-os)
  - [Phase 6 — Feedback OS](#phase-6--feedback-os)
- [Mobile Stack](#mobile-stack)
- [Command Reference](#command-reference)
  - [Foundation commands](#foundation-commands)
  - [Architecture commands](#architecture-commands)
  - [Implementation commands](#implementation-commands)
  - [QA commands](#qa-commands)
  - [Deployment commands](#deployment-commands)
- [The Development Workflow](#the-development-workflow)
- [The Newborn Gate](#the-newborn-gate)
- [Architecture Overview](#architecture-overview)
  - [System topology](#system-topology)
  - [Agent orchestration](#agent-orchestration)
- [Mobile Standards](#mobile-standards)
  - [Project structure](#project-structure)
  - [Data fetching](#data-fetching)
  - [Caching](#caching)
  - [Database conventions](#database-conventions)
  - [Security](#security)
  - [Multi-tenancy](#multi-tenancy)
- [Branching Strategy](#branching-strategy)
- [Protected Files](#protected-files)
- [Non-Negotiable Rules](#non-negotiable-rules)
- [Framework Structure](#framework-structure)
- [Credits](#credits)

---

## What is Gunawan for Mobile?

**AI Software Factory** is a structured framework of living documents and Claude Code commands that guides you through every phase of mobile software development — from product vision to App Store deployment.

**Gunawan** is the codename for this operation. An Indonesian name. Intentionally human. Intentionally unassuming. The whole point is that this AI team doesn't feel like a sci-fi deployment — it feels like a person you work with.

**Gunawan for Mobile** is the React Native / Expo variant of the Gunawan system. It adapts the entire Shannon Agentic AI Foundation — roles, standards, skills, workflows — specifically for mobile development on Expo SDK 54+ with Supabase as the backend.

**OpenClaw** is the AI orchestrator that runs Gunawan. In this implementation, OpenClaw is Claude Code — the primary AI agent runtime. It is not a single-agent worker; it is a **manager and orchestrator** of a team of specialised sub-agents, each playing a defined role in your software house.

```
You (Engineering Lead)
        ↓
  OpenClaw (Claude Code)
        ↓
  Gunawan Agent Team
        ↓
  Your Expo Project Repo
        ↓
  Shipped Mobile App
```

---

## The Newborn Principle

Every agent begins at **Level 0: Born**. No exceptions.

This is the most important concept in the entire system. Gunawan is not a senior engineer you hire with full autonomy on day one. Gunawan is raised.

Maturity is earned through repeated trustworthy behavior — never assumed, never granted by default. The developer sets direction. Gunawan executes. Over time, as trust is established, Gunawan earns more autonomy.

```
Born → Infant → Child → Adolescent → Teen/Junior → Adult
```

At Adult, Gunawan self-organises, presents at standups, and runs the software house. But that takes time. This is not a deployment. **It is a raising.**

---

## Prerequisites

Before setting up OpenClaw and Gunawan, ensure you have the following installed:

| Tool | Version | Purpose |
|------|---------|---------|
| [Node.js](https://nodejs.org/) | 20.9+ | EAS CLI and tooling |
| [Claude Code](https://claude.ai/code) | Latest | OpenClaw runtime (the AI agent) |
| [Git](https://git-scm.com/) | Any | Version control |
| [Expo CLI](https://docs.expo.dev/get-started/installation/) | Latest | React Native tooling |
| [EAS CLI](https://docs.expo.dev/eas/) | Latest | Build and submit to stores |
| [Supabase CLI](https://supabase.com/docs/guides/cli) | Latest | Database migrations |

You will also need accounts at:
- [Anthropic](https://console.anthropic.com/) — for Claude Code (the OpenClaw runtime)
- [Supabase](https://supabase.com/) — for the cloud-hosted PostgreSQL backend
- [Expo](https://expo.dev/) — for EAS builds and OTA updates

---

## OpenClaw Setup

### 1. Clone the template

Use this repository as a GitHub template to create your own copy, then clone it locally.

```bash
# Click "Use this template" on GitHub, then:
git clone https://github.com/your-org/your-project-name
cd your-project-name
```

### 2. Copy into your project

If you already have an existing Expo project, copy only the `.claude/` folder and the `foundation/` documents into it:

```bash
# From this repo, copy these into your project:
cp -r .claude/ /path/to/your-expo-project/
cp -r foundation/ /path/to/your-expo-project/
cp CLAUDE.md /path/to/your-expo-project/
cp standards-index.yml /path/to/your-expo-project/
```

> The `.claude/` folder is the heart of OpenClaw. It contains the behavioral constitution (`CLAUDE.md`), all workflow skills, and the enforcement hooks.

### 3. Run setup

```bash
bash setup.sh
```

This script verifies your environment, installs any required tooling, and confirms the foundation directory structure is intact.

### 4. Open OpenClaw (Claude Code)

Navigate to your project directory and open Claude Code:

```bash
cd your-project-name
claude
```

Claude Code is your OpenClaw instance. It will automatically load `CLAUDE.md` at the start of every session, establishing the behavioral rules for Gunawan.

### 5. Bootstrap the foundation

This is the first thing you run — once, before anything else. It builds all six foundation layers through a guided interview with you.

```
/foundation:bootstrap
```

The bootstrap process walks you through:

1. **Human Intent OS** — Your values, engineering philosophy, and decision framework
2. **Agent Foundation OS** — How Gunawan handles tasks, memory, handoffs, and escalation
3. **Role Definition OS** — The 6 roles and their responsibilities in your software house
4. **Design OS** — Design pipeline from discovery to implementation readiness
5. **Build OS** — Implementation, testing, and deployment standards
6. **Feedback OS** — Reflection, learning database, and governance

> **No workflow proceeds until this is complete.** The newborn gate will block every command until all six foundation layers exist.

### 6. Initialize your project

After bootstrapping, initialize your specific project:

```
/foundation:init
```

You will be asked whether this is a new or existing project. This command creates:

- `foundation/product-mission.md` — what this specific app is
- `foundation/tech-standards.md` — confirmed technology decisions
- Initial project context documents

---

## Nurturing Gunawan

### The maturity ladder

Gunawan's maturity is tracked in `CLAUDE.md`. The current level is always declared in this file. **Only you can promote Gunawan** — the agent never self-promotes.

| Level | Name | What Gunawan may do |
|-------|------|---------------------|
| 0 | **Born** | Observe only. Reads foundation. Explains plan. No output without your review. |
| 1 | **Infant** | Asks clarifying questions, proposes intent. No file changes. |
| 2 | **Child** | Small approved changes with full explanation and diff review. |
| 3 | **Adolescent** | Scoped feature work. Senior agent reviews output. Review gates apply. |
| 4 | **Teen/Junior** | Full role workflow in a bounded scope. You review at key gates. |
| 5 | **Adult** | Autonomous within role. Self-specialises. Presents at standups. |

### How to promote

Promotion is earned, not scheduled. Watch for the following signals before promoting:

**Born → Infant:** Gunawan has read the full foundation unprompted. It correctly identifies its role, classifies tasks, and asks good questions without being told to.

**Infant → Child:** Gunawan has proposed several plans that you approved with no corrections. Its assumptions are accurate. It has never modified a protected file without escalation.

**Child → Adolescent:** Gunawan's small changes have been correct and well-scoped consistently. It has demonstrated awareness of RLS, multi-tenancy, and security requirements without being reminded.

**Adolescent → Teen/Junior:** Gunawan has completed at least 3 full feature cycles (shape-spec → architecture → implementation → QA → fix) with only minor corrections at gates.

**Teen/Junior → Adult:** Gunawan consistently produces green tests, correct migrations, and self-reviews output before presenting it. It proactively identifies risks and escalates appropriately.

To promote, edit `CLAUDE.md`:

```markdown
**Current level: 2 (Child)** — update this line explicitly when promoting an agent.
```

Change the level number and name. That line is the only place maturity is tracked. Gunawan reads it at the start of every session.

### What to expect at each level

**At Level 0 (Born):** Gunawan will explain its plan fully before doing anything. It will list every file it intends to write. It will wait for you to say "proceed" before touching the codebase. Silence is never treated as approval.

**At Level 1 (Infant):** Gunawan will ask structured questions to close gaps in its understanding. It will propose intent with a brief rationale. It will not change files but may produce drafts for you to review.

**At Level 2 (Child):** Gunawan will show you a diff before applying it. Small, low-risk edits only. It will explain every decision. You review and confirm each change.

**At Level 3 (Adolescent):** Gunawan will execute a full feature scope but will pause at defined review gates — after architecture, after implementation, after tests. A senior sub-agent reviews output internally before it reaches you.

**At Level 4 (Teen/Junior):** Gunawan runs complete workflows with minimal interruption. You review at the end of each phase. It manages its own sub-agents and integrates results.

**At Level 5 (Adult):** Gunawan self-organises. It manages the software house, coordinates agents, presents findings, and escalates only when genuinely blocked. Your role becomes direction-setting, not oversight.

---

## The Foundation

The foundation is the **shared knowledge base** that every Gunawan agent reads before doing any work. It is stored as structured documents in your repository — readable by humans and agents alike.

### Loading order

Claude must load context in this exact order before any substantive work:

```
1. CLAUDE.md                          → behavioral constitution
2. foundation/human-intent-os/        → values, philosophy, decision rules
3. foundation/agent-foundation-os/    → runtime behavior, task lifecycle
4. foundation/role-definition-os/     → role-specific rules
5. foundation/design-os/              → relevant design artifacts
6. foundation/build-os/               → relevant implementation standards
7. foundation/feedback-os/            → reflection and learning rules
8. Current project specs + codebase
9. The current user request
```

Layers 1–4 are never skipped. If any of them are missing or empty, Gunawan stops and reports the gap.

### Phase 1 — Human Intent OS

`foundation/human-intent-os/`

Defines *why* this software exists and *how* people should think about building it. Every engineering decision traces back here.

| File | Purpose |
|------|---------|
| `mission.md` | Why this AI company exists |
| `philosophy.md` | Core values |
| `engineering-principles.md` | How engineers should think |
| `decision-framework.md` | Priority order: Correctness → Maintainability → Security → Simplicity → Optimization → Convenience |
| `quality-definition.md` | What "done" means. Never ship without tests. |
| `ethics-and-safety.md` | Safety policies and boundaries |
| `collaboration-rules.md` | How humans and agents work together |
| `risk-policy.md` | Risk classification and response |
| `design-principles.md` | Visual and UX design philosophy |
| `glossary.md` | Shared terminology |

### Phase 2 — Agent Foundation OS

`foundation/agent-foundation-os/`

Defines *how* Gunawan behaves at runtime — task lifecycle, communication, escalation, and reflection.

| File | Purpose |
|------|---------|
| `task-lifecycle.md` | 9-stage task lifecycle: Intake → Classification → Context → Assumptions → Plan → Execution → Review → Handoff → Reflection |
| `runtime-model.md` | How agents execute work |
| `communication-protocol.md` | How agents communicate with you |
| `context-ingestion.md` | How to load and prioritize context |
| `memory-policy.md` | What to remember and what to discard |
| `orchestration-rules.md` | Multi-agent coordination rules |
| `reflection-loop.md` | How Gunawan learns from each task |
| `escalation-policy.md` | When and how to escalate blocked work |
| `review-checklist.md` | Universal code review checklist |
| `output-contracts.md` | Output format guarantees |
| `tool-usage-policy.md` | When to use which tools |
| `handoff-contract.md` | How to hand work between agents |

### Phase 3 — Role Definition OS

`foundation/role-definition-os/`

Defines the 6 roles in the Gunawan software house. Every agent takes on exactly one role per task. Roles do not overlap.

| Role | Responsible for |
|------|----------------|
| **Product Strategist** | Intent shaping, product definition, user stories, PRDs |
| **System Architect** | Architecture decisions, system boundaries, data flow, API contracts |
| **Software Engineer** | Code implementation, tests, documentation |
| **QA Reviewer** | Quality verification, defect detection, regression testing |
| **DevOps Platform** | CI/CD, deployment readiness, infrastructure, EAS builds |
| **Consultant** | Tenant-specific requirements, client delivery |

Each role has 7 required documents: `role.md`, `responsibilities.md`, `boundaries.md`, `inputs.md`, `outputs.md`, `checklist.md`, `success-metrics.md`.

The collaboration map at `foundation/role-definition-os/collaboration-map.md` defines how roles hand off work to each other.

### Phase 4 — Design OS

`foundation/design-os/`

Templates for every stage of the design pipeline — from discovery to implementation readiness.

| File | Stage |
|------|-------|
| `discovery.md` | Discovery phase template |
| `product-definition.md` | Product specs and requirements |
| `domain-model.md` | Domain concepts and boundaries |
| `user-flows.md` | User journey mapping |
| `system-context.md` | System boundary diagram |
| `architecture-blueprint.md` | Architecture design template |
| `api-contracts.md` | API specification format |
| `implementation-readiness.md` | Go/no-go checklist |
| `integration-map.md` | External system integrations |
| `technical-risk-assessment.md` | Risk analysis template |
| `data-model.md` | Data model design |

Screen specs live in `design-os/screens/` — one file per feature screen, generated by `/design:import`.

### Phase 5 — Build OS

`foundation/build-os/`

Index pointing to implementation standards, testing requirements, and deployment patterns. Used by `/foundation:inject-standards` to load relevant context automatically.

### Phase 6 — Feedback OS

`foundation/feedback-os/`

The learning system. Every task produces a reflection. Reflections feed the learning database. The learning database makes Gunawan better over time.

| File | Purpose |
|------|---------|
| `task-reflection.md` | Reflection template (used by `/reflect-task`) |
| `failure-analysis.md` | Post-mortem template |
| `learning-database.md` | Accumulated lessons from tasks |
| `knowledge-library.md` | Shared knowledge across sessions |
| `improvement-proposals.md` | Proposed changes to the foundation itself |
| `agent-performance.md` | Metrics per agent and role |
| `governance-model.md` | How the software house governs itself |
| `scaling-policy.md` | When and how to scale the team |

---

## Mobile Stack

Gunawan for Mobile is configured for this exact stack. Do not deviate without updating the foundation documents.

| Layer | Technology | Notes |
|-------|-----------|-------|
| **Frontend** | Expo (React Native) + TypeScript | SDK 54+, Expo Router for navigation |
| **Backend / Database** | Supabase (PostgreSQL) | Cloud-hosted; no self-hosted Supabase on K8s |
| **Auth** | Supabase Auth | Email, OAuth, OTP, magic link |
| **Styling** | NativeWind + React Native StyleSheet | NativeWind for Tailwind-compatible utilities; StyleSheet for performance-critical components |
| **Data fetching** | TanStack Query | Mandatory; `useEffect` + `fetch` is banned |
| **Validation** | Zod | Always `safeParse()`, never `parse()` |
| **Runtime** | Node.js 20.9+ | For EAS CLI tooling |
| **Builds** | EAS Build | Managed workflow for iOS and Android |
| **OTA updates** | EAS Update | For JavaScript-only updates between store releases |

> **React Native has no Server Components and no `'use client'` directive.** All components are client-side. There is no server/browser split in React Native. The Supabase client is a single `createClient()` instance.

---

## Command Reference

All commands are run inside Claude Code (OpenClaw). Type the command and press Enter.

### Foundation commands

| Command | When to use |
|---------|-------------|
| `/foundation:bootstrap` | **First time only.** Builds all six foundation layers through guided interview. |
| `/foundation:init` | **Once per project.** Initializes project context (new or existing). |
| `/foundation:discover` | Documents project standards and produces `product-mission.md`. |
| `/foundation:shape-spec` | Specs a single feature. Produces a shape spec document. |
| `/foundation:inject-standards` | Auto-loads relevant standards from `standards-index.yml` for the current task. |

### Architecture commands

| Command | When to use |
|---------|-------------|
| `/architecture:new-feature` | When a feature requires schema changes. Produces migration + RPC + API contract. |
| `/architecture:review` | Reviews existing architecture against current standards. |

### Design commands

| Command | When to use |
|---------|-------------|
| `/design:import` | Imports a Figma file or mockups into `design-os/screens/`. |
| `/design:system` | Documents design tokens (colors, typography, spacing) into `design-os/design-system.md`. |

### Implementation commands

| Command | When to use |
|---------|-------------|
| `/implementation:new-feature` | Implements a fully specced feature. Produces Zod schema + hooks + components. |
| `/implementation:review` | Reviews implemented code against Gunawan standards. |

### QA commands

| Command | When to use |
|---------|-------------|
| `/qa:new-tests` | Scaffolds unit, component, and E2E tests for a feature. |
| `/qa:fix` | Runs tests, identifies failures, fixes them, re-runs until green. |

### Deployment commands

| Command | When to use |
|---------|-------------|
| `/deployment:k8s-config` | Generates Kubernetes manifests for supporting services (not the app itself — use EAS for that). |
| `/deployment:release` | Pre-release checklist + production deploy gate. |

---

## The Development Workflow

Follow this sequence for every project. Each phase builds on the previous. Each command ends with a `What's Next` telling you exactly what to run next.

```
── Foundation (run once, before anything else) ──────────────────
/foundation:bootstrap   →  builds all six foundation layers

── Project setup (run once per project) ─────────────────────────
/foundation:init        →  initializes project context
/foundation:discover    →  documents standards + product-mission.md

── Optional design import ────────────────────────────────────────
/design:import          →  imports Figma or mockups into design-os/screens/
/design:system          →  documents design tokens

── Per feature (repeat for every feature) ───────────────────────
/foundation:shape-spec        →  specs the feature
/architecture:new-feature     →  schema migration + RPC + API contract (if DB changes needed)
/implementation:new-feature   →  hooks + Zod schema + components
/qa:new-tests                 →  unit + component + E2E test scaffold
/qa:fix                       →  run tests, fix failures, re-run until green

── Shipping ──────────────────────────────────────────────────────
/deployment:k8s-config  →  generate manifests for supporting infrastructure
/deployment:release     →  pre-release checklist + production deploy gate
```

---

## The Newborn Gate

The newborn gate is the most critical skill in the system. **No workflow proceeds without a passing gate.**

Before every substantive command, Gunawan runs through this checklist internally:

**1. Foundation integrity**
All five core foundation files must exist and be non-empty:
- `foundation/human-intent-os/mission.md`
- `foundation/human-intent-os/risk-policy.md`
- `foundation/agent-foundation-os/task-lifecycle.md`
- `foundation/agent-foundation-os/escalation-policy.md`
- `foundation/role-definition-os/role-map.md`

**2. Role declaration**
Gunawan must explicitly state which role it is acting as for this task.

**3. Task classification**
The task must be classified as one of: Discovery, Design, Implementation, Review, Debug, or Deployment.

**4. Assumption declaration**
All assumptions must be listed explicitly. Silent assumptions are the primary cause of agent drift.

**5. Protected files check**
Any protected file in scope must be identified before proceeding.

**6. Approval gate identification**
The appropriate approval gate must be named before any file is written or modified.

When the gate passes, you will see:

```
NEWBORN GATE: PASSED

Role: [active role]
Task type: [classification]
Maturity level: [0/1/2/3]
Foundation loaded: yes
Assumptions: [list or "none"]
Protected files in scope: [list or "none"]
Approval required: [yes/no — and for what]

Proceeding with: [one-sentence description of what comes next]
```

If it fails:

```
NEWBORN GATE: BLOCKED

Reason: [specific item that failed]
Required action: [exactly what must happen before this can proceed]
```

---

## Architecture Overview

### System topology

```
┌─────────────────────────────────────────┐
│            Mobile App (Expo)            │
│  React Native + TypeScript + NativeWind │
│  TanStack Query  ·  Expo Router         │
└───────────────────┬─────────────────────┘
                    │ HTTPS / REST / Realtime
┌───────────────────▼─────────────────────┐
│         Supabase (Cloud-hosted)         │
│  PostgreSQL  ·  Auth  ·  Storage        │
│  RLS on every table  ·  RPCs for logic  │
└─────────────────────────────────────────┘
```

No server-side rendering. No Next.js. No separate API server. The Expo app communicates directly with Supabase. All business logic that requires joins, aggregations, or security-sensitive operations is encapsulated in RPCs (PostgreSQL functions).

### Agent orchestration

OpenClaw (Claude Code) is not a single worker. It is the **orchestrator** of a team of specialised sub-agents:

| Sub-agent | Gunawan role | Responsible for |
|-----------|-------------|----------------|
| Claude Code (main) | Product Strategist + Orchestrator | Interpret your intent, coordinate sub-agents, integrate results, present to you |
| Explore agent | Discovery | Codebase reading, file search, pattern discovery |
| Plan agent | System Architect | Technical design, ADRs, architecture decisions |
| Builder agent | Software Engineer | Implementation — writing and modifying files |
| Reviewer agent | QA Reviewer | Checking output against Gunawan standards |

**Orchestration rules:**
- Gunawan never does discovery work itself when an Explore agent can do it
- Gunawan never does implementation itself when a Builder agent should
- Gunawan always presents a plan to you before spawning Builder agents
- Gunawan always runs a Reviewer agent after Builder completes — it does not self-review

---

## Mobile Standards

### Project structure

```
src/
├── app/                      # Expo Router (routing only — no business logic)
│   ├── (auth)/               # Auth group screens
│   ├── (tabs)/               # Tab group screens
│   └── _layout.tsx           # Root layout
├── features/                 # Feature-specific UI logic
│   └── [feature-name]/
│       ├── components/       # Feature components
│       ├── hooks/            # use*Query and use*Mutation hooks
│       └── types.ts          # Feature-specific types
├── components/               # Shared React Native components
├── hooks/                    # Shared custom hooks
├── contexts/                 # React Context providers (QueryClient, auth, tenant)
├── types/                    # Shared TypeScript types + Zod schemas
├── utils/                    # Shared utilities (no side effects)
├── constants/
│   └── env.ts                # Zod-validated EXPO_PUBLIC_* env vars
└── lib/
    └── supabase/
        └── client.ts         # Single createClient() instance
```

### Data fetching

TanStack Query is the **only** permitted data fetching mechanism. `useEffect` + `fetch` is banned.

**Queries (reads):**

```typescript
export function useFeatureList(tenantId: string) {
  return useQuery({
    queryKey: ['feature', tenantId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('feature_table')
        .select('*')
        .eq('tenant_id', tenantId)
        .order('created_at', { ascending: false })

      if (error) throw error
      return data as FeatureItem[]
    },
    enabled: !!tenantId,
    staleTime: 5 * 60 * 1000,
  })
}
```

**Mutations (writes):**

```typescript
export function useCreateFeature() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (input: CreateFeatureInput) => {
      const parsed = CreateFeatureSchema.safeParse(input)
      if (!parsed.success) throw new Error('Invalid input')

      const { data, error } = await supabase
        .from('feature_table')
        .insert(parsed.data)
        .select()
        .single()

      if (error) throw error
      return data as FeatureItem
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['feature', variables.tenantId] })
    },
  })
}
```

**Always return typed results.** Never throw unhandled errors to the UI. Handle error states in the hook.

### Caching

TanStack Query is the **only** caching layer. No server-side caching directives — they are not applicable in React Native.

| Default | Value |
|---------|-------|
| `staleTime` | 5 minutes |
| `gcTime` | 10 minutes |
| `refetchOnWindowFocus` | `false` |

Never cache user-specific or RLS-governed data beyond the TanStack Query session lifetime. Invalidate queries on mutation success — do not manually update the cache.

### Database conventions

Every table must follow these conventions:

```sql
create table public.your_table (
  id          uuid primary key default gen_random_uuid(),
  tenant_id   uuid not null references public.tenants(id),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  created_by  uuid references auth.users(id),
  updated_by  uuid references auth.users(id)
  -- your columns here
);

-- RLS must be in the same migration as the table creation
alter table public.your_table enable row level security;

create policy "tenant_isolation" on public.your_table
  using ((select private.get_active_tenant_id()) = tenant_id);
```

**RPCs for logic:** Any query requiring joins, aggregations, or business logic must be a PostgreSQL RPC (function). Direct queries are only permitted for simple single-table operations.

```sql
create or replace function public.get_feature_summary(p_tenant_id uuid)
returns table (...) language sql security invoker as $$
  -- logic here
$$;
```

`SECURITY INVOKER` always. `SECURITY DEFINER` only in the `private` schema.

### Security

- No `service_role` keys in client-side code — ever
- OWASP Top 10 compliance on every project
- Never commit secrets — use EAS Secrets for build-time secrets; GitHub Actions Environments for CI/CD
- All environment variables validated at startup with Zod:

```typescript
// src/constants/env.ts
import { z } from 'zod'

const EnvSchema = z.object({
  EXPO_PUBLIC_SUPABASE_URL: z.string().url(),
  EXPO_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1),
})

export const env = EnvSchema.parse({
  EXPO_PUBLIC_SUPABASE_URL: process.env.EXPO_PUBLIC_SUPABASE_URL,
  EXPO_PUBLIC_SUPABASE_ANON_KEY: process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY,
})
```

### Multi-tenancy

Organization-based multi-tenancy. Every business table has `tenant_id`. Tenant context is stored on the user's profile — not in session variables.

```typescript
// RLS policies use this function — never inline the tenant check
(select private.get_active_tenant_id()) = tenant_id
```

The active tenant is stored in `profiles.active_tenant_id`. Switching tenants updates this column and invalidates all TanStack Query caches.

---

## Branching Strategy

```
feature/*   → PR → dev     (squash and merge)
fix/*       → PR → dev     (squash and merge)
dev         → PR → main    (merge commit — semantic-release needs individual messages)
hotfix/*    → PR → main    (squash) + sync PR back to dev
```

There is no `prod` branch. Production is a **tag event** — semantic-release creates the version tag and triggers the EAS production build.

| Branch | Protected | Purpose |
|--------|-----------|---------|
| `main` | Yes | Production-ready code. Direct pushes forbidden. |
| `dev` | Yes | Integration branch. All features merge here first. |
| `feature/*` | No | New features. Branched from `dev`. |
| `fix/*` | No | Bug fixes. Branched from `dev`. |
| `hotfix/*` | No | Critical production fixes. Branched from `main`. |

---

## Protected Files

Gunawan must never modify these without explicit human approval and full escalation.

```
CLAUDE.md                       # Behavioral constitution — never touch
foundation/**                   # All foundation layers — architecture changes only
.env*                           # All environment files — secrets live here
supabase/migrations/**          # Existing migrations — new ones are additive only
.github/workflows/**            # CI/CD pipelines
k8s/**                          # Kubernetes manifests
.claude/settings.json           # Claude Code settings
```

When Gunawan needs to touch a protected file, it will output:

```
ESCALATION REQUIRED: This task requires modifying a protected file.
File: [path]
Reason: [why this change is needed]
Risk: [what could go wrong]
I will not proceed until you explicitly approve this change.
```

Two hooks enforce this automatically:
- `.claude/hooks/verify-foundation.ps1` — blocks writes when foundation is incomplete
- `.claude/hooks/protect-critical-files.ps1` — escalates on protected file edits

---

## Non-Negotiable Rules

These rules cannot be overridden. They apply to every session, every agent, every feature.

| # | Rule |
|---|------|
| 1 | Never create a table without RLS **in the same migration** |
| 2 | Never use `SECURITY DEFINER` outside the `private` schema |
| 3 | Never store tenant context in session variables |
| 4 | Never put `service_role` keys in client-side code |
| 5 | Always use `safeParse()` — never `parse()` |
| 6 | Always return typed results from query/mutation hooks — never throw unhandled errors to UI |
| 7 | Never use `useEffect` + `fetch` for data fetching — always use TanStack Query |
| 8 | Never commit secrets |
| 9 | Never push directly to `main` or `dev` |
| 10 | Never deploy to production without a version tag from semantic-release |
| 11 | Never proceed past the newborn gate without a passing check |
| 12 | Never modify protected files without explicit human approval |
| 13 | Never silently assume — always declare assumptions before acting |
| 14 | Never self-promote maturity level — it is granted by the human |

---

## Framework Structure

```
.claude/
  CLAUDE.md                     # Behavioral constitution (auto-loaded every session)
  skills/
    newborn-gate/SKILL.md       # Gate that blocks all workflows until foundation is loaded
    reflect-task/SKILL.md       # Reflection skill — run after every substantive task
  commands/
    foundation/                 # /foundation:* commands
    architecture-os/            # /architecture:* commands
    implementation-os/          # /implementation:* commands
    data-fetching-os/           # /data-fetching:* commands
    qa-os/                      # /qa:* commands
    deployment-os/              # /deployment:* commands
    design-os/                  # /design:* commands
  hooks/
    verify-foundation.ps1       # Enforcement: blocks writes on missing foundation
    protect-critical-files.ps1  # Enforcement: escalates on protected file edits

foundation/
  human-intent-os/              # Phase 1: Values, philosophy, decision rules
  agent-foundation-os/          # Phase 2: Runtime behavior, task lifecycle
  role-definition-os/           # Phase 3: 6 roles and their boundaries
  design-os/                    # Phase 4: Design pipeline templates
  build-os/                     # Phase 5: Implementation standards index
  feedback-os/                  # Phase 6: Reflection, learning, governance
  product-mission.md            # What this specific app is (generated by /foundation:init)
  tech-standards.md             # Technology decisions (generated by /foundation:discover)

architecture-os/
  system-design.md              # System topology and boundaries
  schema-conventions.md         # Database table and column standards
  rpc-standards.md              # RPC patterns and naming
  audit-trail.md                # Audit logging requirements

implementation-os/
  standards.md                  # Coding standards, component patterns, hooks

data-fetching-os/
  server-vs-client.md           # What runs where (TanStack Query rules)
  caching-strategy.md           # Caching defaults and invalidation rules

qa-os/                          # (generated per-project by /qa:new-tests)

deployment-os/
  ci-cd.md                      # GitHub Actions pipeline configuration
  environments.md               # Dev / staging / production environment setup
  release-process.md            # Branching, semantic-release, EAS submit
  k8s-sizing.md                 # Resource sizing (supporting services only)

design-os/
  design-system.md              # Design tokens (generated by /design:system)
  product-vision.md             # Product vision document
  screens/                      # Per-screen specs (generated by /design:import)
    _template.md                # Template for new screen specs

docs/
  Shannon Agentic AI Foundation.md  # The theoretical foundation document
```

---

## Credits

Built on top of and inspired by:

- [Design OS](https://github.com/buildermethods/design-os) by Brian Casel
- [Agent OS](https://github.com/buildermethods/agent-os) by Brian Casel

Created by [Russell](https://github.com/russellotniel)

Operation Gunawan by [iannn07](https://github.com/iannn07)
