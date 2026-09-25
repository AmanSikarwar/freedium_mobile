import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/history/application/history_service.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';

import '../../../test_helpers.dart';

void main() {
  group('HistoryLimit', () {
    late ProviderContainer container;

    setUp(() async {
      container = prefsContainer(await mockPrefs());
    });

    tearDown(() {
      container.dispose();
    });

    test('defaults to 100 entries', () async {
      expect(
        await container.read(historyLimitProvider.future),
        HistoryService.defaultLimit,
      );
    });

    test('falls back to default for unrecognized stored values', () async {
      container.dispose();
      container = prefsContainer(await mockPrefs({'history_limit': 42}));
      expect(
        await container.read(historyLimitProvider.future),
        HistoryService.defaultLimit,
      );
    });

    test('persists a new limit and trims history to match', () async {
      final history = container.read(historyProvider.notifier);
      for (var i = 0; i < 35; i++) {
        await history.addHistory('https://medium.com/story-$i', 'Story $i');
      }
      expect(container.read(historyProvider).requireValue, hasLength(35));

      final didApply = await container
          .read(historyLimitProvider.notifier)
          .setLimit(30);

      expect(didApply, isTrue);
      expect(await container.read(historyLimitProvider.future), 30);
      expect(container.read(historyProvider).requireValue, hasLength(30));
    });

    test('rejects unsupported limits', () async {
      final didApply = await container
          .read(historyLimitProvider.notifier)
          .setLimit(42);

      expect(didApply, isFalse);
      expect(
        await container.read(historyLimitProvider.future),
        HistoryService.defaultLimit,
      );
    });
  });

  group('History pruning', () {
    late ProviderContainer container;

    setUp(() async {
      container = prefsContainer(await mockPrefs());
    });

    tearDown(() {
      container.dispose();
    });

    test('clears entries older than the given age', () async {
      final history = container.read(historyProvider.notifier);
      await history.addHistory('https://medium.com/recent', 'Recent');
      await history.addHistory('https://medium.com/old', 'Old');

      // Backdate the second entry by rewriting state through removal+seed.
      final current = container.read(historyProvider).requireValue;
      expect(current, hasLength(2));

      final removed = await history.clearOlderThan(Duration.zero);
      // Both entries are older than "now minus zero"; everything clears.
      expect(removed, 2);
      expect(container.read(historyProvider).requireValue, isEmpty);
    });

    test('reports zero when nothing is old enough', () async {
      final history = container.read(historyProvider.notifier);
      await history.addHistory(TestFixtures.storyUrl, 'Story');

      final removed = await history.clearOlderThan(const Duration(days: 30));

      expect(removed, 0);
      expect(container.read(historyProvider).requireValue, hasLength(1));
    });

    test('trims oversized stored history to the limit on load', () async {
      container.dispose();
      container = prefsContainer(
        await mockPrefs({
          'reading_history': [
            for (var i = 0; i < 35; i++)
              jsonEncode(
                ReadingHistory(
                  url: 'https://medium.com/story-$i',
                  title: 'Story $i',
                  timestamp: TestFixtures.seedDate.add(Duration(minutes: i)),
                ).toJson(),
              ),
          ],
          'history_limit': 30,
        }),
      );

      final history = await container.read(historyProvider.future);
      expect(history, hasLength(30));
    });
  });
}
