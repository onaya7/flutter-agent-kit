# Spec template

A spec lets a session that has never seen the feature build it. Name the file after the feature in
kebab case: `context/features/<name>.md` or `context/fixes/<name>.md`. Drop a section that does not
apply rather than leaving it empty.

```markdown
# <Feature name>

## Goal
What the user can do when this ships, in two or three sentences.

## Context
What exists today: the folders, screens and cubits this builds on, verified against the code.

## Decisions
Choices the user made, dated (YYYY-MM-DD). One line each.

## Design
The screens, one block each: purpose, content, states (empty, loading, error, success), and
where it navigates. Record design-tool frame ids here, never in code.

## Architecture
Data → domain → presentation for this feature: endpoints or stubs, models, usecases, cubits,
routes, and anything promoted to shared code first.

## Phases
1. **A — <name>**: what it builds and what proves it done.
2. **B — <name>**: …

## Verification
The gate, plus the manual flows to run on a device.

## Open questions
Numbered; mark each one answered, with the date, rather than deleting it.

## Progress
Appended by `feature handoff`: one dated block per session.
```
