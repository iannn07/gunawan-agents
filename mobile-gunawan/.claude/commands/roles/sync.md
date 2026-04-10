# /roles:sync — Force Save Active Role State

Manual override for auto-save. Use when Noah explicitly requests a full role state save,
or when ending a long session and wanting to ensure nothing is missed.

## What this does

1. Read the current active role from `.claude/roles/active.md`
2. Read the current state of `.claude/roles/[active-role].md`
3. Review this entire conversation for:
   - Decisions made
   - Tasks completed
   - Patterns learned
   - Assumptions proven wrong
   - Noah's corrections or redirections
4. Update the role state file with all accumulated context
5. Update "last-session" date to today
6. Report what was saved

## Output format

```
ROLES:SYNC — [role-name]
Last saved: [date]

Updated sections:
- [section name]: [what changed]
- [section name]: [what changed]

Role state file: .claude/roles/[role-name].md
```
