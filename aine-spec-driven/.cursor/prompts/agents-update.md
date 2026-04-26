# AGENTS.md Update — Improve from Observed Patterns

**Stage:** 10 of 10 — AGENTS.md Update
**Who uses it:** Solution Architect (SA), Backend Developer
**When:** After several features have been built, when patterns have stabilized.

---

Based on the patterns we have used so far in this project, suggest updates to the `AGENTS.md` file that would make future code generation more consistent and reduce the number of corrective iterations.

Review the codebase and identify:

1. **Repeated patterns** that should be documented as standards
   - Common file structures or naming conventions that emerged
   - Data fetching patterns used across multiple features
   - Error handling approaches that became standard
   - Component patterns (layout, form, table) that are reused

2. **Corrective iterations** that happened during development
   - Cases where the AI agent generated code that had to be manually corrected
   - Patterns the AI agent invented that diverged from the team's preferred approach
   - Missing context that caused the agent to make wrong assumptions

3. **New forbidden patterns** discovered during development
   - Anti-patterns that caused bugs or performance issues
   - Approaches that seemed right but created maintenance problems
   - Security issues that were caught during review

4. **Role or workflow updates**
   - New roles added to the system
   - Changes to the development workflow
   - New tools or libraries adopted

For each suggestion, provide:
- **Section**: Which AGENTS.md section to update (or "New Section" if adding one)
- **Current**: What AGENTS.md says now (or "Not covered")
- **Proposed**: The exact text to add or change
- **Reason**: Why this change will reduce corrective iterations

Output the suggestions as a diff-ready format that can be applied directly to `AGENTS.md`.
