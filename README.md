# Freedium Mobile

<p align="center">
   <img src="https://github.com/AmanSikarwar/freedium_mobile/blob/main/assets/icon/icon.png?raw=true" alt="Freedium Mobile Logo" width="148px"/>
</p>

<p align="center">
    <a href="https://github.com/AmanSikarwar/freedium_mobile/blob/main/LICENSE"><img src="https://img.shields.io/github/license/AmanSikarwar/freedium_mobile?style=flat-square" alt="License"></a>
    <a href="https://github.com/AmanSikarwar/freedium_mobile/releases/latest"><img src="https://img.shields.io/github/v/release/AmanSikarwar/freedium_mobile?style=flat-square" alt="Latest Release"></a>
    <a href="https://github.com/AmanSikarwar/freedium_mobile/releases/latest"><img src="https://img.shields.io/github/downloads/AmanSikarwar/freedium_mobile/total?style=flat-square" alt="Downloads"></a>
    <a href="https://github.com/AmanSikarwar/freedium_mobile/stargazers"><img src="https://img.shields.io/github/stars/AmanSikarwar/freedium_mobile?style=flat-square" alt="Stars"></a>
    <img src="https://img.shields.io/badge/Flutter-3.27+-02569B?style=flat-square&logo=flutter" alt="Flutter">
    <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android" alt="Android">
</p>

<p align="center">
  <strong>Read Medium articles without a subscription</strong>
</p>

<p align="center">
  <em>Your paywall breakthrough for Medium!</em>
</p>

---

## Overview

Freedium Mobile is an Android application that bypasses Medium's paywall, allowing you to read member-only articles for free. The app redirects Medium articles through [Freedium.cfd](https://freedium.cfd) to provide unrestricted access.

Built with **Flutter** and featuring **Material You** design, Freedium Mobile offers a native reading experience with dynamic theming and dark mode support.

## Demo

<div align="center">
  <video loop muted autoplay="True" width="300" src="https://github.com/user-attachments/assets/83e7bd99-aea1-4fc8-9672-c122a795572b"></video>
</div>

---

## Features

- **Paywall Bypass** - Read any Medium article without hitting the paywall or needing a subscription
- **Share Integration** - Share Medium articles directly to Freedium from Chrome, Twitter, or any browser
- **Clipboard Detection** - Automatically detects Medium URLs in your clipboard for quick access
- **Configurable Mirrors** - Multiple Freedium server mirrors with automatic failover
- **Material You Theming** - Dynamic color schemes that adapt to your Android 12+ wallpaper
- **Dark Mode** - Comfortable reading with automatic or manual theme switching
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

1. Copy a Medium article URL
2. Open Freedium Mobile
3. The URL will be auto-detected in the input field
4. Tap **"Read Article"**

</details>

<details>
<summary><strong>Method 2: Share from Browser or App</strong></summary>

1. Open a Medium article in any browser or app
2. Tap the **Share** button
3. Select **"Freedium"** from the share menu
4. Article opens automatically

</details>

<details>
<summary><strong>Method 3: Manual Entry</strong></summary>

1. Open Freedium Mobile
2. Type or paste any Medium article URL
3. Tap **"Read Article"**

</details>

---

## Development

### Prerequisites

- **Flutter SDK** 3.27.0 or higher
- **Dart SDK** 3.10.0 or higher (included with Flutter)
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
│   │   └── app_constants.dart        # freediumUrl, urlRegExp, appVersion
│   ├── services/
│   │   ├── clipboard_service.dart    # Clipboard URL detection
│   │   ├── font_size_service.dart    # Font size persistence
│   │   ├── intent_service.dart       # Share-to-app handling
│   │   ├── theme_mode_service.dart   # Theme persistence
│   │   └── update_service.dart       # GitHub release checker
│   └── theme/
│       ├── app_theme.dart            # Material You theme config
│       ├── theme_provider.dart       # Dynamic color provider
│       └── util.dart                 # Theme utilities
└── features/
    ├── home/
    │   ├── application/
    │   │   └── home_provider.dart    # Home state management
    │   └── presentation/
    │       ├── home_screen.dart
    │       └── widgets/
    ├── settings/
    │   ├── application/
    │   │   └── settings_provider.dart   # Settings state & mirror management
    │   ├── domain/
    │   │   └── settings_state.dart      # Settings & FreediumMirror models
    │   └── presentation/
    │       └── settings_screen.dart
    └── webview/
        ├── application/
        │   ├── theme_injector_service.dart  # CSS injection for theming
        │   └── webview_provider.dart        # WebView controller & state
        ├── domain/
        │   └── webview_state.dart
        └── presentation/
            ├── webview_screen.dart
            └── widgets/
```

### Architecture

The app follows a **feature-based architecture** with **Riverpod 3.0** for state management:

- **Features** - Organized by functionality (`home`, `settings`, `webview`)
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
    <strong>Keywords:</strong> Medium paywall bypass, read Medium free, Medium article reader, Android Medium app, Flutter app, open source, Medium subscription alternative, paywall remover, free Medium access
  </sub>
</p>
