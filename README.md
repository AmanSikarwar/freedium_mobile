# Freedium Mobile App

<p align="center">
   <img src="https://avatars.githubusercontent.com/u/142643505?s=200&v=4" alt="Freedium Logo"/>
</p>

## Overview

Freedium is a mobile application designed to help you bypass Medium's paywall and access articles without restrictions. This app is built using Flutter and provides a seamless reading experience on both Android and iOS platforms.

> This app opens Medium articles in [Freedium.cfd](https://freedium.cfd) to bypass the paywall.

## Features

- **Paywall Bypass**: Access Medium articles without hitting the member-only paywall
- **Cross-Platform**: Works on both Android and iOS devices
- **Share Integration**: Share articles directly to Freedium from other apps
- **Clipboard Support**: Quickly paste URLs from your clipboard
- **Dynamic Theming**: Supports light/dark mode and Material You theming

## Getting Started

### For Users

1. Download the app from [releases page](https://github.com/AmanSikarwar/freedium_mobile/releases/latest)
2. Launch Freedium
3. Paste a Medium article URL or share directly to the app
4. Enjoy reading without restrictions!

### For Developers

#### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK: Included with Flutter
- Android Studio or VS Code with Flutter extensions

#### Setup

1. **Clone the repository**:

   ```sh
   git clone https://github.com/amansikarwar/freedium_mobile.git
   cd freedium_mobile
   ```

2. **Install dependencies**:

   ```sh
   flutter pub get
   ```

3. **Run the app**:

   ```sh
   flutter run
   ```

#### Building

- For Android:

  ```sh
  flutter build apk --release
  ```

- For iOS:

  ```sh
  flutter build ios --release
  ```

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Freedium.cfd](https://freedium.cfd) for providing the paywall bypass service
