# Gunawan AI Company — Claude Code Configuration

## Project context

This is the **XLSMART Package Advisor** — a single-page web tool where an SME owner
answers 3 questions (industry, business size, needs) and receives a personalized
XLSMART connectivity package recommendation powered by the Claude API.

Read `SANTOSO-PROTOCOL-PROJECT.md` for full company context, agent roster,
architecture decisions, sprint plan, and success criteria. That file is the
single source of truth.

---

## Agents

This project is operated by 7 AI agents orchestrated by Paperclip (Santoso):

| Agent | Role | Output location |
|-------|------|-----------------|
| **Dharmawan** | Researcher — scrapes xlsmart.co.id, produces structured data | `data/` |
| **Gunawan** | Analyst — builds recommendation logic and Claude API prompts | `analysis/` |
| **Langston** | Designer — creates UI specifications in markdown, no code | `design/` |
| **Quinn** | Engineer — writes all application code | `src/` |
| **Hendrawan** | QA — tests the app, files bugs, produces test reports | `test/` |
| **Alpha** | DevOps — deploys to VPS, configures public URL and SSL | VPS infra |
| **Linawati** | Marketing/Sales — writes copy, social posts, emails, SEO | `marketing-assets/` |

---

## Framework standard

All application code in this project is built on the **webapp-gunawan** framework.

The full framework lives at `../webapp-gunawan/` (sibling directory in the same repo).
Quinn must copy the framework into the Package Advisor project before writing any code:

```bash
# Run from the santoso-protocol/ directory
cp -r ../webapp-gunawan/.gunawan ./.gunawan
cp -r ../webapp-gunawan/.claude/agents ./.claude/agents-framework
```

The framework provides:
- `.gunawan/foundation/` — human intent OS, agent foundation OS, role definitions, build OS, design OS, feedback OS
- `.gunawan/architecture-os/` — schema conventions, RPC standards, API contracts
- `.gunawan/implementation-os/` — coding standards
- `.gunawan/qa-os/` — testing strategy
- `.gunawan/deployment-os/` — deployment and release process

Quinn reads these layers in the order defined by `webapp-gunawan/CLAUDE.md` before writing any code.
Hendrawan reads `.gunawan/qa-os/strategy.md` before writing any test.
Alpha reads `.gunawan/deployment-os/` before any deployment step.

---

## Tech stack

Defined by `webapp-gunawan`. For this project (stateless, no multi-tenancy):

- **Framework:** Next.js (latest stable) with App Router
- **Language:** TypeScript — strict mode, no `any` types
- **Styling:** Tailwind CSS 4.x + shadcn/ui components
- **AI:** Claude API via `@anthropic-ai/sdk`
- **Validation:** Zod — always `safeParse()`, never `parse()`
- **Database:** Supabase (only if state persistence is needed — default is stateless)
- **Deployment:** Docker on Ubuntu VPS

---

## Code standards

Governed by `webapp-gunawan`. Key rules for this project:

- TypeScript strict mode — `any` is a build error
- All Claude API calls go through server-side API routes — never in client components
- Always use `safeParse()` — never `parse()` (webapp-gunawan rule #5)
- One component per file, named exports only
- Tailwind for all styling — no CSS modules, no styled-components, no inline styles
- Mobile-first responsive design (design for 375px, scale up)
- All secrets via environment variables — never hardcoded
- `src/components/` for UI components, `src/lib/` for utilities and data logic

---

## File output conventions

Each agent writes to their designated folder. Quinn's application code lives in `src/`.
The folder structure mirrors Section 11 of `SANTOSO-PROTOCOL-PROJECT.md`:

```
data/                 ← Dharmawan's research output
analysis/             ← Gunawan's analysis and prompt templates
design/               ← Langston's UI specifications
marketing-assets/     ← Linawati's copy and materials
test/                 ← Hendrawan's test reports and bug tickets
src/                  ← Quinn's application code (Next.js project root)
```

---

## Communication model

- Agents report task status by commenting on their Paperclip issue
- Santoso (Paperclip) routes updates to the Gunawan HQ Telegram group via the bridge
- Human approval is required before: production deployment, budget overruns, scope changes
- When in doubt, ask via Paperclip — do not make unilateral decisions on product scope

---

## Protected files

Do not modify these files — they are the governing documents:
- `SANTOSO-PROTOCOL-PROJECT.md`
- `CLAUDE.md` (this file)
