# Spec Alignment

Project intent outranks generic preferences. The review must establish what the change is supposed to do before deciding whether it is correct.

## Instruction precedence

Use this order, with the most path-specific instruction winning when scopes overlap:

1. explicit review requirements supplied by the user for this run;
2. repository agent/instruction files applicable to the changed path, including root and nested `AGENTS.md`-style files;
3. feature/product specs and acceptance criteria;
4. architecture decisions, contracts, schemas, API docs, design-system rules, and project documentation;
5. tests that encode intended behavior;
6. established local code conventions visible in nearby code;
7. generic best practices from this skill.

A generic practice must not override an intentional, documented project decision. A documented exception can still be called out as risk when it materially affects security or correctness, but do not pretend it violates a requirement that explicitly allows it.

## Discovering the relevant spec

Search narrowly before broadly. Useful evidence may include:

- `.specs/`, `specs/`, `docs/`, `architecture/`, ADR/RFC directories;
- `README*`, `CONTRIBUTING*`, `ARCHITECTURE*`;
- package/app-specific docs near changed files;
- branch or commit identifiers that map to a feature/work item/spec;
- acceptance criteria and task files referenced by commits or documentation;
- API schemas, migrations, generated clients, design tokens, and contracts when they define expected behavior.

Do not assume `.specs/` exists. Do not assume a README is a feature spec merely because it is present.

## Traceability during review

Internally map each material requirement to evidence:

- requirement / expected outcome;
- changed implementation location;
- test or deterministic validation when available;
- status: satisfied, contradicted, or not verifiable.

The final report does not need a full matrix unless it helps explain a blocker.

## Missing or ambiguous specs

Do not fabricate acceptance criteria.

For a non-trivial behavior change, `APPROVE` requires enough evidence to determine intended behavior. If the repository declares a spec-driven workflow and the required spec/acceptance criteria are missing or the change cannot be reconciled with them, treat that as a blocker.

For mechanical refactors, dependency-only changes, docs, formatting, or other changes whose intended outcome can be established without a feature spec, use the relevant repository rules, tests, and invariants instead.

## Tests are spec evidence, not the spec itself

Tests should assert expected outcomes. Do not approve an implementation only because tests mirror its internal structure. Prefer tests that demonstrate acceptance criteria or externally observable behavior.
