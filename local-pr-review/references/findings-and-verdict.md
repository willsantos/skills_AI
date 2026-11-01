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

The verdict is derived from the findings and the completeness of the evidence — never asserted independently of them.

### `REQUEST CHANGES`

Use when at least one unresolved `[BLOCKER]` exists, or when mandatory evidence is missing (see Completeness below). A degraded review is never published as `APPROVE`.

### `APPROVE`

Use when no unresolved blocker exists and the reviewed evidence is complete, including when there are warnings or suggestions.

Do not invent `APPROVE WITH SUGGESTIONS`; suggestions remain under the existing `Suggestions` section while verdict stays `APPROVE`.

## Shared contract mapping

`oroborus-engineering-standards` defines the shared findings contract (`schemas/review/finding-contract.schema.json`, `1.0.0-proposta`). This skill's vocabulary maps onto it as follows:

| Contract field | This skill |
|---|---|
| `finding.category` | the six section names exactly (`Security`, `Performance`, `Maintainability`, `Correctness`, `Conventions`, `Commits`); no other category exists |
| `finding.isBlocking` | `[BLOCKER]` ↔ `true`; `[WARNING]` and suggestions are never blocking |
| `finding.path` / `finding.line` | `path/to/file.ext:42` format; a global finding (no `path`, no `line`) is valid for PR-level issues such as category `Commits` |
| invalid location | a `line` without a `path` is not a valid location; when a concrete location exists it is mandatory — otherwise the finding is downgraded, never silently dropped |
| `verdict` | wire values `APPROVE`/`REQUEST_CHANGES`, derived; the report prose uses the established `APPROVE`/`REQUEST CHANGES` headings and must agree with the JSON block |

## Completeness (missing evidence is not compliance)

Missing mandatory evidence degrades the review and forbids `APPROVE`:

- diff scope truncated → the covered scope is declared, review stays degraded;
- a required gate is `not_run` → record it; `not executed` never converts to `passed`;
- working tree dirty over the reviewed `HEAD` → record `dirty`; the evidence does not represent a clean commit state.

State the degradation explicitly in the report and in the optional machine-readable block (`completeness.state = incomplete_degraded` with the closed `missing` taxonomy), together with verdict `REQUEST CHANGES`.

## Empty sections

Use:

`- Nenhuma issue encontrada.`

Do not fabricate praise to fill a section.
