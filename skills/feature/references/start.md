# start

1. Read `context/current-feature.md` and its spec. If Goals are empty, stop with "run `feature load`
   first".
2. **First start** (Status `Not Started`):
   - `git status` must be clean; if not, ask the user to commit or stash. Never do either for them.
   - Check out `development`, pull, and create `feat/<name>` or `fix/<name>` from the H1. If the
     user's work lives on another branch, ask which branch to start from.
   - Set Status to `In Progress`.
3. **Resume** (Status `In Progress`): stay on the current branch. Read the spec's **Progress** and
   **Open questions** and pick up the first unfinished phase.
4. Before writing code, read the app's `AGENTS.md`, the `.claude/rules/` file for every path you
   will touch, and the shared widgets and helpers it tells you to check.
5. Build that one phase, with its tests. Run the gate from `AGENTS.md`.
6. Report what the phase built, the gate result, anything you decided on the user's behalf, and the
   open questions. Wait for the go before the next phase.
