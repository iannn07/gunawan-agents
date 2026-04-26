# Task Planning — Break Feature into Ordered Tasks

**Stage:** 2 of 10 — Task Planning
**Who uses it:** Solution Architect (SA)
**When:** After the DICE spec is written, before any implementation begins.

---

Break the **[module name]** feature into individual tasks ordered by dependency.

Use the DICE spec at `specs/[module-name].md` as the source of truth.

For each task, provide:

1. **Task number** and short title
2. **Responsible role**: SA, Backend Dev, Frontend Dev, or QC
3. **Spec section it covers**: which part of D, I, C, or E this task implements
4. **Dependencies**: which tasks must complete before this one can start
5. **Expected output**: the concrete deliverable (file, endpoint, migration, test suite)
6. **Estimated complexity**: Low / Medium / High

Order the tasks so that:
- Database schema (Section D) comes before API endpoints (Section I)
- API endpoints come before frontend components
- Test cases (Section E) can be written in parallel with implementation
- Tasks that can run in parallel are clearly marked

Output format:

```
Task 1: [title]
  Role: [role]
  Spec: Section [X], items [Y]
  Depends on: none
  Output: [deliverable]
  Complexity: [Low/Medium/High]

Task 2: [title]
  Role: [role]
  Spec: Section [X], items [Y]
  Depends on: Task 1
  Output: [deliverable]
  Complexity: [Low/Medium/High]
```
