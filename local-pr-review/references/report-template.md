# Review Report Template

Default language for prose: pt-BR, matching the existing service. Keep the established English section headings.

If reliable PR metadata already exists locally, the heading may include its verified PR ID and URL. Otherwise use `Local PR Candidate` and never invent an ID or URL.

(The template below uses a four-backtick fence on purpose: the optional JSON block inside it is itself a fenced `json` block.)

````markdown
## Code Review — Local PR Candidate

**Repo:** <repo>
**Repo URL:** <remote-url-or-"não configurada">
**Branch:** <branch>
**Base:** <merge-base-sha-ou-target>
**Target:** <target>
**Reviewer:** <reviewer-name-or-"Local AI Reviewer">
**Date:** <YYYY-MM-DD>
**Dirty state:** <clean|dirty (HEAD <sha> + working tree)>

### Verdict: <APPROVE|REQUEST CHANGES>

---

### Security

- <finding or "Nenhuma issue encontrada.">

### Performance

- <finding or "Nenhuma issue encontrada.">

### Maintainability

- <finding or grounded positive/neutral evidence when useful>

### Correctness

- <spec/acceptance evidence and findings>
- A revisão cobre `<review-source>` comparado ao target `<target>` a partir do merge-base `<merge-base-sha>`.

### Conventions

- <project conventions checked and findings>

### Commits

- <result across every reviewed branch commit>

---

### Summary

<Concise paragraph stating scope, relevant spec(s), blockers resolved/outstanding, target/base/source state, and overall conclusion.>

<APPROVE.|REQUEST CHANGES.>

### Suggestions

- <non-blocking suggestion, ownership note, or gate that could not execute>

### Machine-readable contract (optional)

```json
{
  "contractVersion": "1.0.0-proposta",
  "review": {
    "provider": "GitHub",
    "repositoryId": "oroborus-auto/orotools",
    "repositoryName": "orotools",
    "pullRequestNumber": 512,
    "sourceBranch": "fix/limits",
    "headSha": "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6a7b8c9d0",
    "baseSha": "0f9e8d7c6b5a493e2d1c0b9a8f7e6d5c4b3a291e",
    "dirtyState": "dirty",
    "scope": {
      "filesIncluded": 14,
      "filesExcluded": [".reviews/review-20261101-0912-fix-limits.md"],
      "truncated": false,
      "diffOnly": true
    }
  },
  "completeness": {
    "state": "incomplete_degraded",
    "missing": ["gate_not_run", "local_dirty_state"],
    "notes": [
      "pytest not_run: toolchain unavailable in this environment.",
      "Review includes uncommitted working-tree changes over HEAD."
    ]
  },
  "gates": [
    { "name": "pytest", "status": "not_run" },
    { "name": "ruff check", "status": "passed", "source": ".reviews/ruff-20261101.txt" }
  ],
  "assessment": {
    "summary": "Local review of merge-base..HEAD plus working tree; one blocking finding.",
    "findings": [
      {
        "category": "Correctness",
        "isBlocking": true,
        "message": "Retry loop swallows cancellation and can spin forever.",
        "path": "src/oro/worker.py",
        "line": 58,
        "evidence": "except BaseException: continue"
      }
    ],
    "requiredChanges": ["Propagate cancellation out of the retry loop."],
    "suggestions": ["Add a regression test for cancelled retries."]
  },
  "verdict": "REQUEST_CHANGES"
}
```

The block is a projection of the report above it: same findings, same verdict, same degradation. Omit the whole block when it cannot be produced faithfully; never emit a block that disagrees with the prose. A review whose evidence is degraded publishes `completeness.state = incomplete_degraded` with the closed `missing` taxonomy and verdict `REQUEST_CHANGES` — never `APPROVE`.
````

## Report rules

- Keep the report concise. Do not dump an internal checklist.
- Mention the exact spec path(s) used when material to correctness.
- If the working tree was included, use wording such as `HEAD <sha> + working tree`; do not imply the dirty changes are in the commit.
- If no commits exist between merge base and `HEAD`, say so rather than claiming commit compliance.
- If commit policy was not defined, state that no repository-specific commit rule was found; do not invent one.
- If a gate was not executable, put it in `Suggestions` unless its absence itself is a blocker under the project/spec. Record it as `not_run`; `not executed` never becomes `passed`.
- If the evidence is degraded (truncated scope, required gate `not_run`, dirty working tree over the reviewed `HEAD`), the verdict is `REQUEST CHANGES`; a degraded review is never published as `APPROVE`.
- The summary's final line must match the verdict exactly, and the optional JSON block must agree with it.
