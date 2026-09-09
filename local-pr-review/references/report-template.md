# Review Report Template

Default language for prose: pt-BR, matching the existing service. Keep the established English section headings.

If reliable PR metadata already exists locally, the heading may use `PR[#<id>](<url>)`. Otherwise use `Local PR Candidate` and never invent an ID/URL.

```markdown
## Code Review — Local PR Candidate

**Repo:** <repo>
**Repo URL:** <remote-url-or-"não configurada">
**Branch:** <branch>
**Target:** <target>
**Reviewer:** <reviewer-name-or-"Local AI Reviewer">
**Date:** <YYYY-MM-DD>

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
```

## Report rules

- Keep the report concise. Do not dump an internal checklist.
- Mention the exact spec path(s) used when material to correctness.
- If the working tree was included, use wording such as `HEAD <sha> + working tree`; do not imply the dirty changes are in the commit.
- If no commits exist between merge base and `HEAD`, say so rather than claiming commit compliance.
- If commit policy was not defined, state that no repository-specific commit rule was found; do not invent one.
- If a gate was not executable, put it in `Suggestions` unless its absence itself is a blocker under the project/spec.
- The summary's final line must match the verdict exactly.
