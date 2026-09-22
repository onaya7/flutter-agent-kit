---
paths:
  - "lib/**"
  - "test/**"
---

# Comments: as short as the reason allows, default to none

The bar is **zero comments**. A comment earns its place only when a reader who understands Dart
and this codebase would still get the line wrong. Then it is **one line**, wrapped at 80 columns
including the indent — and **at most three** when the reason genuinely needs them.

Three is a ceiling, not a budget. Every line has to carry reason; the moment one restates the code
or justifies the line above, it goes. Four lines is an essay and belongs in the table below.

Do not run a bulk pass that collapses comments to their first sentence. The reason is often the
*second* clause — "…because both the flag and the balance move" — so the sweep keeps the summary
and deletes the point, and anything past the column limit comes out truncated mid-sentence. If a
block has to shrink, rewrite it; if that cannot be done without losing the reason, it was not too
long.

## Hard rules
- **One line wherever one will do.** Reach for a second or third only when dropping it would lose
  the reason — a package quirk, a fallback the wire forces, a rejected alternative. Never to
  restate the code or to justify the line above.
- **Never restate the code.** `// Persists the token` above `saveToken()` is noise.
- **No `///` essays.** A doc comment on a public member follows the same one-line limit. Don't
  write a `///` paragraph explaining a whole mechanism; that's what `docs/` is for.
- **Don't narrate the change.** No "fixed a bug where…" and no "previously this…". The diff and the
  commit message carry that.
- **Don't cross-reference another symbol's rationale** ("same reasoning as [_endSession]"). State
  this line's reason, or say nothing.
- **Never reference a design-tool node or frame.** Describe the widget by its purpose.

## Where a comment is allowed at all

**Reusable widgets may carry one doc line.** A shared widget in `lib/core/components/**` or a
feature's `presentation/widgets/**` may open with a single `///` saying what it is for and how it is
meant to be used. That line is the closest thing the widget has to an API; callers read it instead
of the build method. Its constructor params get a `///` only when the name genuinely can't carry the
meaning (an encoded backend enum, a unit).

**Views carry no comments at all.** Anything under `presentation/view/**` gets zero `//` and zero
`///`, with no exceptions. If something in a view needs explaining, one of these is true, and each
has a fix:

- It's a fact about the feature: put it in `docs/features/<feature>.md`.
- It's logic that needs a name: lift it into a cubit, a helper, or a named private method.
- It's a widget that needs explaining: it belongs in `widgets/` with its one doc line.

Extracting a `_canSubmit` getter or a well-named local beats any comment describing the same
condition inline.

## Keep the reason, drop the retelling
State the *why* in its shortest true form. Most long comments are one sentence of reason plus
several of justification. Keep the first; delete the rest.

```dart
// BAD — four lines to say one thing
/// Apple sends the user's name on the first authorization for a bundle id and
/// never again — not on reinstall, not after the account is deleted. A
/// sign-up can still fail after that one chance, so the name is parked in the
/// keychain the moment it arrives and read back later.

// GOOD
/// Apple sends the name once ever, so it is parked until sign-up accepts it.
```

```dart
// BAD — a paragraph of consequence
/// The cubits behind these buttons are app-wide singletons, so every mounted
/// copy sees the same state change. Only the visible screen may act on it —
/// otherwise a flow that routes back to its starting screen pushes a second
/// copy, which then reacts too.

// GOOD
/// The cubits are app-wide singletons — only the visible screen may react.
```

## Where the deleted detail goes
| Detail | Home |
|---|---|
| Why this change was made | commit message |
| A convention future changes must follow | a `.claude/rules/` file |
| System-wide mechanics | `docs/ARCHITECTURE.md` |
| A shared component's usage guide | `docs/components/<name>.md` |
| How a feature's flow hangs together | `docs/features/<feature>.md` |

**Check the destination exists before you delete anything.** If the app writes feature docs on
demand and this one has not been written, keep the detail in the comment. A rule that sends detail
to a file nobody maintains deletes it.

## Lint directives are not prose
`// ignore:` and `// ignore_for_file:` are code, not comments; never delete them.
`very_good_analysis` enables `document_ignores`, which **requires** one explanatory line directly
above the directive. That pair is the one sanctioned two-line block; keep the justification to a
single line.

## Section markers are fine
Single-word groupers in a long constants file, like `// Auth` or `// Settings` in `app_url.dart`,
are not prose comments and stay.
