# flutter-agent-kit

This kit starts every Flutter app from the same tested base, with the same agent instructions, in
whichever AI coding agent you use. It grows when you tell your agent "add this to the kit".

## What's inside

| Piece | What it does |
|---|---|
| `new-app` | Creates an app with FVM-pinned Flutter, three flavors, clean architecture + bloc, DI, networking, theming, routing, tests and CI. It also writes `AGENTS.md`, path-scoped rules and Claude Code settings. |
| `add-feature`, `add-route`, `paginate-list`, `add-picker-sheet`, `codegen`, `ship-flavor` | Everyday procedures inside an app |
| `update-kit` | Moves a pattern from the app you're working in into the kit |
| `sync-app` | Brings an app created earlier up to date with the kit |
| `adopt-app` | Brings an app that wasn't created from the kit onto it |
| Hooks (Claude Code only) | Block edits to generated Dart, format Dart on write, flag stale feature docs |

## Install once per machine

**Requirements:** `fvm`, `git`, `jq`, `bash` and `perl`. Xcode and the Android SDK are needed only
to build and run apps.

### Claude Code
Clone the repo into the skills folder. Claude Code then loads it in every folder as
`flutter-kit@skills-dir`, with no marketplace and no extra authentication:

```sh
git clone https://github.com/onaya7/flutter-agent-kit.git ~/.claude/skills/flutter-kit
```

Update it with `git -C ~/.claude/skills/flutter-kit pull`. If you also work on the kit itself,
symlink your working clone there instead and every edit is live:

```sh
ln -s ~/Desktop/flutter_projects/flutter-agent-kit ~/.claude/skills/flutter-kit
```

**Alternative: install it as a marketplace plugin**, which can update itself in the background:

```sh
claude plugin marketplace add onaya7/flutter-agent-kit
claude plugin install flutter-kit@flutter-agent-kit
```

Then run `/plugin`, open **Marketplaces**, select `flutter-agent-kit` and choose **Enable
auto-update**. The repo is private and background updates don't use git credential helpers, so this
route also needs either an SSH key on your GitHub account (then add the marketplace as
`git@github.com:onaya7/flutter-agent-kit.git`) or a fine-grained read-only token wired in with:

```sh
git config --global url."https://x-access-token:<TOKEN>@github.com/onaya7/flutter-agent-kit".insteadOf "https://github.com/onaya7/flutter-agent-kit"
```

### Codex, Cursor, Copilot, Gemini CLI, Amp, opencode, Windsurf
```sh
npx skills add onaya7/flutter-agent-kit -g --agent universal --skill '*' -y
```
This installs the skills into `~/.agents/skills`, which all of these agents read. Update them with
`npx skills update -g`.

### Recommended alongside
The official Flutter plugin provides generic Flutter and Dart skills plus the Dart MCP server:
- **Claude Code:** apps created by the kit prompt for it automatically. To install it globally, run
  `claude plugin marketplace add flutter/agent-plugins`, then
  `claude plugin install dart-flutter@dart-flutter`.
- **Other agents:** `npx skills add flutter/agent-plugins --skill '*' --agent universal -y`

## Use it

In any agent, you can ask in plain words: "create a new Flutter app", "add this to the kit", "sync
this app with the kit".

To call a skill directly:

| Agent | Syntax | Example |
|---|---|---|
| Claude Code | `/flutter-kit:<skill>` | `/flutter-kit:new-app` |
| Cursor, Copilot | `/<skill>` | `/new-app` |
| Codex | `$<skill>` | `$new-app` |
| Windsurf | `@<skill>` | `@new-app` |
| Gemini CLI, opencode | ask for the skill by name | "use the new-app skill" |

Run `new-app` in an empty folder, or give it the folder to create.

## How changes flow

1. In any app, say "add this to the kit". `update-kit` generalizes the change, edits your local clone
   of the kit (`$FLUTTER_KIT_DIR`, or `~/Desktop/flutter_projects/flutter-agent-kit`), runs the checks
   its tier calls for, then opens a pull request from a `kit/<topic>-<date>` branch. Nothing reaches
   `main` unreviewed.
2. After you merge it, changes arrive differently depending on what changed:

| What changed | How it reaches you |
|---|---|
| Skills and hooks in Claude Code | Skills-folder install: `git -C ~/.claude/skills/flutter-kit pull`, or nothing at all when it is a symlink. Marketplace install: automatic with auto-update on, otherwise `/plugin marketplace update flutter-agent-kit`, then `/reload-plugins` |
| Skills in other agents | `npx skills update -g` |
| Base code, `AGENTS.md`, rules and settings in existing apps | Run `sync-app` in the app. Apps keep their own copies on purpose, because each app adds its own facts. |

## Working on the kit
Read [AGENTS.md](AGENTS.md). Before every commit:

```sh
claude plugin validate .
for t in tests/*.test.sh; do "$t" || exit 1; done
skills/new-app/scripts/smoke-test.sh           # SMOKE_BUILD=1 for native or dependency changes
```
