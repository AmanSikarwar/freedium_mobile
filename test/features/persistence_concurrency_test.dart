import 'dart:convert';

import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/application/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_service.dart';
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/history/application/history_service.dart';
import 'package:freedium_mobile/core/utils/serial_task_queue.dart';

import '../test_helpers.dart';

class _FailedWriteStore(super.initialValues) extends FailingPrefsStore {
  int writes = 0;
  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    writes++;
    return false;
  }
}

void main() {
  test(
    'failed folder rename and settings reset preserve every saved field',
    () async {
      final article = BookmarkedArticle(
        url: TestFixtures.storyUrl,
        title: 'Story',
        savedAt: TestFixtures.seedDate,
        folder: 'Tech',
      );
      final store = _FailedWriteStore({
        'flutter.bookmarked_articles': [jsonEncode(article.toJson())],
        'flutter.bookmark_folders': ['Tech'],
        'flutter.theme_mode': 'dark',
        'flutter.webview_font_size': 26.0,
      });
      SharedPreferencesStorePlatform.instance = store;
      SharedPreferences.resetStatic();
      addTearDown(() => SharedPreferences.setMockInitialValues({}));
      final prefs = await SharedPreferences.getInstance();
      final container = prefsContainer(prefs);
      addTearDown(container.dispose);
      await container.read(bookmarksProvider.future);
      await container.read(bookmarkFoldersProvider.future);
      final settings = await container.read(settingsProvider.future);
      expect(
        await container
            .read(bookmarkFoldersProvider.notifier)
            .renameFolder('Tech', 'Work'),
        isFalse,
      );
      expect(container.read(bookmarksProvider).requireValue, [article]);
      expect(BookmarksService(prefs).getFolders(), ['Tech']);
      expect(BookmarksService(prefs).getBookmarks(), [article]);
      expect(
        await container.read(settingsProvider.notifier).resetToDefaults(),
        isFalse,
      );
      expect(container.read(settingsProvider).requireValue, settings);
      expect(SettingsService(prefs).loadThemeMode(), ThemeMode.dark);
      expect(SettingsService(prefs).loadDefaultFontSize(), 26);
      expect(store.writes, 2); // One attempted snapshot per operation.
    },
  );

  test(
    'overlapping library mutations preserve stored data and order',
    () async {
      final prefs = await mockPrefs();
      final container = prefsContainer(prefs);
      addTearDown(container.dispose);
      final bookmarks = container.read(bookmarksProvider.notifier);
      final history = container.read(historyProvider.notifier);
      final folders = container.read(bookmarkFoldersProvider.notifier);

      expect(
        await Future.wait([
          bookmarks.addBookmark(
            'https://medium.com/first',
            'First',
            folder: 'Tech',
          ),
          bookmarks.addBookmark(
            'https://medium.com/second',
            'Second',
            folder: 'Work',
          ),
        ]),
        everyElement(isTrue),
      );
      expect(BookmarksService(prefs).getBookmarks(), hasLength(2));
      expect(BookmarksService(prefs).getFolders(), ['Tech', 'Work']);

      await Future.wait([
        history.addHistory('https://medium.com/first', 'First'),
        history.addHistory('https://medium.com/second', 'Second'),
        history.updateReadingProgress('https://medium.com/first', 0.5),
      ]);
      expect(HistoryService(prefs).getHistory(), hasLength(2));
      expect(await history.readingProgressFor('https://medium.com/first'), 0.5);
      await Future.wait([
        history.updateReadingProgress('https://medium.com/first', 0.8),
        history.clearHistory(),
      ]);
      expect(HistoryService(prefs).getHistory(), isEmpty);

      await Future.wait([
        bookmarks.toggleBookmark(TestFixtures.storyUrl, 'Story'),
        bookmarks.toggleBookmark(TestFixtures.storyUrl, 'Story'),
        folders.createFolder('Other'),
        folders.renameFolder('Tech', 'Engineering'),
      ]);
      expect(bookmarks.isBookmarked(TestFixtures.storyUrl), isFalse);
      expect(BookmarksService(prefs).getFolders(), [
        'Engineering',
        'Other',
        'Work',
      ]);
    },
  );

  test('a failed queued task does not block the following write', () async {
    final queue = SerialTaskQueue();
    final failed = queue.run<void>(() async => throw StateError('failed'));
    final following = queue.run(() async => 42);
    await expectLater(failed, throwsStateError);
    expect(await following, 42);
  });
}
