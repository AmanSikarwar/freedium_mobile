import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../../../test_helpers.dart';


void main() {
  group('BookmarksNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      container = prefsContainer(await mockPrefs());
    });

    tearDown(() {
      container.dispose();
    });

    test('normalizes URL and title before saving a bookmark', () async {
      final didAdd = await container
          .read(bookmarksProvider.notifier)
          .addBookmark(
            ' HTTPS://Medium.COM/example/story/ ',
            ' Example story ',
          );

      final bookmarks = container.read(bookmarksProvider).requireValue;
      expect(didAdd, isTrue);
      expect(bookmarks, hasLength(1));
      expect(bookmarks.single.url, TestFixtures.storyUrl);
      expect(bookmarks.single.title, 'Example story');
    });

    test('falls back to normalized URL when bookmark title is blank', () async {
      await container
          .read(bookmarksProvider.notifier)
          .addBookmark(' HTTPS://Medium.COM/example/story/ ', '  ');

      final bookmarks = container.read(bookmarksProvider).requireValue;
      expect(bookmarks, hasLength(1));
      expect(bookmarks.single.title, TestFixtures.storyUrl);
    });

    test('ignores invalid bookmark URLs', () async {
      final notifier = container.read(bookmarksProvider.notifier);

      final didAddFtp = await notifier.addBookmark(
        'ftp://example.com/story',
        'Invalid',
      );
      final didAddText = await notifier.addBookmark('not a url', 'Invalid');
      final didAddEmpty = await notifier.addBookmark('', 'Invalid');

      expect(didAddFtp, isFalse);
      expect(didAddText, isFalse);
      expect(didAddEmpty, isFalse);
      expect(container.read(bookmarksProvider).requireValue, isEmpty);
    });

    test('deduplicates bookmarks by normalized URL', () async {
      final notifier = container.read(bookmarksProvider.notifier);
      await notifier.addBookmark(TestFixtures.storyUrl, 'First');
      await notifier.addBookmark(
        ' HTTPS://Medium.COM/example/story/ ',
        'Second',
      );

      final bookmarks = container.read(bookmarksProvider).requireValue;
      expect(bookmarks, hasLength(1));
      expect(bookmarks.single.title, 'First');
    });

    test('toggles bookmarks by normalized URL', () async {
      final notifier = container.read(bookmarksProvider.notifier);
      await notifier.addBookmark(TestFixtures.storyUrl, 'Story');

      final didToggle = await notifier.toggleBookmark(
        ' HTTPS://Medium.COM/example/story/ ',
        '',
      );
      expect(didToggle, isTrue);
      expect(container.read(bookmarksProvider).requireValue, isEmpty);
    });

    test('reports failure and preserves bookmarks when adding fails', () async {
      container.dispose();
      SharedPreferencesStorePlatform.instance =
          FailingPrefsStore();
      SharedPreferences.resetStatic();
      addTearDown(() => SharedPreferences.setMockInitialValues({}));
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
        ],
      );

      final notifier = container.read(bookmarksProvider.notifier);
      await container.read(bookmarksProvider.future);

      final didAdd = await notifier.addBookmark(
        TestFixtures.storyUrl,
        'Story',
      );

      expect(didAdd, isFalse);
      expect(container.read(bookmarksProvider).requireValue, isEmpty);
    });

    test('reports failure when toggling a bookmark add fails', () async {
      container.dispose();
      SharedPreferencesStorePlatform.instance =
          FailingPrefsStore();
      SharedPreferences.resetStatic();
      addTearDown(() => SharedPreferences.setMockInitialValues({}));
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
        ],
      );

      final notifier = container.read(bookmarksProvider.notifier);
      await container.read(bookmarksProvider.future);

      final didToggle = await notifier.toggleBookmark(
        TestFixtures.storyUrl,
        'Story',
      );

      expect(didToggle, isFalse);
      expect(container.read(bookmarksProvider).requireValue, isEmpty);
    });

    test(
      'reports failure and preserves bookmarks when removing fails',
      () async {
        container.dispose();
        final bookmark = BookmarkedArticle(
          url: TestFixtures.storyUrl,
          title: 'Story',
          savedAt: TestFixtures.seedDate,
        );
        SharedPreferencesStorePlatform.instance =
            FailingPrefsStore({
              'flutter.bookmarked_articles': [jsonEncode(bookmark.toJson())],
            });
        SharedPreferences.resetStatic();
        addTearDown(() => SharedPreferences.setMockInitialValues({}));
        final prefs = await SharedPreferences.getInstance();
        container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async => prefs),
          ],
        );

        final notifier = container.read(bookmarksProvider.notifier);
        await container.read(bookmarksProvider.future);
        expect(container.read(bookmarksProvider).requireValue, hasLength(1));

        final didRemove = await notifier.removeBookmark(bookmark);

        expect(didRemove, isFalse);
        expect(container.read(bookmarksProvider).requireValue, hasLength(1));
      },
    );

    test(
      'reports failure and preserves bookmarks when clearing fails',
      () async {
        container.dispose();
        final bookmark = BookmarkedArticle(
          url: TestFixtures.storyUrl,
          title: 'Story',
          savedAt: TestFixtures.seedDate,
        );
        SharedPreferencesStorePlatform.instance =
            FailingPrefsStore({
              'flutter.bookmarked_articles': [jsonEncode(bookmark.toJson())],
            });
        SharedPreferences.resetStatic();
        addTearDown(() => SharedPreferences.setMockInitialValues({}));
        final prefs = await SharedPreferences.getInstance();
        container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async => prefs),
          ],
        );

        final notifier = container.read(bookmarksProvider.notifier);
        await container.read(bookmarksProvider.future);
        expect(container.read(bookmarksProvider).requireValue, hasLength(1));

        final didClear = await notifier.clearBookmarks();

        expect(didClear, isFalse);
        expect(container.read(bookmarksProvider).requireValue, hasLength(1));
      },
    );
  });
}
