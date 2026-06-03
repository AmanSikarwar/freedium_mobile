import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('BookmarksNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('normalizes URL and title before saving a bookmark', () async {
      await container
          .read(bookmarksProvider.notifier)
          .addBookmark(
            ' HTTPS://Medium.COM/example/story/ ',
            ' Example story ',
          );

      final bookmarks = container.read(bookmarksProvider);
      expect(bookmarks, hasLength(1));
      expect(bookmarks.single.url, 'https://medium.com/example/story');
      expect(bookmarks.single.title, 'Example story');
    });

    test('falls back to normalized URL when bookmark title is blank', () async {
      await container
          .read(bookmarksProvider.notifier)
          .addBookmark(' HTTPS://Medium.COM/example/story/ ', '  ');

      final bookmarks = container.read(bookmarksProvider);
      expect(bookmarks, hasLength(1));
      expect(bookmarks.single.title, 'https://medium.com/example/story');
    });

    test('ignores invalid bookmark URLs', () async {
      final notifier = container.read(bookmarksProvider.notifier);

      await notifier.addBookmark('ftp://example.com/story', 'Invalid');
      await notifier.addBookmark('not a url', 'Invalid');
      await notifier.addBookmark('', 'Invalid');

      expect(container.read(bookmarksProvider), isEmpty);
    });

    test('deduplicates bookmarks by normalized URL', () async {
      final notifier = container.read(bookmarksProvider.notifier);
      await notifier.addBookmark('https://medium.com/example/story', 'First');
      await notifier.addBookmark(
        ' HTTPS://Medium.COM/example/story/ ',
        'Second',
      );

      final bookmarks = container.read(bookmarksProvider);
      expect(bookmarks, hasLength(1));
      expect(bookmarks.single.title, 'First');
    });

    test('toggles bookmarks by normalized URL', () async {
      final notifier = container.read(bookmarksProvider.notifier);
      await notifier.addBookmark('https://medium.com/example/story', 'Story');

      await notifier.toggleBookmark(' HTTPS://Medium.COM/example/story/ ', '');
      expect(container.read(bookmarksProvider), isEmpty);
    });
  });
}
