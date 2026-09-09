---
name: local-pr-review
description: Review local Git changes before they become a pull request. Validate the diff against project specs, repository instructions, tests, code conventions, security, correctness, maintainability, performance, architecture, UI rules, and commit policy. Write every review to .reviews/ without deciding whether that directory is versioned.
metadata:
  version: "1.0.0"
---

# Local PR Review

Review the changes that are about to become a PR. Be evidence-driven, spec-first, diff-scoped, and concise.

This is a review-only skill. Do not modify product code, rewrite commits, commit, push, or change branches unless the user explicitly asks for a separate action after the review.

## Non-negotiable contract

1. Project specs and repository instructions define intended behavior and local conventions.
2. Generic best practices are secondary. Never request a change merely because you would design it differently.
3. Review the change, not the whole repository. Existing unrelated debt may be mentioned only when the diff makes it relevant.
4. Every blocking finding must be attributable to changed code/config/docs or to a requirement the change fails to satisfy.
5. Do not invent behavior, requirements, test results, runtime availability, or architectural facts.
6. Use tests and deterministic project gates as evidence when available. A self-assessment is not a substitute for a gate.
7. Always write the final report under `.reviews/` in the repository root.
8. Never add or remove `.reviews/` from `.gitignore`, `.git/info/exclude`, or any VCS configuration. The developer/project decides whether reviews are versioned.
9. Always exclude `.reviews/**` from the review diff, even when the directory is versioned.

## Default review scope

From the repository root:

1. Resolve the target branch in this order:
   - target/base explicitly supplied by the user;
   - repository/PR metadata that clearly identifies the target;
   - `origin/HEAD` when available;
   - local `main`, then `master`, then `develop` when present.
2. Compute the merge base between target and `HEAD`.
3. Review all committed changes from merge base through `HEAD`.
4. Also inspect staged and unstaged changes by default because they may be intended for the upcoming PR.
5. If the working tree is dirty, never describe the reviewed state as a commit alone. Record `HEAD <sha> + working tree`.
6. Exclude `.reviews/**` from every diff/list used for findings.

If a reliable target cannot be established, state the limitation. Do not silently compare against an arbitrary branch.

## Core workflow

### 1. Establish evidence

Collect only what is needed:

- repository root and repository name;
- remote URL when configured;
- current branch;
- target branch and merge base;
- `HEAD` full SHA;
- working-tree state;
- changed files and diff;
- commits in the review range;
- languages/frameworks affected by the diff;
- project-declared tests, linters, analyzers, build checks, and commit rules.

### 2. Resolve project intent first

Read `references/spec-alignment.md`.

Determine the applicable specs/instructions before judging implementation. Prefer the most specific instruction that applies to each changed path.

### 3. Perform the baseline review

Always review for:

- **Security:** high-impact vulnerabilities and insecure defaults visible in the change.
- **Performance:** material regressions supported by evidence, not speculative micro-optimizations.
- **Maintainability:** unnecessary complexity, diff-created dead code, unclear ownership/boundaries, harmful duplication, and violations of project structure.
- **Correctness:** acceptance criteria, edge cases implied by the spec, data/control flow, failure behavior, regressions, tests, and declared gates.
- **Conventions:** repository-local naming, structure, style, generated-file policy, documentation rules, and other instructions.
- **Commits:** project commit policy across every commit in the reviewed range.

Apply the caution rules in `references/code-quality.md`.

### 4. Progressive disclosure: load only what the diff needs

Do not load every reference by default.

| Trigger in the diff | Load |
|---|---|
| module/package/service boundaries, cross-domain calls, new shared code, duplicated business logic | `references/architecture.md` |
| React component API, providers/context, reusable component composition | `references/react.md` |
| HTML/CSS/UI, forms, navigation, interaction, accessibility, responsive behavior | `references/frontend.md` |
| auth/authz, credentials, user-controlled input, uploads, parsers, network calls, sensitive data, new entry points/trust boundaries, CI secrets/dependencies | `references/security.md` |
| project tests/build/lint/security gates or commit conventions need validation | `references/commits-and-gates.md` |
| final verdict/report | `references/findings-and-verdict.md` and `references/report-template.md` |

A trigger may load more than one reference. Read a selected reference completely before using it.

### 5. Validate with project gates

Run only gates that are declared by the project or are already available without installing new dependencies. Do not weaken, delete, or bypass tests to obtain a passing result.

If a declared gate cannot run because the runtime/toolchain is unavailable, record that fact accurately. Do not claim it passed. Use `references/commits-and-gates.md` for blocking rules.

### 6. Classify findings and decide verdict

Read `references/findings-and-verdict.md`.

Use only two verdicts:

- `APPROVE`
- `REQUEST CHANGES`

Suggestions are non-blocking and do not change an otherwise valid `APPROVE`.

### 7. Write the review artifact

Read `references/report-template.md`.

Create `.reviews/` if it does not exist. Do not create `.gitkeep` and do not touch ignore rules.

Default filename:

`review-YYYYMMDD-HHmm-<branch-slug>-<short-head-sha>[-dirty].md`

Use a filesystem-safe branch slug. Add `-dirty` when staged or unstaged product changes were included.

The report must use the established Code Review format and include enough SHA/base information to reproduce the reviewed scope.

### 8. Return a terse completion message

After writing the file, report:

- verdict;
- review file path;
- target and source state;
- any gate that could not be executed.

Do not duplicate the full report in chat unless requested.
