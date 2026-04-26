# [Module Name] — Feature Specification

## Status

| Field       | Value          |
| ----------- | -------------- |
| Version     | 1.0            |
| Author      | [SA Name]      |
| QC Sign-off | Pending        |
| Date        | [YYYY-MM-DD]   |

---

## D — Data Model

Describe every entity (database table) this feature touches. Include new tables and existing tables that gain columns.

### [Entity Name]

| Field       | Type     | Required | Notes                       |
| ----------- | -------- | -------- | --------------------------- |
| id          | UUID     | Yes      | Primary key                 |
| created_at  | DateTime | Yes      | Auto-set on creation        |
| updated_at  | DateTime | Yes      | Auto-set on every update    |
| created_by  | UUID     | Yes      | FK to users table           |
| [field]     | [type]   | Yes/No   | [description and rules]     |

**Indexes:**
- [column(s)] — [reason: e.g., "frequent filter in list endpoint"]

**Foreign Keys:**
- [field] → [target_table].[target_column] (ON DELETE [CASCADE/SET NULL/RESTRICT])

---

## I — Interface Contract (API Endpoints)

### GET /[resource]

- **Who can call it:** [role names]
- **Query parameters:**
  | Param    | Type   | Required | Default | Notes          |
  | -------- | ------ | -------- | ------- | -------------- |
  | page     | int    | No       | 1       | Pagination     |
  | pageSize | int    | No       | 20      | Max 100        |
  | [param]  | [type] | Yes/No   | [val]   | [description]  |
- **Success (200):**
  ```json
  {
    "data": [{ "id": "uuid", "field": "value" }],
    "total": 42,
    "page": 1,
    "pageSize": 20
  }
  ```
- **Errors:**
  - 401 — Not authenticated
  - 403 — Caller does not have the required role
  - 400 — Invalid query parameters

### POST /[resource]

- **Who can call it:** [role names]
- **Request body:**
  | Field   | Type   | Required | Notes          |
  | ------- | ------ | -------- | -------------- |
  | [field] | [type] | Yes/No   | [description]  |
- **Business rule:** [what happens on success — reference C-[N]]
- **Success (201):**
  ```json
  { "id": "uuid", "field": "value", "created_at": "ISO-8601" }
  ```
- **Errors:**
  - 400 — Missing or invalid required fields
  - 401 — Not authenticated
  - 403 — Caller does not have the required role
  - 409 — Conflict (duplicate entry, invalid state transition)

### PUT /[resource]/:id

- **Who can call it:** [role names]
- **Request body:** [same structure as POST, with optional fields]
- **Business rule:** [reference C-[N]]
- **Success (200):** [updated resource]
- **Errors:** 400 · 401 · 403 · 404 · 409

### DELETE /[resource]/:id

- **Who can call it:** [role names]
- **Business rule:** [soft delete? cascade? reference C-[N]]
- **Success (204):** No content
- **Errors:** 401 · 403 · 404

---

## C — Constraints & Business Rules

Number every rule. Use "must" and "must not" — never "should" or "might".

- **C-1:** [Rule statement. E.g., "A profile change request must be approved by an Admin before the profile updates."]
- **C-2:** [Rule statement. E.g., "Only users with the Admin role can approve change requests."]
- **C-3:** [Rule statement. E.g., "The email field must not be changed after KYC verification."]
- **C-4:** [State transition rule. E.g., "An order transitions from DRAFT → SUBMITTED → APPROVED → COMPLETED. Backward transitions are not allowed."]

---

## E — Evidence (Acceptance Criteria)

Each item becomes a test case. Every criterion must be independently testable. Use Given/When/Then format.

- [ ] **E-1:** Given [context], when [action], then [expected result]
- [ ] **E-2:** Given a logged-in [role], when they view [resource], then their data is displayed with all fields from Section D
- [ ] **E-3:** Given an [approver role] approves a [request], then the [resource] updates and the user is notified
- [ ] **E-4:** Given a user without [required role] calls [endpoint], then the API returns 403
- [ ] **E-5:** Given a required field is missing from the request body, then the API returns 400 with a message identifying the missing field
- [ ] **E-6:** Given [boundary condition], when [action], then [expected behavior]

---

## UI States

For every data-driven screen, define what the user sees in each state.

### [Screen Name]

| State    | What the User Sees                                          |
| -------- | ----------------------------------------------------------- |
| Loading  | [e.g., Skeleton cards matching the success layout]          |
| Error    | [e.g., "Failed to load orders. Tap to retry." with button] |
| Empty    | [e.g., "No orders yet. Create your first order." with CTA] |
| Success  | [e.g., Paginated table with columns: ID, Date, Status]     |

---

<!--
  ═══════════════════════════════════════════════════════════
  WORKED EXAMPLES — Delete these after using the template
  ═══════════════════════════════════════════════════════════
-->

<!--
  EXAMPLE A — Java / Spring Boot (ASDP: User Profile with Approval)
  ─────────────────────────────────────────────────────────────────

  ## D — Data Model

  ### user_profile
  | Field             | Type     | Required | Notes                             |
  | ----------------- | -------- | -------- | --------------------------------- |
  | id                | UUID     | Yes      | Primary key                       |
  | user_id           | UUID     | Yes      | FK to auth_users, UNIQUE          |
  | company_name      | VARCHAR  | Yes      | Max 200 chars                     |
  | npwp              | VARCHAR  | Yes      | Tax ID, UNIQUE, max 20 chars      |
  | email             | VARCHAR  | Yes      | Business email, UNIQUE            |
  | phone             | VARCHAR  | No       | Format: +62xxx                    |
  | kyc_verified      | BOOLEAN  | Yes      | Default false                     |
  | created_at        | TIMESTAMP| Yes      | Auto-set                          |
  | updated_at        | TIMESTAMP| Yes      | Auto-set                          |
  | created_by        | UUID     | Yes      | FK to auth_users                  |

  ### profile_change_request
  | Field             | Type     | Required | Notes                             |
  | ----------------- | -------- | -------- | --------------------------------- |
  | id                | UUID     | Yes      | Primary key                       |
  | profile_id        | UUID     | Yes      | FK to user_profile                |
  | field_name        | VARCHAR  | Yes      | Which field is changing           |
  | old_value         | TEXT     | No       | Previous value                    |
  | new_value         | TEXT     | Yes      | Requested value                   |
  | status            | ENUM     | Yes      | PENDING, APPROVED, REJECTED       |
  | reviewed_by       | UUID     | No       | FK to auth_users (Admin)          |
  | reviewed_at       | TIMESTAMP| No       | When decision was made            |
  | created_at        | TIMESTAMP| Yes      | Auto-set                          |
  | updated_at        | TIMESTAMP| Yes      | Auto-set                          |
  | created_by        | UUID     | Yes      | FK to auth_users                  |

  ## I — Interface Contract

  ### GET /api/v1/profile
  - Who can call it: SHIP_OWNER
  - Returns: The caller's own profile
  - Success (200): { id, company_name, npwp, email, phone, kyc_verified }
  - Errors: 401 · 404

  ### POST /api/v1/profile/change-request
  - Who can call it: SHIP_OWNER
  - Required fields: field_name, new_value
  - Business rule: Creates a PENDING change request (C-1)
  - Success (201): { id, field_name, new_value, status: "PENDING" }
  - Errors: 400 · 401 · 409 (already has pending request for this field)

  ### PUT /api/v1/admin/change-request/:id/approve
  - Who can call it: ADMIN
  - Business rule: Approves the request, updates the profile (C-2)
  - Success (200): { id, status: "APPROVED", reviewed_by, reviewed_at }
  - Errors: 401 · 403 · 404

  ## C — Constraints
  - C-1: A profile change request must be approved before the profile updates.
  - C-2: Only Admin role can approve change requests.
  - C-3: The email field must not be changed after KYC verification.
  - C-4: A user must not have more than one pending request per field.

  ## E — Evidence
  - E-1: Given a logged-in Ship Owner, when they view their profile, then their data is displayed.
  - E-2: Given a Ship Owner submits a change request, then status is PENDING.
  - E-3: Given an Admin approves a change request, then the profile updates and status is APPROVED.
  - E-4: Given a user without Admin role calls the approve endpoint, then 403.
  - E-5: Given a Ship Owner with kyc_verified=true submits email change, then 409.
  - E-6: Given a required field is missing, then 400 with clear message.
-->

<!--
  EXAMPLE B — Next.js / Supabase (Generic CRUD: Project Management)
  ──────────────────────────────────────────────────────────────────

  ## D — Data Model

  ### projects
  | Field        | Type      | Required | Notes                              |
  | ------------ | --------- | -------- | ---------------------------------- |
  | id           | UUID      | Yes      | Primary key, gen_random_uuid()     |
  | org_id       | UUID      | Yes      | FK to organizations, tenant key    |
  | name         | TEXT      | Yes      | Max 100 chars                      |
  | description  | TEXT      | No       | Max 500 chars                      |
  | status       | TEXT      | Yes      | CHECK: draft, active, archived     |
  | owner_id     | UUID      | Yes      | FK to auth.users                   |
  | created_at   | TIMESTAMPTZ | Yes    | DEFAULT now()                      |
  | updated_at   | TIMESTAMPTZ | Yes    | DEFAULT now(), trigger on update   |
  | created_by   | UUID      | Yes      | FK to auth.users                   |

  RLS Policies:
  - SELECT: org_id = auth.jwt()->>'org_id'
  - INSERT: org_id = auth.jwt()->>'org_id' AND role IN ('EDITOR', 'MANAGER', 'ADMIN')
  - UPDATE: org_id = auth.jwt()->>'org_id' AND (owner_id = auth.uid() OR role IN ('MANAGER', 'ADMIN'))
  - DELETE: org_id = auth.jwt()->>'org_id' AND role IN ('ADMIN')

  ## I — Interface Contract

  ### GET /api/projects (Server Action: getProjects)
  - Who can call it: VIEWER, EDITOR, MANAGER, ADMIN
  - Query params: page (default 1), pageSize (default 20), status (optional filter)
  - Success (200): { data: Project[], total: number, page: number }
  - Errors: 401

  ### POST /api/projects (Server Action: createProject)
  - Who can call it: EDITOR, MANAGER, ADMIN
  - Required fields: name
  - Optional fields: description
  - Business rule: Status defaults to 'draft', owner_id set to caller (C-1)
  - Success (201): { id, name, status: 'draft', owner_id }
  - Errors: 400 · 401 · 403

  ## C — Constraints
  - C-1: New projects must have status 'draft'. Only the owner or a Manager can change status to 'active'.
  - C-2: Archived projects must not be editable. Unarchiving requires Admin role.
  - C-3: Project names must be unique within an organization.

  ## E — Evidence
  - E-1: Given a logged-in Viewer, when they view the projects list, then all projects in their org are displayed.
  - E-2: Given an Editor creates a project, then status is 'draft' and owner is the caller.
  - E-3: Given a Viewer tries to create a project, then the API returns 403.
  - E-4: Given a duplicate project name within the org, then the API returns 409.
  - E-5: Given an Editor tries to edit an archived project, then the API returns 400 with message "Archived projects cannot be edited".
  - E-6: Given a project name exceeds 100 chars, then the API returns 400.
-->
