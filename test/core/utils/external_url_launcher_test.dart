import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/utils/external_url_launcher.dart';

void main() {
  group('parseExternalHttpUrl', () {
    test('accepts absolute http and https links', () {
      expect(
        parseExternalHttpUrl(' https://github.com/example/release '),
        Uri.parse('https://github.com/example/release'),
      );
      expect(
        parseExternalHttpUrl('http://example.com/changelog'),
        Uri.parse('http://example.com/changelog'),
      );
    });

    test('rejects relative and non-web links', () {
      expect(parseExternalHttpUrl('/relative-release-note'), isNull);
      expect(parseExternalHttpUrl('javascript:alert(1)'), isNull);
      expect(parseExternalHttpUrl('mailto:test@example.com'), isNull);
      expect(parseExternalHttpUrl('https://'), isNull);
    });
  });
}
