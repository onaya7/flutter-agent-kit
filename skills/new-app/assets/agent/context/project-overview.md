# Kit Template App - Project Overview

> One sentence on what the app is for and who it serves.

Fill this in once, then keep it true. It holds the product facts an agent cannot read from the code.
Conventions live in `AGENTS.md` and `.claude/rules/`; system mechanics live in `docs/ARCHITECTURE.md`.
Link to those rather than repeating them here.

## Product

What the app does, grouped by area. A table of area → features works well.

## Audience and goal

Who uses it, and the one or two actions every screen should move them toward.

## Features

| Feature | Folder | Status |
| ------- | ------ | ------ |
|         |        |        |

Each feature's living doc is `docs/features/<feature>.md` (see `.claude/rules/feature-docs.md`).

## Flavors and environments

| Flavor | Entry point | Backend | Distributed through |
| ------ | ----------- | ------- | ------------------- |
| development | `lib/main_development.dart` | | |
| staging | `lib/main_staging.dart` | | |
| production | `lib/main_production.dart` | | |

## Branches and releases

Which branch builds which flavor, how a release reaches the stores, and who approves it.

## Copy and compliance

Rules for user-facing text that the code cannot enforce: regulated claims, words to avoid, brand
spelling, button wording. Delete this section if the app has none.

## Behaviours to keep

Non-obvious product behaviour that a refactor must not break, one line each.
