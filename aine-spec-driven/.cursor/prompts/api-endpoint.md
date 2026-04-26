# API Endpoint — Build from Spec Interface Contract

**Stage:** 4 of 10 — API Endpoint
**Who uses it:** Backend Developer
**When:** After database migration is applied, when implementing the API layer.

---

Build the **[HTTP method] [endpoint path]** API based on spec section I of `specs/[module-name].md`.

Implement in this order:

1. **Input validation**: Validate the request body / query parameters against the types defined in the spec. Use safe validation (`safeParse()`) — never throwing validation.

2. **Authentication check**: Verify the caller is authenticated. Return 401 if not.

3. **Authorization check**: Verify the caller has the required role as listed in the spec (e.g., "Who can call it: [role names]"). Return 403 if unauthorized.

4. **Business logic**: Implement the behavior described in Section C (Constraints & Business Rules). Reference the specific rule numbers (C-1, C-2, ...).

5. **Database operation**: Execute the query/mutation through the project's data access layer — never raw queries in the endpoint handler.

6. **Success response**: Return the response shape and status code defined in the spec.

7. **Error responses**: Handle every error case listed in the spec:
   - 400 — Validation failure (with specific field errors)
   - 401 — Not authenticated
   - 403 — Wrong role
   - 404 — Resource not found
   - 409 — Conflict (duplicate, invalid state transition)
   - 500 — Unexpected error (log details, return generic message)

<!--
  Example A (Java / Spring Boot):
  - Controller + Service + Repository layers
  - Use @Valid for request DTO validation
  - Use Spring Security annotations for auth

  Example B (Next.js / TypeScript):
  - API route handler or server action
  - Use Zod/Valibot safeParse for validation
  - Check session/JWT for auth
-->
