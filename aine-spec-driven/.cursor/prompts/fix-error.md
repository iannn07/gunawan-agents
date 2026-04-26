# Fix Error — Diagnose and Fix Using the Spec

**Stage:** 7 of 10 — Fix Error
**Who uses it:** Anyone
**When:** Any time an error occurs during or after implementation.

---

I got this error:

```
[Paste the full error message, stack trace, or unexpected behavior here]
```

The spec says:

```
[Paste the relevant spec section — the endpoint contract from Section I,
the business rule from Section C, or the acceptance criterion from Section E
that describes what SHOULD happen]
```

Based on this:

1. **Explain** what is wrong — why does the actual behavior differ from the spec?
2. **Identify the root cause** — which file, function, or line is responsible?
3. **Provide a fix** that makes the code match the spec exactly
4. **Verify** the fix does not break any other acceptance criteria in Section E
5. **List** any other files or tests that may need updating as a result of this fix

Rules:
- The spec is the source of truth — the fix must match the spec, not the other way around
- If the spec itself appears wrong, flag it to the SA instead of silently changing behavior
- Never fix an error by weakening validation or removing error handling
- If the fix touches multiple files, list all affected files before making changes
