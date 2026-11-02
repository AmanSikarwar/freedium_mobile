import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../../test_helpers.dart';

final class _RemoveTrackingSharedPreferencesStore(
  this.initialValues, {
  required this.removeResult,
}) extends InMemorySharedPreferencesAsync {
  this
    : super.withData({
        for (final entry in initialValues.entries)
          entry.key.replaceFirst(RegExp(r'^flutter\.'), ''): entry.value,
      });
  final Map<String, Object> initialValues;
  final bool removeResult;
  final removeCalls = <String>[];

  @override
  Future<bool> clear(
    ClearPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    removeCalls.addAll(parameters.filter.allowList ?? {});
    if (!removeResult) {
      throw Exception('Failed to remove ${parameters.filter.allowList}');
    }
    return super.clear(parameters, options);
  }
}

void main() {
  group('FontSizeService', () {
    test('loadFontSize clamps persisted values to supported bounds', () async {
      await mockPrefs({'webview_font_size': 100.0});
      final service = FontSizeService(await testPrefs());

      expect(service.loadFontSize(), FontSizeService.maxFontSize);
    });

    test('loadFontSize falls back to legacy settings key', () async {
      await mockPrefs({'default_font_size': 22.0});
      final service = FontSizeService(await testPrefs());

      expect(service.loadFontSize(), 22.0);
    });

    test('saveFontSize clamps out-of-range values', () async {
      await mockPrefs({});
      final prefs = await testPrefs();
      final service = FontSizeService(prefs);

      await service.saveFontSize(1);

      expect(prefs.getDouble('webview_font_size'), FontSizeService.minFontSize);
    });

    test('normalizeFontSize falls back for non-finite values', () {
      expect(
        FontSizeService.normalizeFontSize(double.nan),
        FontSizeService.defaultFontSize,
      );
    });

    test('resetFontSize ignores missing keys before removing', () async {
      final previousStore = SharedPreferencesAsyncPlatform.instance;
      final store = _RemoveTrackingSharedPreferencesStore(
        {},
        removeResult: false,
      );
      SharedPreferencesAsyncPlatform.instance = store;

      addTearDown(() {
        SharedPreferencesAsyncPlatform.instance = previousStore;
      });
      final service = FontSizeService(await testPrefs());

      await service.resetFontSize();

      expect(store.removeCalls, isEmpty);
    });

    test(
      'resetFontSize reports failed removal for existing legacy key',
      () async {
        final previousStore = SharedPreferencesAsyncPlatform.instance;
        final store = _RemoveTrackingSharedPreferencesStore({
          'flutter.default_font_size': 22.0,
        }, removeResult: false);
        SharedPreferencesAsyncPlatform.instance = store;

        addTearDown(() {
          SharedPreferencesAsyncPlatform.instance = previousStore;
        });
        final service = FontSizeService(await testPrefs());

        expect(
          service.resetFontSize(),
          throwsA(
            isA<Exception>().having(
              (exception) => exception.toString(),
              'message',
              contains('default_font_size'),
            ),
          ),
        );
      },
    );
  });
}
