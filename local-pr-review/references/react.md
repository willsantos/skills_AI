# React Composition Review

Load only when React component APIs, reusable components, providers/context, or component state architecture change.

Use the repository's React version and local conventions. Do not apply version-specific advice unless the version is established.

## High-signal review rules

### Prefer composition over boolean-mode proliferation

Flag a reusable component API when many boolean props create combinations/modes that are hard to reason about, especially when the new change adds another mutually dependent mode.

Prefer explicit variants or composed subcomponents when that is consistent with the project.

Do not flag a single obvious boolean such as `disabled` merely for being boolean.

### Keep state implementation behind the provider boundary

When a provider/context is used as an abstraction, consumers should depend on the public state/actions contract rather than reaching into the provider's storage/implementation details.

### Lift shared state intentionally

If siblings need coordinated state, prefer a clear common owner/provider rather than duplicated state synchronized through effects or incidental coupling.

### Prefer explicit component APIs

For reusable UI, explicit variant components or composable children are often clearer than proliferating mode props or specialized render callbacks. Apply this only when it simplifies the API and matches the codebase.

## Review standard

A composition concern is blocking only when it creates a concrete correctness, compatibility, or documented-architecture problem. API elegance alone belongs in Suggestions.
