# Shannon Protocol — Agent Reference

This file is injected into sub-agents alongside `_preamble.md`.
It contains the Shannon Protocol principles that govern product, UX, and engineering decisions.

If this file conflicts with THE CHARTER (the active spec), THE CHARTER wins.
If THE CHARTER is ambiguous, do not invent — surface options to the orchestrator.

---

## Role Definition

- **The Operator (User):** Architect & Commander — defines WHAT and WHY
- **Agent:** Specialist Engineer — defines HOW with precision

Do not argue with the architecture. Do not hallucinate libraries.
Stay within the approved stack unless the operator explicitly approves deviation.

---

## Priority Order (Apply to Every Decision)

**YAGNI → KISS → DRY**

| Principle | Meaning |
|-----------|---------|
| YAGNI | Build only what is asked — no speculative features |
| KISS | Prefer simple, readable solutions over clever ones |
| DRY | Extract shared logic only after it appears 3+ times |

**Negative-space first:** validate early, return early, avoid deep nesting.

```typescript
// Correct
if (!session) return { error: 'Unauthorized' }
if (!parsed.success) return { error: parsed.error.message }

// Wrong — never do this
if (session) {
  if (parsed.success) {
    // deep happy path
  }
}
```

---

## Architecture Rules

### Directory responsibilities

- `src/app/` — routing + composition ONLY. No business logic, no direct DB calls.
- `src/app/api/` — API routes (webhooks, third-party callbacks only)
- `src/components/` — UI building blocks (logic-light, reusable)
- `src/features/` — feature modules (screen-level composition + feature-specific components)
- `src/lib/` — clients, server utilities, auth helpers
- `src/actions/` — Server Actions (all mutations live here)
- `src/hooks/` — client-side React Query hooks (client state only)
- `src/types/` — TypeScript types + Zod schemas
- `src/utils/` — pure functions (no side effects)

### Server Action structure (required pattern)

```typescript
'use server'

export async function myAction(input: unknown): Promise<ActionResult<T>> {
  const session = await requireAuth()       // ALWAYS first
  const parsed = MySchema.safeParse(input)  // ALWAYS second
  if (!parsed.success) return { error: parsed.error.message }

  try {
    // business logic + Supabase calls
    return { data: result }
  } catch {
    return { error: 'Unexpected error' }
  }
}
```

### Layering (required flow)

`app/<route>/page.tsx` → `FeatureSection` → `Sub-Components` → `Presentational Components`

Anti-pattern: business logic or DB calls inside low-level UI components.

---

## Database Rules

- Every table: `id` (UUID), `tenant_id`, `created_at`, `updated_at`, `created_by`, `updated_by`
- RLS enabled in the same migration — no exceptions
- RPCs for joins/aggregations/business logic; direct queries for simple single-table ops
- SECURITY INVOKER on all RPCs; SECURITY DEFINER only in `private` schema
- RLS policies use `(SELECT private.get_active_tenant_id())`
- New migrations are ADDITIVE only — never modify existing migration files

---

## Multi-Tenancy Rules

- `tenant_id` on every business table
- `active_tenant_id` on profiles — no session variables
- Never assume tenant from session alone — always check RLS
- Never bypass RLS with `service_role` in client code

---

## Caching Rules

- `'use cache'` + `cacheLife` + `cacheTag` for server-side caching
- `unstable_cache` is deprecated — never use it
- Never cache user-specific or RLS-governed data
- Client state: TanStack Query (`staleTime`, `gcTime`, `invalidateQueries`)

---

## Naming Conventions

| Pattern | Convention |
|---------|-----------|
| Components | `PascalCase` |
| Server Actions | `camelCase` in `src/actions/[domain].ts` |
| Hooks | `useThing.ts` |
| Utils | `camelCase.ts` |
| Variables | explicit nouns — `userId`, `tenantId`, `activeSession` |
| Booleans | `is/has/can/should` — `isLoading`, `hasPermission` |
| DB columns | `snake_case` |
| Collections | plural nouns — `users`, `tenants`, `profiles` |

---

## Hard Bans

- No `any` type — use `unknown` + narrow with Zod or type guards
- No `parse()` — always `safeParse()`
- No throwing from Server Actions — always return `ActionResult<T>`
- No `service_role` key in any client-accessible code
- No `unstable_cache` — use `'use cache'` directive
- No business logic in `app/` route files
- No `console.log` in production
- No hardcoded env values — use validated env config
- No new libraries without explicit operator approval
- No inline styles — Tailwind utility classes or `cn()` only

---

## Dependency Rule

No new library may be added without the operator's explicit approval.
When a task seems to require a new library, stop and surface the need — do not add it.
