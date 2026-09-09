# Code Quality Baseline

Use these rules for every code diff.

## Simplicity

Prefer the minimum implementation that satisfies the requirement.

Flag complexity when the change introduces material cost without a requirement or demonstrated need, for example:

- abstraction used only once with no clear boundary benefit;
- configuration/flexibility not required by the spec;
- duplicated control paths that make behavior diverge;
- complex error handling for states the system cannot reach;
- a large implementation where a materially simpler local solution is evident.

Do not block merely because another design is shorter.

## Surgical scope

Changed lines should trace to the change intent.

Flag:

- unrelated refactors bundled into the feature when they increase review or regression risk;
- formatting churn that obscures functional changes when the repo does not require it;
- imports, variables, functions, assets, flags, or branches made unused by this diff;
- changes to neighboring behavior without spec justification.

Do not flag or remove unrelated pre-existing dead code as a PR defect.

## Match local style

The repository's established patterns beat personal preference. Use nearby code and project instructions as evidence for naming, structure, errors, tests, dependency injection, async style, API shape, and file layout.

## Correctness lens

Look for concrete failures such as:

- incorrect branch/condition behavior;
- missing error/failure propagation;
- invalid state transitions;
- off-by-one/boundary errors;
- incorrect null/optional handling;
- concurrency or lifecycle mistakes;
- migration/schema incompatibility;
- partial updates without rollback/idempotency where the project requires it;
- feature behavior not covered by the relevant acceptance criterion.

## Performance lens

Only report a performance issue when the diff creates a credible material regression, such as:

- new unbounded work on a hot/request path;
- N+1 or repeated remote/database operations visible from the flow;
- full collection/file loads where the changed path can receive large inputs;
- accidental repeated rendering/computation/network calls with meaningful cost;
- resource leaks or missing cleanup introduced by the change.

Do not request micro-optimizations without evidence.
