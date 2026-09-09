# Frontend and Web Interface Review

Load when the diff changes UI, HTML, CSS, forms, navigation, responsive behavior, or interaction.

Review against the project's design system/spec first. Do not impose personal aesthetics or a generic visual style.

## Accessibility and semantics

Check changed interaction for:

- semantic native elements where appropriate;
- accessible names/labels;
- keyboard operability and visible focus behavior;
- correct ARIA usage when native semantics are insufficient;
- form labels, validation feedback, and autocomplete where relevant;
- reduced-motion handling for meaningful animation;
- touch targets/interactions that remain usable on touch devices.

## Navigation and state

Check whether changed UI state that must survive refresh/share/back-forward navigation is represented in the URL or otherwise follows the project's established navigation model.

Check deep links and empty/error/loading states when the spec requires them.

## Content and layout resilience

Review changed UI for:

- overflow with long/user-generated content;
- responsive behavior across supported breakpoints;
- images with appropriate dimensions/loading behavior when material;
- theme/dark-mode compatibility when the project supports it;
- locale/i18n assumptions when the project is localized;
- hydration/client-server mismatches when relevant to the framework.

## Visual direction

The creation-oriented frontend guidance is not a generic review gate. Only flag typography, color, visual hierarchy, density, or aesthetic consistency when the project has a defined visual/design specification that the diff contradicts or when the change creates a clear usability defect.

Use terse `file:line` evidence for UI findings.
