# Project review follow-up

Continues the supplied agent transcript on `chore/project-review-fixes`.
Changes are committed separately by issue; no branch push, PR merge, or release
publication is part of this local handoff.

## Implemented

- Retained the prior agent's CSS escape fix, emulator snapshot caching,
  Dependabot grouping, and exact action pins.
- Replaced retracted `jni_flutter` 1.0.4 with 1.0.4+1.
- Centralized CI and release Flutter versions in `.fvmrc` at 3.47.9 and added
  an advisory beta compatibility job.
- Enabled built-in Kotlin, removed Jetifier and obsolete AGP compatibility
  flags, and replaced deprecated resource configurations with locale filters.
- Skipped reachability probing when only one mirror is configured.
- Added Android metadata-gated clipboard URL detection and a persisted opt-out;
  raw paste remains an explicit user action.
- Kept one themed `MaterialApp` across dynamic-color loading and failures, and
  restored the complete app shell on the reader's root-back path.
- Named the reader route for accessibility while pages load, allowing the
  native release smoke check to identify it without waiting for live content.
- Prepared release attestations, APK checksums, signing-certificate details,
  and checksum verification before publication.
- Migrated to `SharedPreferencesWithCache` using the package's one-time helper.
  The old preferences remain intact; tests cover restart, deletion, and failed
  migration. Reading-progress updates write one visit-specific value instead
  of serializing the history list, and old progress keys are pruned.
- Added a fallback-version regression guard, package-import and directive-order
  rules, shared repository instructions, and current README/changelog guidance.
- Removed the unused launcher-icon generator and its forced `cli_util` override.
- Updated `share_plus`, `shared_preferences`, and `url_launcher` to compatible
  patch releases without changing other locked dependencies.

## Verification boundaries

Local SDK: Flutter 3.47.8 / Dart 3.13.7. CI is configured for Flutter 3.47.9;
the new stable and beta CI jobs have not run remotely in this handoff.

The local analyzer, formatting check (184 files), six JavaScript tests, and
locked dependency resolution passed. The full Flutter suite passed all 339
tests after the three dependency patch updates. The final reader-route label
also passed its seven focused widget tests and the analyzer.

A signed, obfuscated ARM64 release APK built successfully (20.2 MB). Its SHA-256
checksum and signing certificate were verified locally. On the API 37 ARM64
emulator, the final signed APK passed cold SEND, warm VIEW, warm SEND, and Back
to Home. GitHub OIDC attestations require the actual release workflow and
cannot be produced by this local build.

The real WebView integration test passed HTTP 503 mirror failover, native touch
scrolling, theme/metadata callbacks, progress save/restore, bookmarks, sharing,
and back navigation with loopback fixtures. Its first attempt failed the hybrid
composition assertion; a diagnostic rerun passed without changing the assertion
or composition-selection logic. The first failure remains recorded, so hosted
CI still needs to establish repeatability on its own emulator.

The normal debug APK was reinstalled without clearing the local mirror fixture
preferences. Native intent checks then passed cold SEND, warm SEND, warm VIEW,
Back to the preceding article, and a fresh cold VIEW.

The final debug app also completed a hot restart through DTD. Runtime-error
inspection reported no errors.

Initial Android verification failed first on disk exhaustion, then on an
existing debug APK with an incompatible certificate, then on an emulator System
UI ANR dialog covering Freedium. These failures and diagnostics were retained
under `/tmp/freedium-*`; they are not release-validation passes.

## External and optional follow-ups

- Push the branch and observe GitHub CI before merging or shipping. Snapshot
  configuration passing actionlint does not prove the hosted emulator boots.
- The latest published release checked on 2026-11-02 is v0.12.0. The previous
  0.13.0 changelog entries now belong to Unreleased until an actual release.
- Keep `android.newDsl=false`: Flutter's current Gradle plugin still requires
  the old DSL. Recheck Flutter support before moving to AGP 10.
- A remotely maintained mirror manifest needs an identified trusted endpoint
  and ownership. No arbitrary third-party mirror source was introduced; users
  can continue adding custom mirrors through Settings.
- IzzyOnDroid publication and larger UI dependency upgrades remain optional
  distribution/maintenance work. Grouped Dependabot updates can propose those
  changes after this branch lands.
- TalkBack, native share-sheet recipients, real document providers, and live
  mirror availability need their separate device/service checks.

## Documentation consulted

- [Flutter built-in Kotlin migration](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin)
- [AGP API updates](https://developer.android.com/build/releases/gradle-plugin-api-updates)
- [Shared preferences migration](https://pub.dev/packages/shared_preferences)
- [Flutter action version files](https://github.com/subosito/flutter-action#use-version-from-pubspecyaml-or-fvm-config)
- [APK build attestations](https://github.com/actions/attest/tree/v4.2.2)
- [Android clipboard classification](https://developer.android.com/reference/android/content/ClipDescription)
