import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/changelog_bottom_sheet.dart';

void main() {
  group('parseChangelogHttpUrl', () {
    test('accepts absolute http and https links', () {
      expect(
        parseChangelogHttpUrl(' https://github.com/example/release '),
        Uri.parse('https://github.com/example/release'),
      );
      expect(
        parseChangelogHttpUrl('http://example.com/changelog'),
        Uri.parse('http://example.com/changelog'),
      );
    });

    test('rejects relative and non-web markdown links', () {
      expect(parseChangelogHttpUrl('/relative-release-note'), isNull);
      expect(parseChangelogHttpUrl('javascript:alert(1)'), isNull);
      expect(parseChangelogHttpUrl('mailto:test@example.com'), isNull);
      expect(parseChangelogHttpUrl('https://'), isNull);
    });
  });
}
