# Freedium Mobile App

<p align="center"><a href="https://iosf.in/" target="_blank"><img src="https://avatars.githubusercontent.com/u/142643505?s=200&v=4" width="20%"></a></p>

<h1 align="center">Freedium - Your paywall breakthrough for Medium!</h1>

## Overview

Freedium is a mobile application designed to help you bypass Medium's paywall and access articles without restrictions. This app is built using Flutter and supports both Android and iOS platforms.

> This app opens Medium articles in [Freedium.cfd](https://freedium.cfd) to bypass the paywall.

## Features

- **Bypass Medium Paywall**: Access Medium articles without hitting the paywall.
- **Share and Receive Links**: Share Medium article links with the app and open them directly.
- **Clipboard Integration**: Easily paste Medium URLs from your clipboard.

## Installation

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK: Included with Flutter

### Steps

1. **Clone the repository**:

   ```sh
   git clone https://github.com/amansikarwar/freedium.git
   cd freedium
   ```

2. **Install dependencies**:

   ```sh
   flutter pub get
   ```

3. **Run the app**:

   ```sh
   flutter run
   ```

## Usage

1. **Enter Medium URL**: Open the app and paste the Medium article URL.
2. **Get Article**: Click on "Get Article" to bypass the paywall and read the article.
   Initially, we reverse-engineered Medium.com's GraphQL endpoints to show unpaywalled posts. Now, we pay for subscriptions and share access through Freedium.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgements

Thanks to [Freedium-cfd](https://freedium.cfd) for providing a way to bypass the Medium paywall.
