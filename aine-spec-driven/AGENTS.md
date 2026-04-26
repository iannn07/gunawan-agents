# [Project Name] — Engineering Standards

<!--
  HOW TO USE THIS FILE
  ────────────────────
  1. Copy this file into the ROOT of your project repository.
  2. Replace every [bracketed placeholder] with your project's actual values.
  3. Delete the example blocks you don't need (Example A or Example B).
  4. Commit this file — Cursor and Claude Code read it before every AI task.

  This template is project-agnostic. Two example fills are provided:
    Example A — Java 21 / Spring Boot 3 / PostgreSQL / Flyway
    Example B — Next.js / TypeScript / Supabase / TailwindCSS
  Keep whichever matches your stack, or write your own.
-->

## Project Overview

[Project name] — [one-sentence description of what the platform does and who uses it].

<!--
  Example A:
  APS (ASDP Port Services) platform — web app for managing vessel schedules,
  port orders, billing, and payment for ship owners and port operators.

  Example B:
  Gunawan Dashboard — internal operations dashboard for managing client
  projects, billing, and team assignments.
-->

## Technology Stack

<!--
  List every major technology. Be specific about versions so the AI agent
  generates compatible code. Delete the example you don't use.
-->

| Layer      | Technology                          |
| ---------- | ----------------------------------- |
| Backend    | [framework + language + version]    |
| Frontend   | [framework + language]              |
| Database   | [engine + migration tool]           |
| Auth       | [auth strategy]                     |
| CI/CD      | [pipeline tool]                     |

<!--
  Example A (Java / Spring Boot):
  | Layer      | Technology                                        |
  | ---------- | ------------------------------------------------- |
  | Backend    | Java 21, Spring Boot 3, Spring Security (JWT)     |
  | Frontend   | Google Stitch for UI generation + TypeScript       |
  | Database   | PostgreSQL — migrations via Flyway                 |
  | Auth       | JWT tokens, role-based access control              |
  | CI/CD      | GitLab Actions                                     |

  Example B (Next.js / Supabase):
  | Layer      | Technology                                         |
  | ---------- | -------------------------------------------------- |
  | Backend    | Next.js 15 App Router, TypeScript strict           |
  | Frontend   | React 19, TailwindCSS, Material-UI                 |
  | Database   | Supabase (PostgreSQL) with RPC functions            |
  | Auth       | Keycloak with Azure AD integration                  |
  | CI/CD      | GitHub Actions                                      |
-->

## Specification Standard

Every feature must have a written specification in **DICE format** before any code is written:

- **D — Data Model**: Every entity (table) the feature touches, with field types and constraints
- **I — Interface Contract**: Every API endpoint with auth, request/response shapes, and error codes
- **C — Constraints & Business Rules**: Numbered rules that govern behavior
- **E — Evidence (Acceptance Criteria)**: Testable Given/When/Then statements

Spec files live in `specs/[module-name].md`. Use the DICE template in `templates/DICE-spec-template.md`.

The spec is the source of truth — not the code. When code and spec disagree, the spec wins and the code must be updated.

## Coding Standards

- Write data type definitions BEFORE writing any logic
- All API endpoints MUST validate input before processing
- All API endpoints MUST check authentication and role before processing
- Use safe validation (`safeParse()`) — never throwing validation (`parse()`) for external data
- Error responses follow a consistent format: `{ error: string, code: string }`
- All database tables MUST have: `created_at`, `updated_at`, `created_by`
- No direct database queries from the controller / route-handler layer
- Every UI component MUST handle 4 states: loading, error, empty, success
- Every code file should be traceable to a spec section

<!--
  Add project-specific standards below. Examples:

  Java / Spring Boot:
  - All services must be annotated with @Transactional where appropriate
  - Use record types for DTOs
  - Controller layer handles only HTTP concerns — business logic in services

  Next.js / TypeScript:
  - Server Components by default; 'use client' only when state or interactivity is needed
  - Use TailwindCSS className instead of sx or inline style for MUI components
  - URL is the single source of truth for public parameters (page, pageSize, filters)
-->

## Roles

<!--
  Define every role in your system. The AI agent uses this to generate
  correct auth checks and permission logic.
-->

| Role          | Permissions                                                |
| ------------- | ---------------------------------------------------------- |
| [ROLE_NAME]   | [what this role can view, create, edit, approve, delete]   |

<!--
  Example A (ASDP APS):
  | Role          | Permissions                                              |
  | ------------- | -------------------------------------------------------- |
  | SHIP_OWNER    | View/edit own profile, submit orders                     |
  | PETUGAS       | View schedules, manage orders for the port               |
  | ADMIN         | Approve profile changes, manage configuration            |
  | SUPERVISOR    | Approve schedules, view all reports                      |

  Example B (Generic SaaS):
  | Role          | Permissions                                              |
  | ------------- | -------------------------------------------------------- |
  | VIEWER        | Read-only access to dashboards and reports               |
  | EDITOR        | Create and edit records within assigned modules          |
  | MANAGER       | Approve submissions, manage team members                 |
  | ADMIN         | Full system configuration, user management, audit logs   |
-->

## Forbidden

These are hard bans — the AI agent must never do any of these:

- No raw SQL in business logic / service classes — use the project's ORM, query builder, or RPC layer
- No skipping input validation on any endpoint
- No internal error details (stack traces, DB errors) returned to the client
- No secrets, API keys, or credentials committed to the repository
- No direct database access from the controller / route-handler layer
- No deploying without passing all acceptance criteria from the spec

## Module Overview

<!--
  List every module in the project. This gives the AI agent a map of
  the full system so it understands cross-module dependencies.
-->

| Module          | What It Covers                            | Spec Reference  |
| --------------- | ----------------------------------------- | --------------- |
| [Module Name]   | [brief description of scope]              | [spec section]  |

<!--
  Example A (ASDP APS):
  | Module                  | What It Covers                                              | BRS Reference      |
  | ----------------------- | ----------------------------------------------------------- | ------------------ |
  | User Access & Roles     | Login, registration, role management, profile approval      | BR-001–004, BR-023 |
  | Schedule Management     | Vessel schedule upload, validation, approval, adjustment    | BR-005–006         |
  | Order Management        | Order submission, auto-approval logic, queue management     | BR-007–010         |
  | Billing & Invoicing     | Tariff calculation, invoice generation, checkout flow       | BR-013–015         |

  Example B (Generic SaaS):
  | Module             | What It Covers                                   | Spec Reference |
  | ------------------ | ------------------------------------------------ | -------------- |
  | Authentication     | Login, SSO, session management, password reset   | SPEC-AUTH      |
  | User Management    | CRUD users, role assignment, team membership     | SPEC-USERS     |
  | Dashboard          | Aggregated metrics, charts, export               | SPEC-DASH      |
  | Notifications      | Email, in-app, webhook triggers                  | SPEC-NOTIF     |
-->

## Development Workflow

All features follow this stage pipeline. Each stage has a corresponding prompt in `.cursor/prompts/`:

| #  | Stage           | Input                       | Output                           | Owner         |
| -- | --------------- | --------------------------- | -------------------------------- | ------------- |
| 1  | Requirements    | Business requirement (BRS)  | Full DICE specification          | SA            |
| 2  | Task Planning   | DICE spec                   | Ordered task list with roles     | SA            |
| 3  | Database        | Spec Section D              | Migration script                 | Backend Dev   |
| 4  | API Endpoint    | Spec Section I              | Endpoint implementation          | Backend Dev   |
| 5  | Frontend UI     | Spec Section I + E          | Component code with all states   | Frontend Dev  |
| 6  | Test Cases      | Spec Section E              | Test suite / collection          | QC            |
| 7  | Fix Error       | Error + spec context        | Corrected code                   | Anyone        |
| 8  | Spec Review     | Complete spec               | Gap analysis report              | QC / SA       |
| 9  | Impact Check    | File or entity name         | Dependency report                | Anyone        |
| 10 | AGENTS.md Update| Observed patterns           | Updated AGENTS.md                | SA / Dev      |

---

Last Updated: [Date]
Version: 1.0
Maintained By: [Team / Person Name]
