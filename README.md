# Freedium Mobile

<p align="center">
   <img src="https://github.com/AmanSikarwar/freedium_mobile/blob/main/assets/icon/icon.png?raw=true" alt="Freedium Mobile Logo" width="148px"/>
</p>

<p align="center">
    <a href="https://github.com/AmanSikarwar/freedium_mobile/blob/main/LICENSE"><img src="https://img.shields.io/github/license/AmanSikarwar/freedium_mobile?style=flat-square" alt="License"></a>
    <a href="https://github.com/AmanSikarwar/freedium_mobile/releases/latest"><img src="https://img.shields.io/github/v/release/AmanSikarwar/freedium_mobile?style=flat-square" alt="Latest Release"></a>
    <a href="https://github.com/AmanSikarwar/freedium_mobile/releases/latest"><img src="https://img.shields.io/github/downloads/AmanSikarwar/freedium_mobile/total?style=flat-square" alt="Downloads"></a>
    <a href="https://github.com/AmanSikarwar/freedium_mobile/stargazers"><img src="https://img.shields.io/github/stars/AmanSikarwar/freedium_mobile?style=flat-square" alt="Stars"></a>
    <img src="https://img.shields.io/badge/Flutter-3.44+-02569B?style=flat-square&logo=flutter" alt="Flutter">
    <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android" alt="Android">
</p>

<p align="center">
  <strong>Read articles from seven leading publishers without a subscription</strong>
</p>

<p align="center">
  <em>Medium, NYT, WaPo, Bloomberg, Reuters, The Economist, and Financial Times</em>
</p>

---

## Overview

Freedium Mobile is an Android reader for paywalled articles from Medium, The New York Times, The Washington Post, Bloomberg, Reuters, The Economist, and Financial Times. It sends supported article links through [Freedium.cfd](https://freedium.cfd) and presents the result in a native reading experience.

Built with **Flutter** and featuring **Material You** design, Freedium Mobile offers a native reading experience with dynamic theming and dark mode support.

## Supported Sources

- **Medium**, including many custom publication domains
- **The New York Times**
- **The Washington Post**
- **Bloomberg**
- **Reuters**
- **The Economist**
- **Financial Times**

## Demo

<div align="center">
  <video loop muted autoplay="True" width="300" src="https://github.com/user-attachments/assets/83e7bd99-aea1-4fc8-9672-c122a795572b"></video>
</div>

---

## Features

- **Seven Supported Sources** - Read articles from Medium, NYT, WaPo, Bloomberg, Reuters, The Economist, and Financial Times
- **Share and Open With** - Share or open supported links directly in Freedium from Android browsers and apps
- **Clipboard Detection** - Automatically detects article URLs in your clipboard for quick access
- **Continue Reading** - Resume unfinished articles from the home screen at your saved reading position
- **Bookmarks** - Save articles locally and search or manage them from the Bookmarks screen
- **Reading History** - Track article progress, completion state, and recently opened stories locally
- **Configurable Mirrors** - Multiple Freedium server mirrors with automatic failover
- **Material You Theming** - Dynamic app colors and matching light or dark article styling
- **Site Popup Control** - Optionally hide Freedium announcement popups while reading
- **Font Size Control** - Adjust text size for better readability
- **Auto-Update Checker** - Get notified when new versions are available

---

## Installation

### Quick Install

1. Go to the [**Releases page**](https://github.com/AmanSikarwar/freedium_mobile/releases/latest)
2. Download the latest APK file
3. Install on your Android device
4. Launch the app and start reading!

> **Note:** You may need to enable "Install from unknown sources" in your device settings.

### How to Use

<details>
<summary><strong>Method 1: Paste URL (Recommended)</strong></summary>

1. Copy a supported article URL
2. Open Freedium Mobile
3. The URL will be auto-detected in the input field
4. Tap **"Read Article"**

</details>

<details>
<summary><strong>Method 2: Share from Browser or App</strong></summary>

1. Open a supported article in any browser or app
2. Tap the **Share** button
3. Select **"Freedium"** from the share menu
4. Article opens automatically

</details>

<details>
<summary><strong>Method 3: Manual Entry</strong></summary>

1. Open Freedium Mobile
2. Type or paste a supported article URL
3. Tap **"Read Article"**

</details>

---

## Development

### Prerequisites

- **Flutter SDK** 3.44.0 or higher
- **Dart SDK** 3.12.0 or higher (included with Flutter)
- Android Studio or VS Code with Flutter extensions
- Git

### Quick Start

```bash
# Clone the repository
git clone https://github.com/AmanSikarwar/freedium_mobile.git
cd freedium_mobile

# Install dependencies
flutter pub get

flutter run
```

### Build Commands

```bash
# Debug build
flutter run

# Release APK
flutter build apk --release

# Release APK with obfuscation (recommended for production)
flutter build apk --release --obfuscate --split-debug-info=obfuscate

# Format code
dart format .

# Analyze code
flutter analyze
```

> **Output location:** `build/app/outputs/flutter-apk/`

### Project Structure

```
lib/
├── app.dart                          # App widget, intent handling, global navigator
├── main.dart                         # Entry point
├── core/
│   ├── constants/
│   │   └── app_constants.dart        # App metadata, package name, default mirrors
│   ├── services/
│   │   ├── clipboard_service.dart    # Clipboard URL detection
│   │   ├── font_size_service.dart    # Font size persistence
│   │   ├── intent_service.dart       # Share-to-app handling
│   │   └── update_service.dart       # GitHub release checker
│   ├── theme/
│   │   ├── app_theme.dart            # Material You theme config
│   │   ├── theme_provider.dart       # Dynamic color provider
│   │   └── util.dart                 # Theme utilities
│   └── utils/
│       ├── article_url_parser.dart   # Shared URL extraction
│       ├── external_url_launcher.dart
│       └── http_url_normalizer.dart
├── features/
│   ├── bookmarks/
│   │   ├── application/
│   │   │   ├── bookmarks_provider.dart
│   │   │   └── bookmarks_service.dart
│   │   ├── domain/
│   │   │   └── bookmarked_article.dart
│   │   └── presentation/
│   │       └── bookmarks_screen.dart
│   ├── history/
│   │   ├── application/
│   │   │   ├── history_provider.dart
│   │   │   └── history_service.dart
│   │   ├── domain/
│   │   │   └── reading_history.dart
│   │   └── presentation/
│   │       └── history_screen.dart
│   ├── home/
│   │   ├── application/
│   │   │   └── home_provider.dart    # Home state management
│   │   ├── domain/
│   │   │   └── home_state.dart
│   │   └── presentation/
│   │       ├── home_screen.dart
│   │       └── widgets/
│   ├── onboarding/
│   │   ├── application/
│   │   │   └── onboarding_provider.dart
│   │   └── presentation/
│   │       └── onboarding_screen.dart
│   ├── settings/
│   │   ├── application/
│   │   │   ├── settings_service.dart
│   │   │   └── settings_provider.dart   # Settings state & mirror management
│   │   ├── domain/
│   │   │   └── settings_state.dart      # Settings & FreediumMirror models
│   │   └── presentation/
│   │       └── settings_screen.dart
│   └── webview/
│       ├── application/
│       │   ├── freedium_article_url_builder.dart
│       │   ├── initial_mirror_resolver.dart
│       │   ├── theme_injector_service.dart  # CSS injection for theming
│       │   └── webview_provider.dart        # WebView controller & state
│       ├── domain/
│       │   └── webview_state.dart
│       └── presentation/
│           ├── webview_screen.dart
│           └── widgets/
└── shared/
    ├── utils/
    │   └── date_utils.dart
    └── widgets/
        └── article_card.dart
```

### Architecture

The app follows a **feature-based architecture** with **Riverpod 3.0** for state management:

- **Features** - Organized by functionality (`bookmarks`, `history`, `home`, `onboarding`, `settings`, `webview`)
- **Application** - Riverpod Notifiers and business logic
- **Presentation** - UI screens and widgets
- **Domain** - State classes with `copyWith()`
- **Core** - Shared services, constants, and theming

#### Key Patterns

- **State Management:** Riverpod 3.x Notifier API (not StateNotifier)
- **Theme Injection:** Flutter → CSS variables → WebView DOM
- **Intent Handling:** Two-phase (initial + streaming) with duplicate prevention

---

## Contributing

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Make** your changes following the existing code style
4. **Test** your changes on Android devices
5. **Commit** with clear messages (`git commit -m 'Add amazing feature'`)
6. **Push** to your fork (`git push origin feature/amazing-feature`)
7. **Open** a Pull Request

### Development Guidelines

- Follow the existing code architecture and patterns
- Use **Riverpod 3.0 Notifier API** for state management
- Always use `copyWith()` for state updates
- Use `debugPrint()` instead of `print()` for logging
- Test changes thoroughly on Android devices
- Keep pull requests focused on a single feature or fix

### Reporting Issues

Found a bug? [Open an issue](https://github.com/AmanSikarwar/freedium_mobile/issues/new) with:

- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Device model and Android version

---

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## Support

- **Report bugs:** [GitHub Issues](https://github.com/AmanSikarwar/freedium_mobile/issues)
- **Star this repo** if you find it useful!

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/AmanSikarwar">Aman Sikarwar</a>
</p>

<p align="center">
  <sub>
    <strong>Keywords:</strong> Freedium Android, Medium reader, NYT reader, Washington Post reader, Bloomberg reader, Reuters reader, Economist reader, Financial Times reader, Flutter app, open source article reader
  </sub>
</p>
