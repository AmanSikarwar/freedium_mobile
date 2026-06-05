# Changelog

All notable changes to this project will be documented in this file.

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
