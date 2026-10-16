---
name: feature
description: Run a feature or fix in a flutter-agent-kit app from spec to pull request through context/current-feature.md. Actions are load, start, review, test, explain, handoff and complete. Use when the user wants to load a spec, start or resume a feature, review or test it, hand it to a fresh session, or finish it.
---

# Feature workflow

Run from the app's root. The working file is `context/current-feature.md`; specs live in
`context/features/` (features) and `context/fixes/` (fixes). If `context/` does not exist, the app
predates this workflow: create it from the kit's `skills/new-app/assets/agent/context/` (or run
`sync-app`) before going on.

## The working file

`context/current-feature.md` has these sections, in this order:

- `# Current Feature` — becomes `# Current Feature: <Name>` while one is active
- `## Status` — `Not Started`, `In Progress` or `Complete`
- `## Spec` — the path of the spec file, empty for an inline description
- `## Goals` — bullets that define done
- `## Notes` — constraints, decisions and open items carried between features
- `## History` — completed work, oldest first, append only

The spec is the source of truth for scope and progress; `current-feature.md` points at it. A spec
follows [references/spec-template.md](references/spec-template.md).

## Actions

Run the action the user named. With no action, list these and stop.

| Action | Does | Steps |
| ------ | ---- | ----- |
| `load <spec \| description>` | Points the working file at a spec, or writes one from a description | [load](references/load.md) |
| `start` | Branches off `development`, then builds the next phase | [start](references/start.md) |
| `review` | Checks the diff against the goals and the app's conventions | [review](references/review.md) |
| `test` | Runs the gate, then checks the screens on a device | [test](references/test.md) |
| `explain` | Lists what changed and why, file by file | [explain](references/explain.md) |
| `handoff` | Writes progress into the spec so a fresh session can resume | [handoff](references/handoff.md) |
| `complete` | Commits, records History and resets the working file | [complete](references/complete.md) |

## Rules for every action

- The app's `AGENTS.md` names its gate (analyze, test, golden and convention commands) and its
  branch rules. Read it; where it differs from these steps, it wins.
- Build one phase, report, and wait for the user's go before the next.
- Never commit, push or open a pull request unless the user asked for that step.
- No AI attribution in commit messages or pull request bodies.
