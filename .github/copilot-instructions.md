# Freedium Mobile - Copilot Instructions

Flutter Android app bypassing Medium paywalls via Freedium.cfd with Material You theming.

## Architecture

**Feature-Based Structure** (`lib/`):
```
features/<feature>/
  presentation/  # Screens, widgets (ConsumerStatefulWidget)
  application/   # Riverpod providers, notifiers
  domain/        # State classes with copyWith()
core/
  services/      # Shared services (clipboard, intent, font_size, update)
  theme/         # AppTheme, theme_provider, util
  constants/     # AppConstants (freediumUrl, urlRegExp, appVersion)
```

**Three Features**: 
- `home/` - URL input form
- `webview/` - article display with theme injection
- `settings/` - app settings, theme, mirrors configuration

## Riverpod Patterns (Critical)

Use **Notifier API** (Riverpod 3.x), NOT StateNotifier:
```dart
// Family provider for URL-specific state
class WebviewNotifier extends Notifier<WebviewState> {
  final String url;
  WebviewNotifier(this.url);
  @override WebviewState build() => WebviewState();
}
final webviewProvider = NotifierProvider.family<WebviewNotifier, WebviewState, String>(WebviewNotifier.new);

// Simple notifier
class HomeNotifier extends Notifier<HomeState> {
  @override HomeState build() => HomeState(...);
}
final homeProvider = NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

// Settings provider with persistence
class SettingsNotifier extends Notifier<SettingsState> {
  @override SettingsState build() => _loadFromPrefs();
}
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
```

**Provider Types Used**:
- `NotifierProvider.family` → URL-specific state (`webviewProvider`)
- `NotifierProvider` → Singleton state (`homeProvider`, `settingsProvider`)
- `StreamProvider` → Intent stream (`intentStreamProvider`)
- `FutureProvider` → Async init (`dynamicThemeProvider`, `activeFreediumUrlProvider`)
- `Provider` → Services (`intentServiceProvider`, `clipboardServiceProvider`, `freediumUrlServiceProvider`)

**State Updates**: Always `copyWith()` for immutability:
```dart
state = state.copyWith(progress: progress / 100.0, isPageLoaded: true);
```

## Settings & Configurable Mirrors

**Settings Feature** (`features/settings/`):
- `SettingsState` - theme mode, font size, mirror list, auto-switch, timeout
- `SettingsService` - SharedPreferences persistence
- `SettingsNotifier` - state management with persistence
- `FreediumUrlService` - mirror testing and auto-switching

**Configurable Mirrors**:
```dart
// Default mirrors from AppConstants
static List<FreediumMirror> get defaultMirrors => [
  FreediumMirror(name: 'Freedium (Primary)', url: freediumUrl, isDefault: true),
  FreediumMirror(name: 'Freedium Mirror', url: freediumMirrorUrl, isDefault: true),
];

// Custom mirrors can be added by user
FreediumMirror(name: 'Custom', url: 'https://...', isCustom: true);
```

**Auto-Switch Logic** (when mirror fails):
1. WebView gets `onWebResourceError` → `_handleLoadError()`
2. If `autoSwitchMirror` enabled and retries remain, try next mirror
3. Show snackbar with mirror name being tried
4. On success, reset retry count; on exhaustion, show error UI

## WebView Theme Injection Pipeline

Three-stage Flutter→Web theming:
1. `ThemeInjectorService.getThemeInjectionScript()` converts `ColorScheme` to CSS variables
2. `assets/js/theme.js` template with `%IS_DARK_MODE%`, `%CSS_VARS%`, `%CUSTOM_CSS_CONTENT%` placeholders
3. `assets/css/webview_styles.css` applies `--app-*` CSS custom properties to Freedium DOM

**WebView Lifecycle** (`webview_provider.dart`):
```dart
// 1. Create controller with JS channels
controller.addJavaScriptChannel('themeApplied', onMessageReceived: ...);
// 2. NavigationDelegate.onPageFinished → inject theme (freedium URLs only)
// 3. External links → launchUrl() with LaunchMode.externalApplication
// 4. onWebResourceError → try next mirror if auto-switch enabled
```

**URL Handling**: Only Freedium URLs (from configured mirrors) navigate in WebView; others open system browser.

## Intent Handling (Share-to-App)

**Two-phase system** (`lib/app.dart`, `intent_service.dart`):
- **Initial**: `getInitialIntent()` on app launch (with 400ms delay for UI ready)
- **Streaming**: `intentStreamProvider` for intents while app is running

**Duplicate Prevention** (critical):
```dart
// Check if already on webview route before navigating
final isCurrentlyOnWebview = currentRoute?.settings.name?.startsWith('/webview/') ?? false;
// Always reset after navigation and in dispose()
ReceiveSharingIntent.instance.reset();
```

## Navigation

**Global Navigator Key** (`lib/app.dart`) for provider-initiated navigation:
```dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
navigatorKey.currentState?.push(...);  // From providers/listeners
```

**WebView Back Handling** (`PopScope.onPopInvokedWithResult`):
1. Check `canGoBack()` → call `goBack()` if true
2. Otherwise `navigator.pop()` or `pushReplacement(HomeScreen)`

## Build Commands

```bash
flutter pub get              # Install dependencies
flutter run                  # Debug (WebView debugging enabled via kDebugMode)
flutter build apk --release  # Production APK
dart format .                # Format code
```

**Debug WebView**: Auto-enabled via `AndroidWebViewController.enableDebugging(kDebugMode)`

## Key Files Reference

| File | Purpose |
|------|---------|
| `lib/app.dart` | App widget, intent handling, global navigator key |
| `lib/core/constants/app_constants.dart` | `freediumUrl`, `urlRegExp`, `appVersion` |
| `lib/features/webview/application/webview_provider.dart` | WebView lifecycle, theme injection trigger |
| `lib/features/webview/application/theme_injector_service.dart` | ColorScheme→CSS generation |
| `lib/features/settings/application/settings_provider.dart` | Settings state, FreediumUrlService |
| `lib/features/settings/presentation/settings_screen.dart` | Settings UI with mirror management |
| `assets/js/theme.js` | JS theme injection template |
| `assets/css/webview_styles.css` | CSS overrides for Freedium DOM |

## Patterns to Follow

1. **State**: Always `copyWith()`, never mutate directly
2. **Errors**: Try-catch with `debugPrint()` fallbacks (see `_injectTheme`)
3. **Navigation**: Check `context.mounted` before async navigation
4. **Intents**: Always `ReceiveSharingIntent.instance.reset()` on disposal
5. **Theme injection**: Only for configured Freedium mirror URLs
6. **Logging**: Use `debugPrint()`, not `print()`
7. **Widgets**: Use `ConsumerStatefulWidget` for stateful screens needing `ref`