# AI Interaction Guidelines

## Communication

- Be concise and direct
- Explain non-obvious decisions briefly
- Ask before large refactors or architectural changes
- Don't add features the spec doesn't ask for
- Never delete files without asking

## Workflow

Every feature or fix follows these steps. The `feature` skill runs them (`load`, `start`, `review`,
`test`, `explain`, `handoff`, `complete`); without it, follow them by hand.

1. **Document**: write the spec in `context/features/` or `context/fixes/`, then load it into
   `context/current-feature.md`
2. **Branch**: create `feat/<name>`, `fix/<name>` or `chore/<name>` off `development`
3. **Implement**: one phase of the spec at a time. Report after each phase and wait for a go
4. **Test**: the gate in `AGENTS.md` (analyze with zero issues, tests, and any golden or convention
   suite it names), then a run on a device or simulator through the makefile
5. **Iterate**: adjust until the phase is right
6. **Hand off**: before a session ends mid-feature, write progress, gotchas and open questions into
   the spec so a fresh session can resume from it alone
7. **Commit**: only when asked, and only after the gate passes
8. **Pull request**: into `development`, only when asked
9. **Record**: mark the feature complete in `context/current-feature.md` and add it to History

## Branching

| Branch | Purpose |
| ------ | ------- |
| `feat/*`, `fix/*`, `chore/*` | Work in progress, one feature or fix each |
| `development` | Integration; every pull request targets it |

Record the release branches and what each one builds in `context/project-overview.md`.

## Commits

- Ask before committing; never auto-commit
- Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`)
- One feature or fix per commit
- No AI attribution: no "Generated with" lines and no co-author trailer for any assistant

## When stuck

- If something still fails after 2–3 attempts, stop and explain what you tried
- Don't keep trying random fixes
- Ask when a requirement is unclear, and record the answer in the spec

## Code changes

- Make the smallest change that does the job
- Don't refactor unrelated code unless asked
- Follow `AGENTS.md` and the rule for each path you touch
- Never hand-edit generated files; change the source and rerun codegen

## Code review

Review AI-written code for layer boundaries, `BuildContext` across async gaps, disposed
controllers and subscriptions, hard-coded colours or copy, and missing tests. In Claude Code the
flutter-kit agents `code-scanner`, `refactor-scanner` and `ui-reviewer` cover this; the `feature`
skill's `review` action covers it in any agent.
