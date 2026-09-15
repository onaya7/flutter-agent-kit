---
name: ship-flavor
description: Run or build a specific flavor (development, staging, production) of a flutter-agent-kit app through its makefile, including signing prerequisites, and deploy when the app has deploy targets. Use when asked to run the app, produce an APK/AAB/IPA, or push a build to a store or tester group.
---

# Run, build and ship a flavor

There are three flavors:

| Flavor | App ID suffix | Display name | Entry point | Env file |
|---|---|---|---|---|
| `development` | `.dev` | `[DEV] <App>` | `lib/main_development.dart` | `.env.development` |
| `staging` | `.stg` | `[STG] <App>` | `lib/main_staging.dart` | `.env.staging` |
| `production` | none | `<App>` | `lib/main_production.dart` | `.env.production` |

**Always use the makefile.** Every target is already `fvm`-prefixed and pairs the right entry point
with the right native flavor. If those get out of sync, one flavor's Dart code is built into another
flavor's app shell; `bootstrap` asserts against that in debug builds.

## Run
```sh
make run-dev        # or: make run-staging, make run-prod
```
If the user or the project has a preferred simulator or device, pass it with `-d` through raw
`fvm flutter run`, keeping the matching `-t` and `--flavor`.

## Build local artifacts
```sh
make build-{dev,staging,prod}-{apk,aab,ipa}
```
`make help` lists every target. Dev targets build `--debug`; staging and production build
`--release`.

## Signing prerequisites
- **Android release:** either the `ANDROID_KEYSTORE_PATH` family of environment variables (CI) or a
  local `android/key.properties` next to the keystore. Both stay untracked.
- **iOS:** set the development team and signing in Xcode for each configuration. The template ships
  with no team.

## Deploy
Deploying is outward-facing and uses up real release slots. **Confirm with the user before running
any deploy.**
- Look for `deploy-*` targets with `make help`.
- If none exist, the app has no deploy pipeline. Say so; don't invent fastlane or store commands.
- If they exist, read their prerequisites (credentials, env files, lanes) in the app's docs or
  fastlane folders before running.

## Build numbers
The build *name* comes from `version:` in `pubspec.yaml`. Bump it for a user-visible release, and
bump the `+build` number for every store upload unless a deploy lane increments it.
