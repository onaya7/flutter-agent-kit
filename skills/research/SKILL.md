---
name: research
description: Run a research prompt from context/research/<name>.md in a flutter-agent-kit app and write the findings as documentation, without touching source code. Use when the user asks to research a package, an API, a platform rule or a design and capture the result.
---

# Research

Run from the app's root with the prompt name as the argument.

1. With no argument, stop with "Usage: research <prompt-name>".
2. Read `context/research/<name>.md`. If it is missing, say so, offer to write it with the user,
   and stop. A prompt file has:
   - **Output**: where to write results (default `docs/research/<name>.md`)
   - **Question**: what to find out, and the decision it feeds
   - **Include**: the details to capture
   - **Sources**: files, packages, sites, design files or tools to use
3. Research with what the prompt names:
   - The app's code, `AGENTS.md`, rules and docs, for how it works today
   - Package pages and changelogs on pub.dev, and current library docs, for versions, platform
     support and breaking changes. Check each package's minimum Flutter and Dart against the app's
     `.fvmrc` and `pubspec.yaml` before recommending it
   - Platform guidance (Apple Human Interface Guidelines, Material, store review rules) for
     platform behaviour
   - The design file, when the prompt asks for screens
4. Write the findings to the output path: the answer first, then the evidence with a source for
   each claim, then the options with their trade-offs and a recommendation.
5. Summarize what you found in a few lines.

## Rules

- Documentation only: never edit `lib/`, `test/` or platform folders, and never add a dependency.
- No branches or commits.
- Mark anything unverified as unverified, with the check that would settle it.
