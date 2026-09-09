# Architecture and Modular Design Review

Load this reference only when the diff changes boundaries, shared code, packages/modules/services, or duplicates domain behavior.

## Boundary signals

Healthy modules/bounded contexts tend to have:

- a small, intentional public surface;
- explicit contracts across boundaries;
- ownership of their own domain state;
- minimal hidden mutable state shared across modules;
- internal implementation types kept internal;
- thin composition/transport edges with business rules delegated inward;
- replaceable dependencies where the project architecture expects them;
- failures that do not cascade blindly across boundaries.

Flag only violations introduced or materially worsened by the diff.

High-signal violations include:

- one module directly reading/writing another module's persistence without an agreed contract;
- transport/UI/CLI adapters gaining domain policy that belongs in application/domain code;
- a public facade exposing repositories/internal implementation details;
- cross-module writes with unclear transaction/failure ownership;
- a new shared/global bucket becoming an unowned grab-bag;
- a new dependency direction that contradicts the project's documented architecture.

## Common domain logic and duplication

When similar business logic appears in multiple components, first verify that the domain meaning is genuinely the same.

Distinguish:

- **domain behavior:** business validation, domain formatting, notifications, auditing, policies, calculations;
- **infrastructure behavior:** logging, generic configuration, transport plumbing, database connection mechanics.

Do not automatically recommend consolidation. Some duplication is preferable to harmful coupling.

Before flagging duplicate domain behavior, ask:

1. Is the behavior semantically the same, not merely similarly named?
2. Is duplication introduced or materially extended by this diff?
3. Would consolidation preserve clear ownership?
4. Would the shared abstraction reduce maintenance cost without creating a highly coupled bottleneck?
5. Does the project already define where this shared concept belongs?

A consolidation suggestion is normally non-blocking unless the duplication directly violates a project rule or creates a correctness risk.
