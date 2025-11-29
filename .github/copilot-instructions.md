# Freedium Mobile - Copilot Instructions

Flutter app that bypasses Medium paywalls via Freedium.cfd with Material You theming.

## Architecture

**Feature-Based Structure**:
- `lib/features/<feature>/presentation/` - UI screens and widgets
- `lib/features/<feature>/application/` - Riverpod providers and business logic  
- `lib/features/<feature>/domain/` - State models (e.g., `WebviewState`)
- `lib/core/` - Shared services, constants, themes

**Two Features**: `home/` (URL input) and `webview/` (article display with theme injection)

## Riverpod 3.0 Patterns (Critical)

Use `Notifier` API, NOT `StateNotifier`:
```dart
// Family provider with constructor injection
class WebviewNotifier extends Notifier<WebviewState> {
  final String url;
  WebviewNotifier(this.url);
  @override WebviewState build() => WebviewState();
}
final webviewProvider = NotifierProvider.family<WebviewNotifier, WebviewState, String>(WebviewNotifier.new);
```

**Provider Types**:
- `NotifierProvider.family` - URL-specific state (`webview_provider.dart`)
- `StreamProvider` - Intent handling (`intent_service.dart`)
- `FutureProvider` - Async operations (`dynamicThemeProvider`)
- `Provider` - Services (`themeInjectorServiceProvider`)

**State Updates**: Always use `copyWith()`:
```dart
state = state.copyWith(progress: progress / 100.0, isPageLoaded: true);
```

## WebView Theme Injection Pipeline

Three-stage Flutter-to-web theming:
1. `ThemeInjectorService.getThemeInjectionScript()` - Converts `ColorScheme` to CSS variables
2. `assets/js/theme.js` - Template with `%IS_DARK_MODE%`, `%CSS_VARS%`, `%CUSTOM_CSS_CONTENT%` placeholders
3. `assets/css/webview_styles.css` - Applies CSS custom properties to Freedium DOM

**Lifecycle**: `onWebViewCreated` → add JS handlers → `onLoadStop` → inject theme (Freedium URLs only)

**JS-Flutter Bridge**:
```dart
controller.addJavaScriptHandler(handlerName: 'themeApplied', callback: (args) => ...);
```

## Intent Handling (Share-to-App)

**Two-phase system**: Initial intent (`getInitialIntent()` on launch) + streaming intents (`intentStreamProvider` while running)

**Duplicate Prevention** (critical):
- Check route: `ModalRoute.of(context)?.settings.name?.startsWith('/webview/')`
- Reset after navigation: `ReceiveSharingIntent.instance.reset()`
- Always reset in `dispose()` and pop callbacks

## Navigation

**Global Navigator Key** for provider-initiated navigation:
```dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
navigatorKey.currentState?.push(...);  // From providers
```

**WebView Back Navigation**: Check `canGoBack()` in `PopScope.onPopInvokedWithResult` before popping

## Build Commands

```bash
flutter pub get              # Install dependencies
flutter run                  # Debug (WebView inspection enabled)
flutter build apk --release  # Production APK
dart format .                # Format code
```

**Debug Mode**: WebView inspection via `isInspectable: kDebugMode`

## Key Files

- `lib/app.dart` - App setup, intent handling, global navigator key
- `lib/core/constants/app_constants.dart` - `freediumUrl`, `urlRegExp`, `appVersion`
- `lib/features/webview/application/webview_provider.dart` - WebView lifecycle management
- `lib/features/webview/application/theme_injector_service.dart` - CSS variable generation
- `assets/js/theme.js` & `assets/css/webview_styles.css` - Theme injection templates

## Dependencies (pubspec.yaml)

- `flutter_riverpod: ^3.0.3` - State management (Riverpod 3.x)
- `flutter_inappwebview: ^6.1.5` - WebView with JS injection
- `listen_sharing_intent: ^1.9.2` - Share-to-app
- `dynamic_color: ^1.8.1` - Material You theming

## Patterns to Follow

1. **State**: Always `copyWith()` for immutability
2. **Errors**: Try-catch with graceful fallbacks (see `_injectTheme`)
3. **Navigation**: Check `context.mounted` before async navigation
4. **Intents**: Always reset via `ReceiveSharingIntent.instance.reset()` on disposal
5. **Theme injection**: Only for `freedium.cfd` URLs; external links open in system browser
6. **Logging**: Use `debugPrint()`, not `print()`