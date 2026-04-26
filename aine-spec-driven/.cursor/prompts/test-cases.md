# Test Cases — Generate from Acceptance Criteria

**Stage:** 6 of 10 — Test Cases
**Who uses it:** Quality Control (QC)
**When:** As soon as Section E of the spec is written — can run in parallel with implementation.

---

From the acceptance criteria in spec section E of `specs/[module-name].md`, generate a test suite covering:

1. **Normal case** (happy path) for every endpoint and user flow
2. **At least 3 edge cases per endpoint**, including:
   - Missing required fields → expect 400
   - Wrong role / unauthorized → expect 403
   - Resource not found → expect 404
   - Duplicate or conflicting state → expect 409
   - Boundary values (empty strings, max length, zero, negative numbers)

For each test case:

- **Name**: Reference the criterion number — `E-[N]: [Given/When/Then summary]`
- **Setup**: What preconditions are needed (test data, auth token, database state)
- **Action**: The exact API call or UI interaction
- **Assertion**: The expected response, status code, or UI change
- **Teardown**: Any cleanup needed

Output format depends on the project's test tooling:

<!--
  Example A (Java / Spring Boot):
  - Generate JUnit 5 test class with @SpringBootTest
  - Use MockMvc for API endpoint tests
  - Generate a Postman collection (.json) for manual verification

  Example B (Next.js / TypeScript):
  - Generate Vitest test file following the project's test standard
  - Use the mock factory pattern for test data
  - Follow execution order: mocks → imports → describe → beforeEach → it blocks
-->

Mapping from spec to tests:

```
Spec Section E                    Test Suite
─────────────                     ──────────
E-1: Given ... when ... then ...  → test('E-1: ...')
E-2: Given ... when ... then ...  → test('E-2: ...')
E-3: Given ... when ... then ...  → test('E-3: ...')
```

A feature is not done until every acceptance criterion in Section E has a passing test.
