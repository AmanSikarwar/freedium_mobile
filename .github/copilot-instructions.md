# Freedium Mobile - Copilot Instructions

This Flutter app bypasses Medium paywalls by redirecting articles to Freedium.cfd. Key architecture and patterns:

## Core Architecture

**Simple Feature-Based Structure**: Unlike full Clean Architecture, this app uses a simplified approach:
- `lib/features/<feature>/presentation/` - UI screens and widgets  
- `lib/features/<feature>/application/` - Riverpod providers and business logic
- `lib/features/<feature>/domain/` - State models (e.g., `WebviewState`)
- `lib/core/` - Shared services, constants, themes

**Two Main Features**:
- `home/` - URL input and navigation to WebView (`HomeScreen`, `HomeNotifier`)
- `webview/` - WebView with dynamic theme injection for Freedium articles (`WebviewScreen`, `WebviewNotifier`)

## State Management: Riverpod 3.0

**Critical**: This project uses Riverpod 3.0 with the new `Notifier`-based API (NOT `StateNotifier`):
- Use `Notifier` instead of `StateNotifier` (no AutoDispose suffix needed)
- Family providers: `NotifierProvider.family<WebviewNotifier, WebviewState, String>(WebviewNotifier.new)`
- All provider refs are just `Ref` (no generic parameters like `WidgetRef` or `ProviderRef`)
- Constructor injection pattern: notifier receives parameters via constructor (e.g., `WebviewNotifier(this.url)`)

**Provider Types in Use**:
- `NotifierProvider.family` for URL-specific WebView state (see `webview_provider.dart`)
- `StreamProvider` for intent/sharing handling (`intentStreamProvider` in `intent_service.dart`)
- `FutureProvider` for async operations (`dynamicThemeProvider`, `updateCheckProvider`)  
- `Provider` for services (`themeInjectorServiceProvider`, `intentServiceProvider`)

**State Immutability**: All state objects use `copyWith()` for partial updates:
```dart
state = state.copyWith(progress: progress / 100.0);
```

## WebView Integration (Critical Pattern)

**Theme Injection System** - 3-stage pipeline from Flutter to web:
1. `ThemeInjectorService.getThemeInjectionScript()` converts Flutter `ColorScheme` to CSS custom properties
2. `assets/js/theme.js` template with `%IS_DARK_MODE%`, `%CSS_VARS%`, `%CUSTOM_CSS_CONTENT%` placeholders
3. `assets/css/webview_styles.css` applies custom properties to Freedium DOM elements

**String Replacement Pattern** (used in theme injection):
```dart
scriptTemplate
  .replaceFirst('%IS_DARK_MODE%', isDark.toString())
  .replaceFirst('%CSS_VARS%', cssVars.replaceAll("'", r"\'").replaceAll("\n", r'\n'))
  .replaceFirst('%CUSTOM_CSS_CONTENT%', customCSSContent.replaceAll("'", r"\'").replaceAll("\n", r'\n'))
```

**WebView Lifecycle Management**:
- `onWebViewCreated()` → add JavaScript handlers (`themeApplied`, `Toaster`)
- `onLoadStop()` → inject theme script for Freedium URLs only
- `onProgressChanged()` → update loading progress (0.0 to 1.0)
- `shouldOverrideUrlLoading()` → reset state flags, open external URLs in system browser

**JavaScript-to-Flutter Communication**:
```dart
controller.addJavaScriptHandler(
  handlerName: 'themeApplied',
  callback: (args) => state = state.copyWith(isThemeApplied: true)
);
```

## Intent Handling (Share-to-App Flow)

**Two-Phase Intent System**:
1. **Initial intent** (`getInitialIntent()` in `app.dart`): Handles URL when app launches from share
2. **Streaming intents** (`intentStreamProvider`): Handles URLs while app is already running

**Duplicate Prevention Pattern** (critical):
- Check route name: `ModalRoute.of(context)?.settings.name?.startsWith('/webview/')` 
- Reset intent after navigation: `ReceiveSharingIntent.instance.reset()`
- Use `RouteSettings(name: '/webview/$url')` for route identification

## Navigation Patterns

**Global Navigator Key** for provider-initiated navigation:
```dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// In app.dart: MaterialApp(navigatorKey: navigatorKey, ...)
// In providers: navigatorKey.currentState?.push(...)
```

**PopScope Handling** (`webview_screen.dart`):
- Check `canGoBack()` before popping to handle WebView back navigation
- Set visibility to false before navigation: `setState(() => _isVisible = false)`
- Always reset intent: `ReceiveSharingIntent.instance.reset()` in disposal/pop callbacks

## Asset Loading & Template Substitution

**Bundle Asset Pattern** (`ThemeInjectorService`):
```dart
final scriptTemplate = await rootBundle.loadString('assets/js/theme.js');
final customCSS = await rootBundle.loadString('assets/css/webview_styles.css');
// Replace placeholders with runtime values
```

**Asset Declaration** (pubspec.yaml):
```yaml
flutter:
  assets:
    - assets/icon/
    - assets/js/
    - assets/css/
```

## Dynamic Theming (Material You)

**Graceful Fallback Pattern** (`theme_provider.dart`):
```dart
final corePalette = await DynamicColorPlugin.getCorePalette();
if (corePalette != null) {
  lightColorScheme = corePalette.toColorScheme();
} else {
  lightColorScheme = appTheme.light().colorScheme; // fallback
}
```

## Error Handling Patterns

**WebView Error Recovery** (`webview_provider.dart`):
- `onReceivedError`: Reset progress, log error, continue gracefully
- `onRenderProcessGone`: Show snackbar, offer reload option
- Theme injection: Wrapped in try-catch with fallback to `isThemeApplied: true`

**JavaScript Error Isolation**: Theme application continues even if script injection fails

## Build & Development

**Environment Setup**:
```bash
flutter pub get              # Install dependencies
flutter run                  # Debug mode (enables WebView inspection)
flutter build apk --release  # Production APK
dart format .                # Format code (no specific line length)
```

**Android-Specific**:
- Min SDK: 21 (from `pubspec.yaml`)
- Compile SDK: Managed by Flutter plugin
- Signing: `key.properties` file with keystore credentials (see `build.gradle.kts`)
- Material 3: `com.google.android.material:material:1.14.0-alpha04`

**Debug Mode Features**:
- WebView inspection: `isInspectable: kDebugMode` in `webview_screen.dart`
- Use `debugPrint()` for logging (not `print()`)

**App Constants** (`app_constants.dart`):
- `freediumUrl`: Base URL for theme injection checks
- `urlRegExp`: Validation regex for URL inputs
- `appVersion`: Uses `String.fromEnvironment('APP_VERSION', defaultValue: '0.4.0')`

## Key Dependencies

- `flutter_riverpod: ^3.0.0` - State management (Riverpod 3.x syntax)
- `flutter_inappwebview: ^6.1.5` - WebView with JS injection
- `listen_sharing_intent: ^1.9.2` - Share-to-app functionality
- `dynamic_color: ^1.8.1` - Material You theming
- `share_plus: ^12.0.0` - Share from app
- `flutter_lints: ^6.0.0` - Standard Effective Dart rules

## Common Patterns to Follow

1. **State updates**: Always use `copyWith()` for immutable state changes
2. **Async operations**: Wrap in try-catch with fallback behavior
3. **Navigation**: Use global `navigatorKey` from providers, check `context.mounted`
4. **WebView lifecycle**: Always reset intent on disposal (`ReceiveSharingIntent.instance.reset()`)
5. **Theme injection**: Only for `freedium.cfd` URLs, external links open in system browser
6. **Provider initialization**: Use `.new` constructor reference syntax (Riverpod 3.0)