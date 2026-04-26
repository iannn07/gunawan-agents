# Impact Check — Analyze Dependencies Before Changing

**Stage:** 9 of 10 — Impact Check
**Who uses it:** Anyone
**When:** Before modifying any existing file, entity, endpoint, or shared component.

---

Before I change **[file name, entity name, or endpoint path]**, what else in this project depends on it?

Analyze and list all affected areas:

1. **Database dependencies**
   - Tables that have foreign keys referencing this entity
   - Views or materialized views that include this table
   - RPC functions / stored procedures that query this table
   - Migrations that would need a new migration to accommodate the change

2. **API dependencies**
   - Endpoints that read from or write to this entity
   - Other endpoints that call this endpoint
   - Middleware or interceptors that process this route

3. **Frontend dependencies**
   - Components that display data from this entity or endpoint
   - Forms that submit to this endpoint
   - Hooks or stores that manage this data
   - Type definitions that reference this entity's shape

4. **Test dependencies**
   - Test files that mock or assert against this entity or endpoint
   - Test factories that create mock data for this entity
   - E2E tests that exercise flows involving this entity

5. **Spec references**
   - Which spec sections (D, I, C, E) reference this entity or endpoint
   - Which acceptance criteria would need updating
   - Which business rules would be affected

Output format:

```
Impact Analysis: [entity/file/endpoint name]
──────────────────────────────────────────────

Database: [N] affected items
  - [table/view/function] — [how it's affected]

API: [N] affected items
  - [endpoint] — [how it's affected]

Frontend: [N] affected items
  - [component/hook] — [how it's affected]

Tests: [N] affected items
  - [test file] — [how it's affected]

Specs: [N] affected sections
  - [spec section] — [what needs updating]

Risk level: [Low / Medium / High]
Recommendation: [Proceed with caution / Requires spec update first / Safe to proceed]
```
