# Findings and Verdict

The review should be high-signal. Findings need evidence, impact, and a clear relationship to the diff/spec.

## Finding levels

Use these labels inside the relevant section when needed:

### `[BLOCKER]`

Must be resolved before the changes are ready for PR. Typical reasons:

- contradicted acceptance criterion or mandatory project rule;
- demonstrable correctness/regression defect;
- high-impact security vulnerability;
- required project gate fails because of the change;
- incompatible API/schema/migration behavior;
- non-trivial spec-driven change whose mandatory acceptance criteria cannot be verified because required implementation/spec evidence is missing.

### `[WARNING]`

A grounded risk worth addressing or consciously accepting, but not enough by itself to stop the PR. Typical reasons:

- maintainability cost with credible future impact;
- performance risk whose impact is plausible but not proven to be merge-blocking;
- architectural drift not forbidden by project rules;
- missing optional test coverage around a meaningful edge case.

Pure polish, optional refactors, ownership/bus-factor notes, or alternative designs belong in `Suggestions`, not as findings.

## Finding format

Prefer one concise bullet:

`- [BLOCKER] path/to/file.ext:42 — <problem>. <impact / violated requirement>.`

Add a second sentence only when the fix or reasoning is non-obvious.

Do not report a finding without a concrete location when one exists. For commit-only findings, identify the commit hash/message. For spec-level blockers, cite the spec path/criterion and the affected code location.

## Verdict

### `REQUEST CHANGES`

Use when at least one unresolved `[BLOCKER]` exists.

### `APPROVE`

Use when no unresolved blocker exists, including when there are warnings or suggestions.

Do not invent `APPROVE WITH SUGGESTIONS`; suggestions remain under the existing `Suggestions` section while verdict stays `APPROVE`.

## Empty sections

Use:

`- Nenhuma issue encontrada.`

Do not fabricate praise to fill a section.
