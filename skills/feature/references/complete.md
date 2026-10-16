# complete

Run only when the user asks to complete the feature.

1. Run the gate from `AGENTS.md`; stop if it fails.
2. Check `docs/features/<feature>.md` against `.claude/rules/feature-docs.md` and `AGENTS.md`
   against the change; fix what became wrong.
3. Commit the remaining work on the feature branch with a conventional message.
4. Reset `context/current-feature.md`:
   - H1 back to `# Current Feature`, Status `Not Started`, Spec and Goals cleared
   - Notes: drop what this feature settled, keep what is still open
   - Append to History: `- **<Name>** — <one line on what shipped> (<short SHA>, <YYYY-MM-DD>)`
5. Commit it as `chore: record <name> in current-feature.md`.
6. Ask before pushing, and before opening a pull request into `development`. Never merge into a
   release branch; releases are a separate request.
7. Once merged, ask before deleting the local and remote branch.
