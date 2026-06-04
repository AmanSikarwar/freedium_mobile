import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _FailingSharedPreferencesStore extends SharedPreferencesStorePlatform {
  _FailingSharedPreferencesStore([Map<String, Object>? initialValues])
    : _values = Map.of(initialValues ?? {});

  final Map<String, Object> _values;

  @override
  Future<bool> clear() async => false;

  @override
  Future<Map<String, Object>> getAll() async => Map.of(_values);

  @override
  Future<bool> remove(String key) async => false;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

void main() {
  group('HistoryNotifier', () {
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

    test('normalizes URL and title before saving history', () async {
      await container
          .read(historyProvider.notifier)
          .addHistory(' HTTPS://Medium.COM/example/story/ ', ' Example story ');

      final history = container.read(historyProvider);
      expect(history, hasLength(1));
      expect(history.single.url, 'https://medium.com/example/story');
      expect(history.single.title, 'Example story');
    });

    test('falls back to normalized URL when history title is blank', () async {
      await container
          .read(historyProvider.notifier)
          .addHistory(' HTTPS://Medium.COM/example/story/ ', '  ');

      final history = container.read(historyProvider);
      expect(history, hasLength(1));
      expect(history.single.title, 'https://medium.com/example/story');
    });

    test('ignores invalid history URLs', () async {
      final notifier = container.read(historyProvider.notifier);

      await notifier.addHistory('ftp://example.com/story', 'Invalid');
      await notifier.addHistory('not a url', 'Invalid');
      await notifier.addHistory('', 'Invalid');

      expect(container.read(historyProvider), isEmpty);
    });

    test('deduplicates history by normalized URL', () async {
      final notifier = container.read(historyProvider.notifier);
      await notifier.addHistory('https://medium.com/example/story', 'First');
      await notifier.addHistory(
        ' HTTPS://Medium.COM/example/story/ ',
        'Second',
      );

      final history = container.read(historyProvider);
      expect(history, hasLength(1));
      expect(history.single.url, 'https://medium.com/example/story');
      expect(history.single.title, 'Second');
    });

    test('reports failure and preserves history when clearing fails', () async {
      container.dispose();
      final history = ReadingHistory(
        url: 'https://medium.com/example/story',
        title: 'Story',
        timestamp: DateTime.utc(2026, 2, 3),
      );
      SharedPreferencesStorePlatform.instance = _FailingSharedPreferencesStore({
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
      container.read(historyProvider);
      await container.read(sharedPreferencesProvider.future);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(historyProvider), hasLength(1));

      final didClear = await notifier.clearHistory();

      expect(didClear, isFalse);
      expect(container.read(historyProvider), hasLength(1));
    });
  });
}
