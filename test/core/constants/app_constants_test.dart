import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/utils/external_url_launcher.dart';

void main() {
  group('AppConstants', () {
    test('points user-facing source links to the release repository', () {
      expect(
        AppConstants.appSourceUrl,
        'https://github.com/AmanSikarwar/freedium_mobile',
      );
      expect(
        parseExternalHttpUrl(AppConstants.appSourceUrl),
        Uri.parse('https://github.com/AmanSikarwar/freedium_mobile'),
      );
    });

    test('uses the Android application id as package name', () {
      expect(
        AppConstants.appPackageName,
        'io.github.amansikarwar.freedium_mobile',
      );
    });
  });
}
