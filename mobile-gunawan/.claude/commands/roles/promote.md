# /roles:promote — Promote Active Role Maturity Level

Only Noah may promote a role. Never self-promote.
This command formalizes Noah's promotion decision into the role state file.

## Maturity levels

| Level | Name | What the agent may do |
|-------|------|-----------------------|
| 0 | Born | Read files, ask questions. No output without human review. |
| 1 | Infant | Propose intent. No file changes. |
| 2 | Child | Small approved changes with full explanation. |
| 3 | Adolescent | Scoped feature work. Review gates apply. |
| 4 | Teen/Junior | Full role workflow in bounded scope. Human reviews at gates. |
| 5 | Adult | Autonomous within role. Self-specialises. |

## Promotion criteria (minimum before Noah promotes)

| To level | Minimum criteria |
|----------|-----------------|
| 1 | First real task completed with passing Reviewer + reflection written |
| 2 | 5+ tasks completed, at least 1 pattern logged, no critical violations |
| 3 | Scoped feature delivered end-to-end without architecture correction |
| 4 | Full OS workflow executed autonomously (Explore → Architect → Builder → Reviewer) |
| 5 | Consistent autonomous delivery across 3+ features, zero gate violations |

## What this does

1. Read the current active role from `.claude/roles/active.md`
2. Verify current maturity level
3. Update the maturity level in `.claude/roles/[active-role].md`
4. Add a promotion entry to the Maturity History table
5. Confirm the promotion

## Usage

```
/roles:promote
```

(No argument needed — always promotes the active role by 1 level)

## Output format

```
ROLES:PROMOTE
Role:     [role-name]
Previous: [level] ([name])
New:      [level] ([name])
Date:     [today]
Approved: Noah

New capabilities unlocked:
- [what this level allows that the previous did not]
```
