# Requirements — Expand to Full DICE Specification

**Stage:** 1 of 10 — Requirements
**Who uses it:** Solution Architect (SA)
**When:** At the start of a new feature, when you have a business requirement but no spec yet.

---

Take this business requirement and expand it into a full specification using the DICE format:

**Requirement:**
[Paste the business requirement here]

For each section, produce:

## D — Data Model
- Every entity (database table) the feature touches
- Field name, type, required/optional, constraints, and notes
- Primary keys, foreign key relationships, and indexes
- Audit columns: `created_at`, `updated_at`, `created_by`

## I — Interface Contract (API Endpoints)
- HTTP method and path for each endpoint
- Who can call it (role names from the project's role table)
- Request body or query parameters with types
- Success response shape and status code
- All error responses: 400, 401, 403, 404, 409, 500

## C — Constraints & Business Rules
- Numbered rules (C-1, C-2, ...) that govern behavior
- State transitions, approval flows, permission checks
- Rules must use "must" or "must not" — never "should" or "might"

## E — Evidence (Acceptance Criteria)
- Testable Given/When/Then statements, numbered (E-1, E-2, ...)
- Cover the normal case first
- At least 3 edge cases per endpoint
- Error scenarios: wrong role, missing fields, invalid state transitions

## UI States
For every data-driven screen, describe the 4 states:
- **Loading**: What the user sees while data is fetching
- **Error**: What the user sees when the fetch or action fails
- **Empty**: What the user sees when there is no data
- **Success**: What the user sees when data is present
