# test

1. Read `context/current-feature.md` and the spec's **Verification** section.
2. Run the gate exactly as the app's `AGENTS.md` names it. Without an app-specific gate:
   ```sh
   fvm flutter analyze
   fvm dart run bloc_tools:bloc lint .   # only if `jq -r '.toolchain.has[]?' .kit.json` lists bloc_lint
   fvm flutter test
   ```
   Run any golden or screen-capture suite the app keeps separately. Fix what fails before going on;
   never update a golden to make a failure pass without saying which images changed and why.
3. Run the app through the makefile (`make run-dev`, plus any flag `AGENTS.md` requires) and check
   every screen the feature touches:
   - Light and dark theme
   - Text scale at the largest accessibility size: nothing clipped or overflowing
   - A small phone and a large one, portrait; the keyboard open over every input
   - Reduce Motion (iOS) or Remove animations (Android): content still appears, nothing stuck
   - Empty, loading, error and success states, and back navigation from each step
   - No new errors in the debug console
4. If you cannot drive the device yourself, list the exact flows for the user to run and say which
   checks are still unverified.
5. Report what passed, what failed and what was not checked.
