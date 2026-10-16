# flutter-agent-kit

onaya7's kit for starting and working in Flutter apps with any AI coding agent. It holds the base
app every new project starts from, the agent instructions each app receives, and skills in the
[Agent Skills](https://agentskills.io/specification) format.

## How it reaches agents

| Channel | Agents | Install once | Pick up changes |
|---|---|---|---|
| Skills folder, as a clone or a symlink | Claude Code | `git clone https://github.com/onaya7/flutter-agent-kit.git ~/.claude/skills/flutter-kit` | `git -C ~/.claude/skills/flutter-kit pull`; nothing when it is a symlink to a working clone |
| Claude Code plugin (`.claude-plugin/`) | Claude Code | `claude plugin marketplace add onaya7/flutter-agent-kit`, then `claude plugin install flutter-kit@flutter-agent-kit` | Automatic when auto-update is on for this marketplace; otherwise `/plugin marketplace update flutter-agent-kit`, then `/reload-plugins` |
| `npx skills` | Codex, Cursor, Copilot, Gemini CLI, Amp, opencode, Windsurf | `npx skills add onaya7/flutter-agent-kit -g --agent universal --skill '*' -y` | `npx skills update -g` |

Hooks and agents run only in Claude Code. Any rule a hook enforces must also be written into the app
`AGENTS.md` template so other agents follow it, and any check an agent makes must also be reachable
through a skill (the `feature` skill's `review` action covers the agents).

## Where things live

| Path | Holds |
|---|---|
| `skills/<name>/SKILL.md` | One procedure per skill |
| `skills/new-app/assets/` | Everything a new app is built from. Installers copy only skill folders, so templates cannot live anywhere else |
| `agents/` | Claude Code review agents; read-only and app-agnostic, they read each app's `AGENTS.md` for its specifics |
| `hooks/hooks.json`, `scripts/` | Claude Code guardrails; every script exits early outside a Flutter project |
| `.claude-plugin/` | Claude Code marketplace and plugin manifests |

The layout inside `skills/new-app/assets/` and the template placeholders are documented in
`skills/new-app/SKILL.md`.

## Rules for changing the kit

- **Nothing app-specific.** No product names, endpoints, brand colors, bundle IDs, copy or
  secrets from any app. Use the placeholders defined in `skills/new-app/SKILL.md`.
- **A skill states a procedure.** Facts about one app belong in that app's `AGENTS.md` or
  `.claude/rules/`, never in the kit.
- **Follow the Agent Skills spec.** `name` matches its folder (lowercase, digits, hyphens);
  `description` says what the skill does and when to use it, within 1024 characters; keep the body
  under about 500 lines and move detail into `references/`.
- **Write for any agent.** Name commands and files, not one agent's tool names.
- **Never add `version` to `.claude-plugin/plugin.json`.** The commit SHA is the version, so every
  push reaches installed copies.
- **Comments in code and scripts:** one line, only for a non-obvious why.
- **Nothing version-specific stated as timeless.** Apps adopted onto the kit run older toolchains
  than the template pins. Don't assert how a command behaves today — name the version boundary, give
  the one-line live check that decides it, and give both branches. Gate a tool an app may not have
  (`bloc_lint`, `gen-l10n`, CI) on `.kit.json`'s `toolchain.has`, and read a live file for anything
  you are about to run. Never record a resolved package version in `.kit.json`: it is rewritten by
  any `pub get`, and a stale-but-confident value is worse than an absent one.
- Edit an existing skill, rule or template before adding a new one.
- **A file a rule names as the reference is part of that rule.** If it drifts, the rule teaches the
  drift — a bloc held up as the house style for state unions was found with every variant private,
  which is the thing that rule bans. Verify the reference when you change the rule.
- **A rule that names a destination must name one that exists.** Sending detail to a doc the app
  writes on demand deletes it. Say "keep it here until that file exists" instead.
- **Prefer an assertion to prose for anything greppable.** A convention held by hand is held until
  the next hurry; `test/conventions/conventions_test.dart` is where a new one goes.

## Before committing

```sh
claude plugin validate .                 # when the claude CLI is installed
bash -n scripts/*.sh skills/*/scripts/*.sh
for t in tests/*.test.sh; do "$t" || exit 1; done
skills/new-app/scripts/smoke-test.sh     # scaffolds a throwaway app; runs analyze, bloc lint and tests
```

For changes to native files, dependencies or build settings, run the smoke test as
`SMOKE_BUILD=1 skills/new-app/scripts/smoke-test.sh`. It also builds a debug APK and an iOS
simulator app.

`claude plugin validate` always warns that the root `CLAUDE.md` is not plugin context. That is
expected: the file exists only for sessions opened inside this repo.

Commit on `main` with a conventional message, such as `feat(base): add PhoneNumberField` or
`fix(hooks): skip non-Flutter repos`. Push only after the user approves.
