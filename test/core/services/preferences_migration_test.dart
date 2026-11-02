import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_service.dart';
import 'package:freedium_mobile/features/history/application/history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'migrates saved data once without deleting legacy preferences',
    () async {
      final legacyValues = <String, Object>{
        'has_seen_onboarding': true,
        'history_limit': 30,
        'webview_font_size': 24.0,
        'settings_snapshot':
            '{"version":1,"values":{"auto_detect_clipboard":false}}',
        'bookmark_folders': ['Tech'],
        'bookmarked_articles': [
          jsonEncode({
            'url': TestFixtures.storyUrl,
            'title': 'Saved story',
            'savedAt': TestFixtures.seedDate.toIso8601String(),
            'folder': 'Tech',
          }),
        ],
        'reading_history': [
          jsonEncode({
            'url': TestFixtures.storyUrl,
            'title': 'Saved story',
            'timestamp': TestFixtures.seedDate.toIso8601String(),
            'progress': 0.6,
          }),
        ],
      };
      SharedPreferences.setMockInitialValues(legacyValues);
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final first = ProviderContainer();
      addTearDown(first.dispose);
      final prefs = await first.read(sharedPreferencesProvider.future);
      for (final entry in legacyValues.entries) {
        expect(prefs.get(entry.key), entry.value);
      }
      expect(
        BookmarksService(prefs).getBookmarks().single.title,
        'Saved story',
      );
      expect(HistoryService(prefs).getHistory().single.progress, 0.6);
      expect(FontSizeService(prefs).loadFontSize(), 24);

      await prefs.setBool('has_seen_onboarding', false);
      await prefs.remove('reading_history');
      final restarted = ProviderContainer();
      addTearDown(restarted.dispose);
      final reloaded = await restarted.read(sharedPreferencesProvider.future);
      expect(reloaded.getBool('has_seen_onboarding'), isFalse);
      expect(HistoryService(reloaded).getHistory(), isEmpty);
      final legacy = await SharedPreferences.getInstance();
      expect(legacy.getBool('has_seen_onboarding'), isTrue);
      expect(legacy.getStringList('reading_history'), isNotEmpty);
    },
  );

  test(
    'failed migration keeps legacy data and does not mark completion',
    () async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
      SharedPreferencesAsyncPlatform.instance = FailingPrefsStore();
      final container = ProviderContainer(retry: (_, _) => null);
      addTearDown(container.dispose);
      await expectLater(
        container.read(sharedPreferencesProvider.future),
        throwsException,
      );
      expect(
        await SharedPreferencesAsync().containsKey('preferences_migrated_v1'),
        isFalse,
      );
      expect(
        (await SharedPreferences.getInstance()).getBool('has_seen_onboarding'),
        isTrue,
      );
    },
  );
}
