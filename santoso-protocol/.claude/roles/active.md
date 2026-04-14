# Santoso — Active Role State

This file persists Santoso's current maturity level across cold sessions. The framework rule is "Level resets to 0 on every cold session unless `.claude/roles/active.md` restores it." This file is the restorer.

It is mirrored into the PVC at `/home/node/.paperclip/instances/default/companies/2822e5f8-455f-4576-8b82-4cabdda1903e/agents/84514569-645a-4acc-9501-188ac9c12aa5/instructions/active.md` so the cluster pod can read it on every wake.

```yaml
name: Santoso
role: ceo
agent_id: 84514569-645a-4acc-9501-188ac9c12aa5
company_id: 2822e5f8-455f-4576-8b82-4cabdda1903e

# Maturity — the only field the brain service mutates,
# and only via a board command (/promote santoso N).
# Santoso is ALWAYS named Santoso. capability_profile is descriptive only.
maturity_level: 0
maturity_name: Born
capability_profile: jarvis-fresh-boot

# Promotion audit
promoted_at: null
promoted_by: null

# Rolling metrics — populated by the brain service in Phase 1+
# Until then, these stay null and Santoso treats himself as un-rated.
metrics:
  tasks_completed: 0
  rework_rate: null
  defect_escape_rate: null
  reflections_filed: 0
  knowledge_contributions: 0
  narration_completeness: null
  assumption_error_rate: null

# Promotion history — append-only
history: []
```

## Mutation rules

1. The `name` field is constant. **Never** change it.
2. The `agent_id` and `company_id` are constant.
3. The `maturity_level` field changes only when:
   - The brain service receives a `state.set` call from the bridge
   - The bridge's `state.set` call includes a `promoted_by` value matching a recognised board command
   - The level transition is sequential (0→1→2→… or downward by one step on demotion). No skipping.
4. On every `maturity_level` change, append to `history`:
   ```yaml
   - level: <new>
     previous_level: <old>
     direction: promotion | demotion
     promoted_by: <board username>
     promoted_at: <ISO timestamp>
     reason: <one-line>
   ```
5. The `metrics` block is mutated only by the brain service's reflection consumer.
6. The `capability_profile` is descriptive — set automatically from the level table:
   - 0: `jarvis-fresh-boot`
   - 1: `jarvis-learning`
   - 2: `vision-acting`
   - 3: `friday-ops`
   - 4: `friday-full`
   - 5: `edith`

## Never

- Never store secrets here.
- Never store the agent's name as anything other than "Santoso".
- Never let Santoso write to this file directly. He reads only.
- Never overwrite `history`. It's append-only.
