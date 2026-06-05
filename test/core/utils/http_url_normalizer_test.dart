import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/utils/http_url_normalizer.dart';

void main() {
  group('normalizeHttpUrl', () {
    test('normalizes casing and repeated trailing slashes', () {
      expect(
        normalizeHttpUrl(' HTTPS://Medium.COM/example/story/// '),
        'https://medium.com/example/story',
      );
    });

    test('normalizes root paths without leaving a slash', () {
      expect(normalizeHttpUrl('https://medium.com///'), 'https://medium.com');
    });
  });
}
