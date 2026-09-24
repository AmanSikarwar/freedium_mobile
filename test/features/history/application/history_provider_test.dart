import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../../../test_helpers.dart';


void main() {
  group('HistoryNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      container = prefsContainer(await mockPrefs());
    });

    tearDown(() {
      container.dispose();
    });

    test('normalizes URL and title before saving history', () async {
      await container
          .read(historyProvider.notifier)
          .addHistory(' HTTPS://Medium.COM/example/story/ ', ' Example story ');

      final history = container.read(historyProvider).requireValue;
      expect(history, hasLength(1));
      expect(history.single.url, TestFixtures.storyUrl);
      expect(history.single.title, 'Example story');
    });

    test('falls back to normalized URL when history title is blank', () async {
      await container
          .read(historyProvider.notifier)
          .addHistory(' HTTPS://Medium.COM/example/story/ ', '  ');

      final history = container.read(historyProvider).requireValue;
      expect(history, hasLength(1));
      expect(history.single.title, TestFixtures.storyUrl);
    });

    test('ignores invalid history URLs', () async {
      final notifier = container.read(historyProvider.notifier);

      await notifier.addHistory('ftp://example.com/story', 'Invalid');
      await notifier.addHistory('not a url', 'Invalid');
      await notifier.addHistory('', 'Invalid');

      expect(container.read(historyProvider).requireValue, isEmpty);
    });

    test('deduplicates history by normalized URL', () async {
      final notifier = container.read(historyProvider.notifier);
      await notifier.addHistory(TestFixtures.storyUrl, 'First');
      await notifier.addHistory(
        ' HTTPS://Medium.COM/example/story/ ',
        'Second',
      );

      final history = container.read(historyProvider).requireValue;
      expect(history, hasLength(1));
      expect(history.single.url, TestFixtures.storyUrl);
      expect(history.single.title, 'Second');
    });

    test('updates and preserves reading progress when reopening', () async {
      final notifier = container.read(historyProvider.notifier);
      await notifier.addHistory(TestFixtures.storyUrl, 'First');
      await notifier.updateReadingProgress(
        TestFixtures.storyUrl,
        0.42,
      );
      await notifier.addHistory(TestFixtures.storyUrl, 'Second');

      final history = container.read(historyProvider).requireValue;
      expect(history.single.title, 'Second');
      expect(history.single.progress, 0.42);
      expect(
        await notifier.readingProgressFor(
          ' HTTPS://Medium.COM/example/story/ ',
        ),
        0.42,
      );
    });

    test('normalizes reading progress thresholds', () async {
      final notifier = container.read(historyProvider.notifier);
      await notifier.addHistory(TestFixtures.storyUrl, 'Story');

      await notifier.updateReadingProgress(
        TestFixtures.storyUrl,
        0.04,
      );
      expect(container.read(historyProvider).requireValue.single.progress, 0);

      await notifier.updateReadingProgress(
        TestFixtures.storyUrl,
        0.96,
      );
      expect(container.read(historyProvider).requireValue.single.progress, 1);
    });

    test('reports failure and preserves history when removing fails', () async {
      container.dispose();
      final history = ReadingHistory(
        url: TestFixtures.storyUrl,
        title: 'Story',
        timestamp: TestFixtures.seedDate,
      );
      SharedPreferencesStorePlatform.instance = FailingPrefsStore({
        'flutter.reading_history': [jsonEncode(history.toJson())],
      });
      SharedPreferences.resetStatic();
      addTearDown(() => SharedPreferences.setMockInitialValues({}));
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
        ],
      );

      final notifier = container.read(historyProvider.notifier);
      await container.read(historyProvider.future);
      expect(container.read(historyProvider).requireValue, hasLength(1));

      final didRemove = await notifier.removeHistory(history);

      expect(didRemove, isFalse);
      expect(container.read(historyProvider).requireValue, hasLength(1));
    });

    test('reports failure and preserves history when clearing fails', () async {
      container.dispose();
      final history = ReadingHistory(
        url: TestFixtures.storyUrl,
        title: 'Story',
        timestamp: TestFixtures.seedDate,
      );
      SharedPreferencesStorePlatform.instance = FailingPrefsStore({
        'flutter.reading_history': [jsonEncode(history.toJson())],
      });
      SharedPreferences.resetStatic();
      addTearDown(() => SharedPreferences.setMockInitialValues({}));
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
        ],
      );

      final notifier = container.read(historyProvider.notifier);
      await container.read(historyProvider.future);
      expect(container.read(historyProvider).requireValue, hasLength(1));

      final didClear = await notifier.clearHistory();

      expect(didClear, isFalse);
      expect(container.read(historyProvider).requireValue, hasLength(1));
    });
  });
}
