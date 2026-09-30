import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'MainActivity opts out of Flutter deep linking for receive_intent',
    () async {
      final manifest = await File('android/app/src/main/AndroidManifest.xml')
          .readAsString();
      final activity = RegExp(r'<activity\b[^>]*>([\s\S]*?)</activity>')
          .firstMatch(manifest)!
          .group(1)!;
      expect(
        activity,
        contains(
          'android:name="flutter_deeplinking_enabled" android:value="false"',
        ),
      );
    },
  );

  test('Android opens links from every supported publisher', () async {
    final manifest = await File('android/app/src/main/AndroidManifest.xml')
        .readAsString();
    const hosts = [
      'medium.com',
      'nytimes.com',
      'washingtonpost.com',
      'bloomberg.com',
      'reuters.com',
      'economist.com',
      'ft.com',
    ];

    for (final host in hosts) {
      expect(manifest, contains('android:host="$host"'));
    }
  });
}
