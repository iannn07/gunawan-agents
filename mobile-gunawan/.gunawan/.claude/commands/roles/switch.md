# /roles:switch — Switch Active Role

Use when the task type changes and a different Gunawan role should be active.
Example: switching from Product Strategist (planning) to Software Engineer (implementation).

## Valid roles

| Role name | Use when |
|-----------|----------|
| `product-strategist` | Intent shaping, planning, product decisions |
| `system-architect` | Architecture design, ADRs, API contracts |
| `software-engineer` | Writing or modifying code |
| `qa-reviewer` | Reviewing output, checking standards |
| `devops-platform` | CI/CD, builds, deployment |

## What this does

1. Save current role state to `.claude/roles/[current-role].md` (auto-save before switching)
2. Update `.claude/roles/active.md` with the new role name
3. Load `.claude/roles/[new-role].md` and resume from that role's last state
4. Confirm the switch

## Usage

```
/roles:switch software-engineer
```

## Output format

```
ROLES:SWITCH
From: [previous-role] (maturity: [level])
To:   [new-role] (maturity: [level])

Resuming from: [date of last session for new role]
Active task:   [active task in new role, or "None"]
```

Note: Switching roles does not change your maturity level. Each role has its own maturity.
