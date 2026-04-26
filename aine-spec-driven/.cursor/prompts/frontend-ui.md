# Frontend UI — Generate Component from Spec

**Stage:** 5 of 10 — Frontend UI
**Who uses it:** Frontend Developer
**When:** After the API endpoints are available (or mockable), when building the UI.

---

Using the UI states defined in spec section I and acceptance criteria from section E of `specs/[module-name].md`, build the **[component name]** component.

The component must implement all 4 UI states:

1. **Loading state**: [Describe what the user sees while data loads — skeleton screen, spinner, placeholder content. Must match the layout of the success state.]

2. **Error state**: [Describe what the user sees when the fetch or action fails — error message, retry button, guidance text. Never show raw error objects.]

3. **Empty state**: [Describe what the user sees when there is no data — contextual message with a call to action. E.g., "No orders yet. Create your first order."]

4. **Success state**: [Describe what the user sees when data is present — the actual content, data tables, forms, etc.]

Requirements:

- Follow the project's component architecture (atomic design, container pattern)
- Extract stateful logic into custom hooks where it aids reuse
- Wire API calls to the endpoints defined in spec section I
- Implement all interaction behaviors described in the acceptance criteria (Section E)
- Handle form validation client-side before submission
- Show meaningful feedback for every user action (toast, inline message, state change)

<!--
  Example A (Java / Spring Boot + Google Stitch):
  - Generate the component spec for Google Stitch using the UI states above
  - Component names must match the spec entity names exactly
  - After generation: review state logic against acceptance criteria before committing

  Example B (Next.js / React + TailwindCSS):
  - Use Server Components by default, 'use client' only for interactivity
  - Style with TailwindCSS className (prefer over sx or inline styles)
  - Use the project's established form library (React Hook Form, etc.)
-->
