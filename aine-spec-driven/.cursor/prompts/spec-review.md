# Spec Review — Check for Completeness and Testability

**Stage:** 8 of 10 — Spec Review
**Who uses it:** QC, Solution Architect (SA)
**When:** After a spec is drafted, before any implementation begins.

---

Review the specification at `specs/[module-name].md`.

List everything that is **missing, too vague, or untestable**. Check each section:

## Section D — Data Model
- [ ] Are there undefined field types?
- [ ] Are there missing constraints (required, unique, max length)?
- [ ] Are foreign key relationships fully specified with ON DELETE behavior?
- [ ] Are audit columns present (`created_at`, `updated_at`, `created_by`)?
- [ ] Are indexes identified for frequently queried columns?
- [ ] Are there entities referenced in other sections but not defined here?

## Section I — Interface Contract
- [ ] Does every endpoint have an HTTP method and path?
- [ ] Are auth requirements specified for every endpoint (which roles)?
- [ ] Are request parameters fully typed with required/optional markers?
- [ ] Is the success response shape defined with a status code?
- [ ] Are ALL error responses listed (400, 401, 403, 404, 409)?
- [ ] Are there endpoints mentioned in business rules but not defined here?

## Section C — Constraints & Business Rules
- [ ] Is every rule numbered (C-1, C-2, ...)?
- [ ] Are there vague words like "should", "might", "usually", "appropriate"?
- [ ] Are state transitions explicit (what triggers them, what blocks them)?
- [ ] Do permission rules reference specific roles from the Roles table?
- [ ] Are there implicit rules that should be made explicit?

## Section E — Evidence (Acceptance Criteria)
- [ ] Is every criterion numbered (E-1, E-2, ...)?
- [ ] Does every criterion follow Given/When/Then format?
- [ ] Is every criterion independently testable?
- [ ] Is the normal case (happy path) covered for every endpoint?
- [ ] Are there at least 3 edge cases per endpoint?
- [ ] Are error scenarios covered (wrong role, missing field, invalid state)?
- [ ] Are there business rules in Section C without corresponding test criteria?

## Cross-Section Consistency
- [ ] Does every entity in Section D appear in at least one endpoint in Section I?
- [ ] Does every endpoint in Section I reference the correct roles?
- [ ] Does every business rule in Section C have at least one acceptance criterion in Section E?
- [ ] Are UI states (loading, error, empty, success) defined for every data-driven screen?

For each gap found, provide:
- **Location**: Section and item number
- **Issue**: What is missing or vague
- **Suggestion**: How to fix it (be specific)
