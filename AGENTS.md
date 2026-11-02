# Freedium Mobile

Flutter Android reader for seven supported publishers. Keep fixes focused and
reuse the existing Material 3 Expressive components and feature structure.

## Current documentation

Use Context7 MCP for library, framework, SDK, API, CLI, or cloud-service syntax,
configuration, migration, setup, and library-specific debugging. Resolve the
library ID first, then query one concept at a time. Prefer official sources.
General refactoring, business logic, and code review do not require a lookup.

## Code map

- `lib/features/<feature>/application`, `domain`, and `presentation` separate
  providers, models, and UI. Keep screens and reusable widgets in focused files.
- `lib/features/shell/presentation/app_shell.dart` hosts the four app tabs.
- `lib/core/routing/app_navigation.dart` owns the navigator, route observer,
  and article routes. Reader fallback navigation restores `AppShell`.
- `lib/core/layout/floating_toolbar.dart` provides bottom toolbar clearance.
- `lib/core/services/font_size_service.dart` owns the shared preferences provider
  and one-time legacy migration. All app services use `SharedPreferencesWithCache`.
- Settings and bookmark libraries save complete snapshots. Preserve recovery
  snapshots and reload the preferences cache after failed snapshot writes.
- History stores frequent progress updates per article visit. Keep metadata and
  retention changes serialized with progress writes.

## Patterns

- Use Riverpod code generation for state and derived providers. Keep manual
  providers for existing injectable function/service seams.
- Use Freezed models and `copyWith()`. Regenerate with
  `dart run build_runner build`; do not hand-edit generated files.
- Check `ref.mounted` or `context.mounted` after asynchronous work before use.
- Keep storage mutations serialized with `SerialTaskQueue`.
- Validate incoming URLs with the shared URL helpers. Inject themes only into
  configured mirror origins, respecting path boundaries.
- WebView failures must identify the main document; subresource failures must
  not trigger mirror switching. Initialize the requested document before loading.
- Theme injection passes CSS through JavaScript template literals. Preserve
  escapes for backslashes, backticks, and interpolation markers.
- Consume the launching `receive_intent` intent once; retain pending URLs while
  onboarding or theme loading finishes. Keep duplicate-route detection.
- Automatic clipboard detection uses Android URL metadata. Raw clipboard reads
  belong to the explicit paste action; respect the saved opt-out.
- Use package imports, ordered directives, and `debugPrint()` for diagnostics.

## Verification

CI and release Flutter versions come from `.fvmrc`. Dependencies are locked.

```sh
flutter pub get --enforce-lockfile
dart format --set-exit-if-changed .
flutter analyze --no-pub --fatal-infos
flutter test --no-pub
node --test test/js/*.mjs
actionlint .github/workflows/ci.yml .github/workflows/release.yml
```

For Android and release changes, use `docs/android-validation.md`. Integration
and release smoke tests clear preferences, so use a disposable emulator. Keep
`--no-uninstall` for the integration-to-intent-smoke sequence. Release builds
use `tool/build_release_apks.sh` and keep symbols under `build/`.
