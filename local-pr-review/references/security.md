# Security Review

Load this reference when the diff touches a security-sensitive surface. Baseline reviews may still flag obvious critical/high-impact vulnerabilities without loading this file.

## Establish context

Identify the affected language/framework and the relevant trust boundary. Review both frontend and backend portions when the changed flow crosses both.

Project-specific security rules and documented exceptions matter. Do not fight a documented exception, but accurately describe residual risk when material.

## High-signal checks

Prioritize concrete exploitable or high-impact issues, including as applicable:

- hard-coded credentials, tokens, private keys, or secrets;
- missing authorization checks on privileged actions or object access;
- injection into SQL/commands/templates/queries;
- unsafe HTML/script handling and XSS paths;
- SSRF or unrestricted server-side fetching from attacker-controlled destinations;
- path traversal or unsafe file handling/uploads;
- unsafe deserialization/parser usage on untrusted data;
- missing validation at a new trust boundary;
- sensitive data exposure in logs, URLs, client bundles, errors, or responses;
- insecure cryptographic or authentication defaults;
- privilege escalation introduced by role/permission changes;
- dependency/CI changes that expose credentials or execute untrusted code with elevated permissions.

Do not produce a generic vulnerability checklist in the report. Report only findings grounded in the diff/repository.

## Mini threat-model lens for new boundaries

If the diff introduces a new endpoint, parser, upload surface, external integration, privileged job, authentication boundary, or other meaningful entry point, briefly reason about:

1. protected asset;
2. concrete entry point/trust boundary;
3. realistic attacker capability;
4. plausible abuse path;
5. existing/required mitigation.

Keep this internal unless it supports a finding. Do not turn every PR review into a full threat-model document.

## Security ownership is advisory

For especially sensitive changed files, git history may be inspected to understand whether ownership is concentrated or effectively orphaned. This is useful for risk context, not for general maintainer lists.

Ownership/bus-factor concerns alone are not code blockers. Put them in Suggestions unless a project policy explicitly makes ownership/approval mandatory.
