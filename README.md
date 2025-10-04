# Freedium Mobile

<p align="center">
   <img src="https://github.com/AmanSikarwar/freedium_mobile/blob/659ae7cee4d378c9a7e7decaa3199dd239cc2af1/assets/icon/icon.png?raw=true" alt="Freedium Mobile Logo" width="148px"/>
</p>

<p align="center">
    <a href="https://github.com/AmanSikarwar/freedium_mobile/blob/main/LICENSE"><img src="https://img.shields.io/github/license/AmanSikarwar/freedium_mobile?style=flat-square" alt="License"></a>
    <a href="https://github.com/AmanSikarwar/freedium_mobile/releases/latest"><img src="https://img.shields.io/github/v/release/AmanSikarwar/freedium_mobile?style=flat-square" alt="Latest Release"></a>
    <a href="https://github.com/AmanSikarwar/freedium_mobile/releases/latest"><img src="https://img.shields.io/github/downloads/AmanSikarwar/freedium_mobile/total?style=flat-square" alt="Downloads"></a>
    <a href="https://github.com/AmanSikarwar/freedium_mobile/stargazers"><img src="https://img.shields.io/github/stars/AmanSikarwar/freedium_mobile?style=flat-square" alt="Stars"></a>
</p>

<p align="center">
  <strong>Read Medium articles without a subscription</strong>
</p>

---

## Overview

Freedium Mobile is an Android application that bypasses Medium's paywall, allowing you to read member-only articles for free. The app redirects Medium articles through [Freedium.cfd](https://freedium.cfd) to provide unrestricted access.

Built with Flutter and featuring Material You design, Freedium Mobile offers a native reading experience with dynamic theming and dark mode support.

## App Demo

<!-- PLACEHOLDER: Add screen recording/GIF here -->
<div align="center">
  <video loop muted autoplay="True" width="300" src="https://github.com/user-attachments/assets/83e7bd99-aea1-4fc8-9672-c122a795572b
" </video>
</div>

---

## Features

**Paywall Bypass**  
Read any Medium article without hitting the paywall or needing a subscription.

**Share Integration**  
Share Medium articles directly to Freedium from other apps like Chrome, Twitter, or any browser.

**Clipboard Detection**  
Automatically detects Medium URLs in your clipboard for quick access.

**Material You Theming**  
Dynamic color schemes that adapt to your Android 12+ wallpaper.

**Dark Mode**  
Comfortable reading in any lighting condition with automatic or manual theme switching.

**Font Size Control**  
Adjust text size for better readability according to your preference.

**Pull to Refresh**  
Quickly reload articles with a simple pull-down gesture.

**Auto-Update Checker**  
Get notified when new versions are available with built-in update notifications.

---

## Installation

### Download

1. Go to the [Releases page](https://github.com/AmanSikarwar/freedium_mobile/releases/latest)
2. Download the latest APK file
3. Install on your Android device
4. Launch the app and start reading

**Note:** You may need to enable "Install from unknown sources" in your device settings.

### Usage

**Method 1: Paste URL**

1. Copy a Medium article URL
2. Open Freedium Mobile
3. The URL will be auto-detected in the input field
4. Tap "Read Article"

**Method 2: Share from Browser or App**

1. Open a Medium article in any browser or app
2. Tap the Share button
3. Select "Freedium" from the share menu
4. Article opens automatically

**Method 3: Manual Entry**

1. Open Freedium Mobile
2. Type or paste any Medium article URL
3. Tap "Read Article"

---

## Development

### Prerequisites

- Flutter SDK 3.27.0 or higher
- Dart SDK (included with Flutter)
- Android Studio or VS Code with Flutter extensions
- Git

### Setup

Clone the repository:

```bash
git clone https://github.com/AmanSikarwar/freedium_mobile.git
cd freedium_mobile
```

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

Output location: `build/app/outputs/flutter-apk/`

### Project Structure

```
lib/
├── app.dart                        # Main app configuration
├── main.dart                       # Entry point
├── core/
│   ├── constants/
│   │   └── app_constants.dart      # App constants
│   ├── services/
│   │   ├── clipboard_service.dart
│   │   ├── font_size_service.dart
│   │   ├── intent_service.dart     # Share handling
│   │   ├── theme_mode_service.dart
│   │   └── update_service.dart     # Update checking
│   └── theme/
│       ├── app_theme.dart
│       ├── theme_provider.dart
│       └── util.dart
└── features/
    ├── home/
    │   ├── application/
    │   │   └── home_provider.dart
    │   └── presentation/
    │       ├── home_screen.dart
    │       └── widgets/
    └── webview/
        ├── application/
        │   ├── theme_injector_service.dart  # Injects custom CSS
        │   └── webview_provider.dart
        ├── domain/
        │   └── webview_state.dart
        └── presentation/
            ├── webview_screen.dart
            └── widgets/
```

### Architecture

The app uses a simplified feature-based architecture with Riverpod 3.0 for state management:

- **Features**: Organized by functionality (home, webview)
- **Application layer**: Riverpod providers and business logic
- **Presentation layer**: UI screens and widgets
- **Domain layer**: State models
- **Core**: Shared services, constants, and theming

---

## Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following the existing code style
4. Test your changes on Android
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to your fork (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Guidelines

- Follow the existing code architecture and patterns
- Use Riverpod 3.0 Notifier API
- Test changes thoroughly on Android devices
- Keep pull requests focused on a single feature or fix
- Update documentation when adding new features

### Reporting Issues

Found a bug? [Open an issue](https://github.com/AmanSikarwar/freedium_mobile/issues/new) and include:

- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Device and Android version

---

## Privacy

Freedium Mobile respects your privacy:

- No personal data collection
- No analytics or tracking
- No ads
- No account required
- Settings stored locally on your device
- Open source and transparent

The app redirects articles through Freedium.cfd. Please review their privacy policy for information about their service.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Acknowledgements

- [Freedium.cfd](https://freedium.cfd) - For providing the paywall bypass service
- [Flutter](https://flutter.dev) - For the cross-platform framework
- [Riverpod](https://riverpod.dev) - For state management

---

## Support

- Report bugs: [GitHub Issues](https://github.com/AmanSikarwar/freedium_mobile/issues)

---

**Keywords:** Medium paywall bypass, read Medium free, Medium article reader, Android Medium app, Flutter app, open source, Medium subscription alternative, paywall remover, free Medium access

---

<p align="center">
  Made by <a href="https://github.com/AmanSikarwar">Aman Sikarwar</a>
</p>
