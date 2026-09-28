# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Changed

- Replaced `listen_sharing_intent` with `receive_intent` (pinned 0.2.8)
  for share-to-app intents: VIEW data URIs and SEND extra text are mapped
  through `intentShareText`, with no media-file handling (unused) and no
  reset API (initial intents are consumed exactly once). This removes the
  last Kotlin Gradle Plugin build warning.

## [0.13.0] - 2026-09-26

### Added

- Bookmark folders: single-level labels with filter chips, an Unsorted view,
  a move-to-folder sheet (also via long-press on the WebView bookmark
  button), and a manage-folders sheet (create, rename, delete). Deleting a
  folder keeps its articles as Unsorted.
- Bookmark export/import: shareable versioned JSON backups with validation,
  duplicate merging, and an imported/skipped report.
- History retention controls: keep the last 30, 100, or 500 articles plus
  clearing entries older than 30 days, from the History options menu.
- Finished stories section on Home for re-reading completed articles.
- Full-page article theming: component token aliases (`--primary`,
  `--accent`, `--muted`, `--card`, `--popover`, `--border`, `--ring`),
  Table of Contents, footer, brand lockup, tables, blockquotes, embeds,
  selection, and scrollbar coverage.
- Full Shiki code-token recoloring: canonical github-light/github-dark
  palettes remapped to the app palette (JS remap with CSS fallbacks),
  verified against the live Freedium DOM in light and dark modes.

### Improved

- Ships the post-0.12.0 modernization pile-up: Riverpod `@Riverpod`
  codegen, Freezed models with JSON serialization, unified URL/date/mirror
  helpers, shared library list widgets, strict analyzer lints, and expanded
  test coverage (217 tests, analyzer clean).
- CI and release both run on Flutter stable with locked dependencies.

### Fixed

- Corrected the fallback app version reported by local/debug builds without
  `--dart-define=APP_VERSION`.
- Aligned ModeWatcher localStorage keys (`mode-watcher-theme`) with the
  current Freedium page.
- Repaired the `theme.js` injection flow (restored reading-progress
  tracking during the Shiki recoloring work).

### Notes

- Releases ship Android APKs only; the repository has no `ios/` target yet,
  so the 0.11.0 "iOS platform support" note should be read as dependency
  groundwork (WKWebView package), not a shippable iOS build.

## [0.12.0] - 2026-08-10

### Added

- Expanded article support to Medium, The New York Times, The Washington Post, Bloomberg, Reuters, The Economist, and Financial Times.
- Added Android **Open with Freedium** handling for the seven supported publishers and their common short-link domains.
- Added persistent reading progress, automatic position restoration, and a home-screen **Continue Reading** section.
- Added reading progress and completion status to History and Bookmarks.
- Added a setting to hide Freedium announcement popups while reading.

### Improved

- Redesigned History and Bookmarks with responsive content widths, richer article cards, source labels, collection counts, clearer swipe actions, and improved empty/search states.
- Updated home, onboarding, About, and README copy for all seven supported sources.
- Updated injected article typography and theme selectors for the current Freedium page structure.

### Fixed

- Prevented themed WebView content from appearing before theme injection completes.
- Normalized article author metadata extracted from Freedium pages.

### Dependencies

- Updated `webview_flutter` to `4.14.1`, `flutter_markdown_plus` to `1.0.12`, and `share_plus` to `13.3.0`.
- Updated Riverpod packages and GitHub Actions dependencies.

## [0.11.0] - 2026-06-09

### Added
- Added iOS platform support.
- Added a home-screen **Star on Github** action.
- Added mirror URL normalization and stronger mirror selection handling.
- Added broad unit/widget test coverage across app routing, settings, home, webview, history, bookmarks, and services.

### Improved
- Synced font-size settings between Settings and WebView, including legacy preference handling.
- Improved WebView theme injection, CSS variables, interaction styling, and script/localStorage error handling.
- Improved article URL parsing and canonicalization for clipboard input, shared links, mirrors, bookmarks, history, and WebView navigation.
- Improved settings flows for mirrors, theme, timeout, update dialogs, and failed persistence operations.

### Fixed
- Fixed multiple WebView URL handling issues, including mirror paths, root mirror paths, article fragments, stale error state, and outbound navigation guards.
- Added safer error feedback for share, bookmark, history, clipboard, changelog, update, about, and external link actions.
- Fixed onboarding completion routing and active route tracking for shared links.
- Fixed stale mirror mutations, invalid saved mirrors, invalid history/bookmark entries, and saved-list search reset behavior.
- Fixed release lockfile compatibility for Flutter 3.44.x.

### Build / CI
- Release and CI now enforce locked dependencies.
- CI is pinned to Flutter stable `3.44.x`.
- Android build tooling/dependency updates, including WebView-related packages and Kotlin Gradle plugin pinning.

## [0.10.0] - 2026-05-02

### Added

- Local reading history support with offline persistence and improved tracking.
- Bookmarks feature with dedicated state/service layers and a bookmarks screen.
- First-run onboarding flow for new users.
- Article metadata extraction through a WebView JavaScript channel.
- Reusable `ArticleCard` UI component and shared date utilities.

### Changed

- Enhanced History and Bookmarks UX, including better filtering/search/sorting.
- Refactored `WebviewNotifier` to remove `BuildContext` anti-pattern usage.
- Improved WebView state handling and article history recording flow.
- Updated Android/build tooling configuration (AGP/SDK/NDK) and project dependencies.
- Updated release CI workflow to remove version bump commit/push steps.

### Fixed

- Corrected metadata extraction behavior for Freedium DOM.
- Fixed highlight.js theme injection behavior in WebView.
- Eliminated theme FOUC by injecting pre-theme script earlier (`onPageStarted`).
- Removed unnecessary WebView article meta overlay and polished onboarding visuals.
- Improved onboarding completion handling with explicit error feedback.

### Dependencies

- Flutter packages: `share_plus` to `13.0.0`, `shared_preferences` to `2.5.5`, `webview_flutter_android` to `4.11.0`.
- Android dependency: `com.google.android.material:material` to `1.14.0-beta01`.
- GitHub Actions: `actions/checkout` to `v6`, `actions/setup-java` to `v5`, `actions/cache` to `v5`, `actions/upload-artifact` to `v7`.

[0.10.0]: https://github.com/AmanSikarwar/freedium_mobile/compare/v0.9.0...v0.10.0
[0.11.0]: https://github.com/AmanSikarwar/freedium_mobile/compare/v0.10.0...v0.11.0
[0.12.0]: https://github.com/AmanSikarwar/freedium_mobile/compare/v0.11.0...v0.12.0
[0.13.0]: https://github.com/AmanSikarwar/freedium_mobile/compare/v0.12.0...v0.13.0
