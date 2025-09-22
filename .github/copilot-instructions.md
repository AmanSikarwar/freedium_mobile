# Freedium Mobile - Copilot Instructions

This Flutter app bypasses Medium paywalls by redirecting articles to Freedium.cfd. Key architecture and patterns:

## Core Architecture

**Simple Feature-Based Structure**: Unlike full Clean Architecture, this app uses a simplified approach:
- `lib/features/<feature>/presentation/` - UI screens and widgets  
- `lib/features/<feature>/application/` - Riverpod providers and business logic
- `lib/features/<feature>/domain/` - State models (e.g., `WebviewState`)
- `lib/core/` - Shared services, constants, themes

**Two Main Features**:
- `home/` - URL input and navigation to WebView
- `webview/` - WebView with dynamic theme injection for Freedium articles

## State Management: Riverpod 3.0

**Current Provider Patterns**: This project uses Riverpod 3.0 with the new `Notifier`-based API:
- Use `Notifier` instead of `StateNotifier` (no AutoDispose suffix needed)
- Family providers use `NotifierProvider.family<WebviewNotifier, WebviewState, String>`
- All provider refs are now just `Ref` (no generic parameters)
- Constructor-based notifier initialization with `WebviewNotifier.new`

**Provider Types Used**:
- `NotifierProvider.family` for URL-specific WebView state
- `StreamProvider` for intent/sharing handling (`intentStreamProvider`)
- `FutureProvider` for async operations (`dynamicThemeProvider`, `updateCheckProvider`)  
- `Provider` for services (`themeInjectorServiceProvider`, `intentServiceProvider`)

**Key Provider Examples**:
```dart
// Family provider for URL-specific WebView state  
final webviewProvider = NotifierProvider.family<WebviewNotifier, WebviewState, String>(WebviewNotifier.new);

// Stream for handling shared URLs from other apps
final intentStreamProvider = StreamProvider<String>((ref) { ... });
```

## WebView Integration Patterns

**Theme Injection System**: The app dynamically injects Flutter's Material theme into Freedium webpages:
- `ThemeInjectorService` converts Flutter `ColorScheme` to CSS custom properties (e.g., `--app-primary`, `--app-surface`)
- `assets/js/theme.js` template with `%placeholders%` for dynamic values (theme mode, CSS vars, custom styles)
- `assets/css/webview_styles.css` contains Freedium-specific styling using CSS custom properties
- Theme injection only occurs for `freedium.cfd` URLs; external links open in system browser

**WebView State Management**:
- `WebviewState` tracks loading progress, theme application status, and controller instance
- JavaScript handlers (`themeApplied`, `Toaster`) enable webpage-to-app communication via `addJavaScriptHandler`
- Use `ref.listen()` pattern for navigation and lifecycle management in `app.dart`
- Constructor injection pattern: `WebviewNotifier(this.url)` with URL as constructor parameter

**Intent Handling**: App processes shared URLs from other apps via `listen_sharing_intent`:
- `IntentService` wraps the plugin in Riverpod providers for reactive stream handling
- `app.dart` handles both initial intents and streaming intents with duplicate prevention logic
- Navigation uses route name checking (`/webview/$url`) to prevent duplicate WebView instances

## Key Development Patterns

**Navigation**: Global `navigatorKey` for programmatic navigation from providers:
```dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// Use in providers: navigatorKey.currentState?.push(...)
```

**Asset Loading**: Bundle JavaScript/CSS files are loaded via `rootBundle.loadString()` in `ThemeInjectorService`:
- Template substitution pattern: replace `%placeholders%` in loaded assets with runtime values
- CSS custom properties bridge Flutter theme to web content

**Dynamic Theming**: Uses `dynamic_color` package for Material You support with graceful fallback:
- `DynamicColorPlugin.getCorePalette()` for system color extraction
- Fallback to default Material 3 theme when dynamic colors unavailable

**State Immutability**: All state objects use `copyWith()` pattern for updates with partial field updates

**WebView Configuration**: Comprehensive `InAppWebViewSettings` in `webview_screen.dart`:
- JavaScript enabled with debug-only inspection
- Hybrid composition for performance, cache enabled for efficiency
- Security: disabled file access, mixed content compatibility mode

## Build & Development

**Dependencies**: 
- Core: `flutter_riverpod: ^3.0.0`, `flutter_inappwebview: ^6.1.5`
- Platform: `listen_sharing_intent`, `dynamic_color`, `share_plus`
- Tooling: `flutter_lints: ^6.0.0` (standard Effective Dart rules)

**Commands**:
- `flutter pub get` - Install dependencies
- `flutter run` - Run in debug mode  
- `flutter build apk --release` - Build Android APK
- `dart format .` - Format code (no specific line length configured)

**Debug Patterns**:
- WebView inspection enabled in debug mode via `isInspectable: kDebugMode`
- `debugPrint()` for error logging (theme injection failures, WebView crashes)
- JavaScript error handling with graceful fallbacks (theme application continues on script errors)

**Error Handling**: Comprehensive WebView error management in `webview_provider.dart`:
- `onReceivedError`: Network/loading failures with progress reset
- `onRenderProcessGone`: Renderer crashes with user notification and reload option
- Theme injection wrapped in try-catch with fallback success state

**App Constants**: Centralized in `lib/core/constants/app_constants.dart` (Freedium URL, app info, regex patterns)