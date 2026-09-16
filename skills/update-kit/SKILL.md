---
name: update-kit
description: Capture a reusable pattern, component, convention, dependency or fix from the current Flutter app into onaya7's flutter-agent-kit and publish it as a reviewed pull request, so every future app starts with it. Use when the user says "add this to the kit", "update the kit" or "update the workspace", or wants something to become the default for new apps.
---

# Update the kit

The kit is the git repo `onaya7/flutter-agent-kit`. Installed copies are caches that get
overwritten, so always edit the clone, and land every change through a pull request.

## 1. Open the clone and check its state
Use the first of these that exists:
1. `$FLUTTER_KIT_DIR`
2. `~/Desktop/flutter_projects/flutter-agent-kit`

If neither exists, run `gh repo clone onaya7/flutter-agent-kit ~/Desktop/flutter_projects/flutter-agent-kit`.

```sh
KIT=~/Desktop/flutter_projects/flutter-agent-kit
git -C "$KIT" status --porcelain                              # must be empty
git -C "$KIT" fetch -q origin
git -C "$KIT" checkout main && git -C "$KIT" pull --ff-only
git -C "$KIT" rev-list --count origin/main..main              # must be 0
gh pr list --repo onaya7/flutter-agent-kit --state open --label kit-propagation
```

Stop and tell the user if the tree is dirty or `main` has unpushed commits; never stash, reset or
overwrite their work. If a propagation PR is already open, add to its branch in step 6 rather than
opening a second one against the same files.

Read the clone's `AGENTS.md` before editing. Then reconcile the app's watermark (step 7), so you know
what has already been published.

## 2. Choose the scope

**A named change.** The user says what to capture. State in one sentence what will change and which
files in the current app it comes from.

**A sweep.** The user asks for whatever is new since last time. The app's watermark is
`.claude/kit-sync.json`:

```sh
APP="$(git rev-parse --show-toplevel)"
WM="$APP/.claude/kit-sync.json"
base="$(jq -r '[.history[]? | select(.status=="merged")][0].app_commit // empty' "$WM" 2>/dev/null)"
git -C "$APP" diff --name-status "${base:+$base..}HEAD" -- .claude/rules .claude/skills
git -C "$APP" status --porcelain -- .claude/rules .claude/skills
```

- **No watermark yet** — compare each app rule and skill against its kit counterpart with `diff -u`
  instead. History from before the first publication is noise.
- **The recorded commit is gone**, because its branch was squashed — fall back to
  `--since=<app_date from that entry>`.
- **Uncommitted edits** may propagate, but list them in `dirty_paths` so the next sweep offers them
  again. Never commit in the user's app.

Show candidates as a numbered table in three groups — new, pending in an open PR, and skipped by
`never_propagate` — and let the user pick. Keep one topic per PR; if the picks span unrelated topics,
propose two branches.

## 3. Choose where it goes

| It is | Put it in |
|---|---|
| A procedure with steps | An existing skill, or a new `skills/<name>/SKILL.md` |
| A convention for certain paths | A rule template under `skills/new-app/assets/`, plus its line in the AGENTS.md template's rule index |
| A fact every session needs | The AGENTS.md template under `skills/new-app/assets/` |
| Reusable code (widget, helper, core class) | The base app under `skills/new-app/assets/` |
| A dependency, lint or build setting | The base app's `pubspec.yaml`, `analysis_options.yaml` or `makefile` |
| A guardrail the app improved | `scripts/`, plus the same rule in the AGENTS.md template |
| Something Claude Code must be blocked from doing | `hooks/hooks.json` and `scripts/`, plus the same rule in the AGENTS.md template |
| How the kit itself works | The kit's `AGENTS.md` |

Code that only makes sense with an optional module (Firebase, push notifications, maps and so on)
goes in that module, not the base.

## 4. Generalize

Apply this test to every line you carry across: **would it still be true in an app scaffolded a
minute ago by `new-app`?** If not, rewrite it or drop it.

**May cross:** the shape of a convention; a symbol that exists in the base app; the kit's own theme
roles, make targets and env file names; a "why" sentence that names no app artifact.

```sh
grep -rlw --include='*.dart' '<Symbol>' "$KIT/skills/new-app/assets/template/lib"
```

**Must never cross:** app and organisation names or bundle IDs; feature folder names under
`lib/features/`; symbols only that app defines; SDKs the base app does not depend on; release
plumbing such as lane names and store credential variables; counts that describe one repo's current
state; a dependency override that exists for one app; design-tool variable names and node ids.

**Typical rewrites:**

| In the app | In the kit |
|---|---|
| A renamed theme role | The kit's own role name |
| "Reference implementation `SomeCubit` in `lib/features/<feature>/`" | "Mirror the app's existing one; search for `loadMore` under `lib/`" |
| A per-feature folder exception | The kit's single convention |
| The app's env file names | `.env.development`, `.env.staging`, `.env.production` |

Then catch vocabulary no list anticipates:

```sh
git -C "$KIT" diff main...HEAD -- . ':!skills/new-app/assets/template' \
  | grep '^+' | grep -oE '\b[A-Z][A-Za-z0-9]{3,}\b' | sort -u \
  | while read -r s; do
      grep -rqw --include='*.dart' "$s" "$KIT/skills/new-app/assets/template/lib" \
        || echo "not in the base app: $s"
    done
```

Every line of output is a decision to make before committing. Whenever you introduce a symbol into
the kit's prose, add it to `symbols=` in `tests/references.test.sh` in the same commit; that list is
hardcoded, so an unlisted symbol is never verified.

Search the clone for every skill and template that mentions what you changed, and update them
together.

**A failure in `tests/references.test.sh` on a name you added is the guard working.** Three
responses, in order of preference:
1. Add the missing piece to the base app, and list its symbol. This makes the change tier 3.
2. Reword to drop the concrete name.
3. Drop the sentence; it was an app fact in disguise.

Never delete an entry from that test to make it pass, and never add a stub file to satisfy it.

## 5. Validate by tier

The shell suite runs in about five seconds, so it always runs in full. Only the smoke test is tiered.

```sh
files="$(git -C "$KIT" diff --name-only main...HEAD)"
tier=1
grep -qE '^(scripts/|hooks/|skills/[^/]+/scripts/|skills/new-app/assets/agent/\.claude/settings\.json)' <<<"$files" && tier=2
grep -qE '^skills/new-app/assets/(template|modules)/' <<<"$files" && tier=3
echo "tier $tier"
```

| Tier | What changed | Run |
|---|---|---|
| 1 | Skill and rule prose, `AGENTS.md`, `README.md` | `claude plugin validate .`; `bash -n scripts/*.sh skills/*/scripts/*.sh`; `for t in tests/*.test.sh; do "$t" \|\| exit 1; done` |
| 2 | `scripts/`, `hooks/hooks.json`, a skill's scripts, the agent settings template | Tier 1, then `skills/new-app/scripts/smoke-test.sh` |
| 3 | Anything under `skills/new-app/assets/template/` or `assets/modules/` | Tier 2, run as `SMOKE_BUILD=1 skills/new-app/scripts/smoke-test.sh` |

Fix every failure. State the tier in the pull request, so a reviewer knows what was proved.

## 6. Branch, commit, push, open the pull request

Never commit on `main`.

```sh
BRANCH="kit/<topic>-$(date +%Y%m%d)"      # topic is the kit file's stem, such as ui-conventions
git -C "$KIT" switch -c "$BRANCH"         # or: switch "$BRANCH" to add to an open propagation
git -C "$KIT" add -A
git -C "$KIT" commit -m "docs(rules): <what changed>"
git -C "$KIT" push -u origin "$BRANCH"
gh pr create --repo onaya7/flutter-agent-kit --base main --head "$BRANCH" \
  --label kit-propagation --title "<the commit subject>" --body-file "$body"
git -C "$KIT" checkout main
```

Keep the source app's name out of the branch and title — the kit's refs are shared and permanent.
Provenance belongs in the body:

```markdown
## What changed
One line per convention, as it now reads in the kit.

## Why it generalises
What stays true in a freshly scaffolded app, and which app-specific parts were dropped.

## Source
Published from <app> at <short sha>, branch <branch>. Uncommitted at scan time: <files, or none>.

## Kit files
- <path>

## Validation, tier <n>
- <command> — pass

## After merge
`git -C ~/.claude/skills/flutter-kit pull --ff-only`, `npx skills update -g`, and `sync-app` in apps
that have a `.kit.json`.
```

Never paste the app's remote URL into a body, message or log; it may embed a credential. Reference
commits by short SHA.

## 7. Record the watermark

Write `.claude/kit-sync.json` in the app, newest entry first, and leave it uncommitted for the user:

```json
{
  "kit_repo": "onaya7/flutter-agent-kit",
  "schema": 1,
  "history": [
    {
      "app_commit": "<sha>", "app_date": "<yyyy-mm-dd>", "topic": "<topic>",
      "kit_branch": "<branch>", "kit_pr": 0, "status": "open",
      "proposed": ["<app path>"], "dirty_paths": []
    }
  ],
  "never_propagate": []
}
```

The sweep baseline is the newest entry whose `status` is `merged`, so an unmerged pull request never
advances it and its files keep resurfacing. At the start of every run, reconcile each open entry:

```sh
gh pr view <n> --repo onaya7/flutter-agent-kit --json state,mergeCommit --jq '{state, sha: .mergeCommit.oid}'
```

- **Merged** — set `status` to `merged` and record the merge commit. If the reviewer edited the
  branch, `git -C "$KIT" diff <branch tip> <merge sha>` shows what they changed; report it, and never
  apply it back into the app automatically.
- **Closed unmerged** — set `status` to `closed`, and offer to add the path to `never_propagate` so
  the sweep stops proposing it.

## 8. Tell the user how the change arrives

After the pull request merges:
- **Claude Code, skills-folder install:** `git -C ~/.claude/skills/flutter-kit pull --ff-only`, or
  nothing at all when that path is a symlink to this clone. It cannot detect staleness on its own, so
  check `git -C ~/.claude/skills/flutter-kit status -sb` after fetching.
- **Claude Code, marketplace install:** automatic when auto-update is on for `flutter-agent-kit`;
  otherwise `/plugin marketplace update flutter-agent-kit`, then `/reload-plugins`.
- **Other agents:** `npx skills update -g`.
- **Apps created earlier** keep their own copies of `AGENTS.md`, rules and base code. Offer to run
  the `sync-app` skill in them.
