# Source Notes

This skill is a condensed, review-oriented synthesis. It intentionally does not reproduce the referenced skills wholesale.

Concepts were adapted from these public Agent Skills references:

- https://agent-skills.techleads.club/skills/component-common-domain-detection/
- https://agent-skills.techleads.club/skills/react-composition-patterns/
- https://agent-skills.techleads.club/skills/modular-design-principles/
- https://agent-skills.techleads.club/skills/frontend-design/
- https://agent-skills.techleads.club/skills/web-design-guidelines/
- https://agent-skills.techleads.club/skills/security-best-practices/
- https://agent-skills.techleads.club/skills/security-threat-model/
- https://agent-skills.techleads.club/skills/security-ownership-map/
- https://agent-skills.techleads.club/skills/tlc-spec-driven/
- https://agent-skills.techleads.club/skills/coding-guidelines/

Review-specific choices in this skill:

- project specs/instructions outrank generic style preferences;
- security is passive/high-signal by default and deepens only for sensitive diffs;
- threat modeling is reduced to a small boundary/abuse-path lens during relevant PRs;
- security ownership is advisory during PR review;
- frontend creation aesthetics are not treated as generic review rules;
- domain duplication is not automatically consolidated because reduced duplication can increase coupling;
- `.reviews/` is always the report destination but its version-control policy is deliberately left to the developer/project.
