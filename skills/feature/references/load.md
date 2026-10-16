# load

1. Read the argument after `load`:
   - **One word or a path**: find `context/features/<name>.md` or `context/fixes/<name>.md`. If
     neither exists, say so and stop.
   - **Several words**: treat it as a description. Write a spec from it at
     `context/features/<kebab-name>.md` (or `context/fixes/` for a bug) following
     [spec-template.md](spec-template.md). Verify every path and class you name in **Context**
     against the code, and ask about anything the description leaves open.
   - **Nothing**: stop with "load needs a spec name or a description".
2. If `context/current-feature.md` already has a feature `In Progress`, ask before replacing it.
3. Update `context/current-feature.md`:
   - H1 → `# Current Feature: <Name>`
   - `## Spec` → the spec's path
   - `## Goals` → the spec's goals as bullets, one per phase at most
   - `## Notes` → constraints worth seeing every session; keep notes from earlier features that
     are still open
   - `## Status` → `Not Started`
4. Show the goals and the phases, and ask any open question that blocks phase A.
