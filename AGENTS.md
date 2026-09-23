# Agent Instructions for Skills Repository

Directives for AI agents working in this repository.

## Mandatory Skill Standard

When creating, editing, or standardizing any skill in this repository:
1. Always load and apply the guidelines from `skill-architect` (located in `.opencode/skills/skill-architect/` or `.claude/skills/skill-architect/`).
2. Always validate modified or newly created skills using the validation script:
   ```bash
   python3 .claude/skills/skill-architect/scripts/validate_skill.py <path-to-skill-folder>
   ```
   A skill must PASS all structural checks without errors before completion.

---

## Skill Architecture Principles

### 1. Progressive Disclosure (Token Economy)

Organize skill content into three strict layers:
- **Level 1 (L1) — Frontmatter (`SKILL.md` header):**
  - High-signal routing metadata (`name`, `description`, `metadata`).
  - Budget: ~100 words max. Loaded in every agent session catalog.
- **Level 2 (L2) — Body (`SKILL.md` content):**
  - Core workflow, procedural instructions, essential decision trees.
  - Budget: Under 500 lines. Loaded only when the skill is invoked.
- **Level 3 (L3) — Linked Files (`references/`, `scripts/`, `assets/`):**
  - Detailed specs, deep domain knowledge, code templates, scripts.
  - Loaded selectively and on-demand only when a specific trigger condition is met in the workflow.

### 2. Frontmatter & Metadata Requirements

Every `SKILL.md` must start with valid YAML frontmatter:
```yaml
---
name: skill-name-in-kebab-case
description: Clear summary of what it does. Use when [trigger phrases user would say]. Do NOT use for [negative scope / boundaries].
metadata:
  author: "willsantos"
  github: "https://github.com/willsantos"
  version: "1.0.0"
---
```

Rules:
- `name`: Must be lowercase kebab-case matching folder name.
- `description`:
  - Must include explicit trigger guidance: `Use when...` or `Usar quando...`
  - Must include explicit negative scope: `Do NOT use for...` or `Não usar para...`
  - Must be under 1024 characters.
  - Never contain XML/HTML angle brackets (`<` or `>`).
- `metadata`: Must include `author`, `github`, and `version` (semver string).

### 3. Folder Layout

```text
skill-name/
├── SKILL.md                 # Core instructions (L2)
├── agents/
│   └── openai.yaml          # Agent platform integration config
├── assets/
│   └── icon.svg             # 24x24 SVG icon
├── references/              # (Optional L3) Deep reference documents
└── scripts/                 # (Optional) Deterministic automation / validation scripts
```

Constraints:
- **NO `README.md` inside skill folders:** Skills are instructions for agents, not documentation sites. Keep explanations inside `SKILL.md` or `references/`. (The repository root `README.md` is the only human-facing documentation).
- **Assets:** Include SVG icon and openai agent configuration.

---

## Workflow for Standardizing a Skill

1. Check folder name: must be kebab-case.
2. Inspect `SKILL.md`:
   - Validate YAML frontmatter (ensure delimiters `---`, `name`, `description`, `metadata`).
   - Confirm description has both positive triggers and negative boundaries.
   - Refactor bodies longer than 500 lines by moving reference material into `references/<topic>.md`.
   - Ensure progressive disclosure links specify *when* to read the reference file.
3. Verify or scaffold `agents/openai.yaml` and `assets/icon.svg`.
4. Run validation:
   ```bash
   python3 .claude/skills/skill-architect/scripts/validate_skill.py <skill-folder>
   ```
5. Resolve any reported errors.
