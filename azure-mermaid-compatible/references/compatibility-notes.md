# azure-mermaid-compatible

Reusable Agent Skill for creating Mermaid documentation that treats Azure DevOps as the compatibility baseline while preserving standard Markdown rendering in VS Code.

## Files

- `SKILL.md`: skill definition and workflow.
- `references/azure-devops-compatibility.md`: compatibility notes and authoritative references.

## Typical triggers

Use automatically for requests involving:

- architecture diagrams;
- application or infrastructure flows;
- sequence diagrams;
- CI/CD and deployment flows;
- state transitions;
- database/entity relationships;
- service integrations;
- request/data/event flows;
- Mermaid review and repair.

## Key rule

Use standard fenced `mermaid` blocks and a conservative Mermaid subset. For flowcharts, use `graph`, never `flowchart`, when Azure DevOps compatibility is required.
