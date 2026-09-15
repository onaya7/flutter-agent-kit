# flutter-agent-kit

onaya7's kit for starting and working in Flutter apps with any AI coding agent. It holds the base
app every new project starts from, the agent instructions each app receives, and skills in the
[Agent Skills](https://agentskills.io/specification) format.

## How it reaches agents

| Channel | Agents | Install once | Pick up changes |
|---|---|---|---|
| Claude Code plugin (`.claude-plugin/`) | Claude Code | `claude plugin marketplace add onaya7/flutter-agent-kit`, then `claude plugin install flutter-kit@flutter-agent-kit` | Automatic when auto-update is on for this marketplace; otherwise `/plugin marketplace update flutter-agent-kit`, then `/reload-plugins` |
| `npx skills` | Codex, Cursor, Copilot, Gemini CLI, Amp, opencode, Windsurf | `npx skills add onaya7/flutter-agent-kit -g --agent universal --skill '*' -y` | `npx skills update -g` |

Hooks run only in Claude Code. Any rule a hook enforces must also be written into the app
`AGENTS.md` template so other agents follow it.

## Where things live

| Path | Holds |
|---|---|
| `skills/<name>/SKILL.md` | One procedure per skill |
| `skills/new-app/assets/` | Everything a new app is built from. Installers copy only skill folders, so templates cannot live anywhere else |
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
- Edit an existing skill, rule or template before adding a new one.

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
