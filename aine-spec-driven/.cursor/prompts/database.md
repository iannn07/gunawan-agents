# Database — Generate Migration from Spec

**Stage:** 3 of 10 — Database
**Who uses it:** Backend Developer
**When:** After task planning, when implementing the data layer for a feature.

---

Generate a database migration script for the **[entity name]** table based on spec section D of `specs/[module-name].md`.

Requirements:

1. **Table structure**: Create the table exactly as defined in Section D
2. **Primary key**: UUID primary key (or match the project's convention)
3. **Audit columns**: Include `created_at`, `updated_at`, `created_by` with appropriate defaults
4. **Foreign keys**: Define all relationships listed in the spec with proper ON DELETE behavior
5. **Indexes**: Add indexes for columns that appear in WHERE clauses or JOIN conditions as identified in the spec
6. **Constraints**: NOT NULL, UNIQUE, CHECK constraints as specified
7. **Access control**: Include row-level security policies or equivalent access control in the same migration

<!--
  Example A (Java / Spring Boot / Flyway):
  Output a Flyway migration file: V[number]__create_[entity]_table.sql
  Use PostgreSQL syntax.

  Example B (Next.js / Supabase):
  Output a Supabase migration file: [timestamp]_create_[entity]_table.sql
  Include RLS policies. Use supabase CLI conventions.
-->

The migration must be **additive only** — no DROP or ALTER on existing objects. If modifying an existing table, create a new migration file.
