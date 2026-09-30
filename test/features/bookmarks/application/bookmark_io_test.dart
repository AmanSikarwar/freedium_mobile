import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmark_io.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';

import '../../../test_helpers.dart';

BookmarkedArticle _entry(String url, {String? folder}) => BookmarkedArticle(
  url: url,
  title: 'Title for $url',
  savedAt: TestFixtures.seedDate,
  folder: folder,
);

void main() {
  group('bookmark backup', () {
    test(
      'rejects unsupported versions and skips incorrectly typed entries',
      () {
        for (final version in [null, 999, '1', 1.0]) {
          expect(
            () => parseBookmarksJson(
              jsonEncode({'version': version, 'bookmarks': <Object?>[]}),
            ),
            throwsFormatException,
          );
        }
        final parsed = parseBookmarksJson(
          jsonEncode({
            'version': bookmarkBackupVersion,
            'bookmarks': [
              {'url': 42},
              {'url': TestFixtures.storyUrl, 'title': false},
              {'url': TestFixtures.storyUrl, 'folder': <Object?>[]},
              {'url': TestFixtures.storyUrl, 'savedAt': <String, Object?>{}},
              {'url': TestFixtures.storyUrl, 'title': 'Valid'},
            ],
          }),
        );
        expect(parsed.skipped, 4);
        expect(parsed.bookmarks.single.title, 'Valid');
      },
    );

    test('round-trips bookmarks and folders', () {
      final raw = exportBookmarksJson(
        [_entry(TestFixtures.storyUrl, folder: 'Tech')],
        const ['Tech'],
      );
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      expect(decoded['version'], bookmarkBackupVersion);
      expect(decoded['folders'], ['Tech']);

      final parsed = parseBookmarksJson(raw);
      expect(parsed.skipped, 0);
      expect(parsed.bookmarks, hasLength(1));
      expect(parsed.bookmarks.single.url, TestFixtures.storyUrl);
      expect(
        parsed.bookmarks.single.title,
        'Title for ${TestFixtures.storyUrl}',
      );
      expect(parsed.bookmarks.single.folder, 'Tech');
    });

    test('skips entries with missing or invalid URLs', () {
      final raw = jsonEncode({
        'version': 1,
        'folders': <String>[],
        'bookmarks': [
          {'url': null, 'title': 'No URL'},
          {'url': 'not a url', 'title': 'Bad URL'},
          {'title': 'Missing URL key'},
          {
            'url': TestFixtures.storyUrl,
            'title': '  ',
            'savedAt': 'not a date',
            'folder': '  ',
          },
        ],
      });

      final parsed = parseBookmarksJson(raw);

      expect(parsed.skipped, 3);
      expect(parsed.bookmarks, hasLength(1));
      expect(parsed.bookmarks.single.title, TestFixtures.storyUrl);
      expect(parsed.bookmarks.single.folder, isNull);
    });

    test('throws FormatException for non-backup payloads', () {
      expect(() => parseBookmarksJson('not json'), throwsFormatException);
      expect(() => parseBookmarksJson('[]'), throwsFormatException);
      expect(
        () => parseBookmarksJson(jsonEncode({'version': 1})),
        throwsFormatException,
      );
    });
  });
}
