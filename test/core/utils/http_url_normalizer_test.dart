import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/utils/url.dart';
import '../../test_helpers.dart';

void main() {
  group('normalizeHttpUrl', () {
    test('normalizes casing and repeated trailing slashes', () {
      expect(
        normalizeHttpUrl(' HTTPS://Medium.COM/example/story/// '),
        TestFixtures.storyUrl,
      );
    });

    test('normalizes root paths without leaving a slash', () {
      expect(normalizeHttpUrl('https://medium.com///'), 'https://medium.com');
    });
  });
}
