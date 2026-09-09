# Commits and Project Gates

Load when validating commits, tests, lint, build, analyzers, or other repository-declared gates.

## Commit review

Determine the commit convention from project instructions first.

Validate every commit in the branch review range, not only `HEAD`.

Check, when required by the project:

- allowed Conventional Commit types/scopes;
- scope rules for code vs docs/config/removal;
- subject/message format;
- atomicity expectations;
- forbidden merge/fixup/WIP commits;
- issue/work-item references.

If the repository has no commit convention, Conventional Commits may be suggested but must not become a blocker merely because this skill prefers them.

Never rewrite/rebase commits as part of the review.

## Gates

Discover gates from the repository, for example agent instructions, contributing docs, package scripts, Makefiles/task runners, CI definitions, language config, or the spec itself.

Run the relevant declared gates when their runtime/tools are already available.

Examples include tests, type checking, lint, formatting checks, compilation/build, migration validation, static security analyzers, dependency audits, or spec validators.

### Evidence rules

- A successful command can be reported as passed.
- A failed required gate is a blocker when the failure is attributable to the reviewed change or the project explicitly requires a clean gate before PR.
- If a required gate cannot execute because a runtime/tool is unavailable, report `not executed` and why.
- Do not convert `not executed` into `passed`.
- Do not install dependencies, change toolchains, modify lockfiles, or use network access merely to make a review gate runnable unless explicitly authorized.
- Never weaken/skip/delete tests or checks to get green.

## Spec-driven projects

When the project declares spec-driven acceptance criteria, use the criteria as the source for test expectations. Tests should verify required outcomes rather than mirror implementation structure.
