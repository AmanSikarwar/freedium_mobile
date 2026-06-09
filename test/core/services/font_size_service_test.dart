import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _RemoveTrackingSharedPreferencesStore
    extends SharedPreferencesStorePlatform {
  _RemoveTrackingSharedPreferencesStore(
    this.initialValues, {
    required this.removeResult,
  });

  final Map<String, Object> initialValues;
  final bool removeResult;
  final removeCalls = <String>[];

  @override
  Future<bool> clear() async => true;

  @override
  Future<Map<String, Object>> getAll() async => initialValues;

  @override
  Future<bool> remove(String key) async {
    removeCalls.add(key);
    return removeResult;
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      true;
}

void main() {
  group('FontSizeService', () {
    test('loadFontSize clamps persisted values to supported bounds', () async {
      SharedPreferences.setMockInitialValues({'webview_font_size': 100.0});
      final prefs = await SharedPreferences.getInstance();
      final service = FontSizeService(prefs);

      expect(service.loadFontSize(), FontSizeService.maxFontSize);
    });

    test('loadFontSize falls back to legacy settings key', () async {
      SharedPreferences.setMockInitialValues({'default_font_size': 22.0});
      final prefs = await SharedPreferences.getInstance();
      final service = FontSizeService(prefs);

      expect(service.loadFontSize(), 22.0);
    });

    test('saveFontSize clamps out-of-range values', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
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
      final previousStore = SharedPreferencesStorePlatform.instance;
      final store = _RemoveTrackingSharedPreferencesStore(
        {},
        removeResult: false,
      );
      SharedPreferencesStorePlatform.instance = store;
      SharedPreferences.resetStatic();
      addTearDown(() {
        SharedPreferencesStorePlatform.instance = previousStore;
        SharedPreferences.resetStatic();
      });
      final prefs = await SharedPreferences.getInstance();
      final service = FontSizeService(prefs);

      await service.resetFontSize();

      expect(store.removeCalls, isEmpty);
    });

    test(
      'resetFontSize reports failed removal for existing legacy key',
      () async {
        final previousStore = SharedPreferencesStorePlatform.instance;
        final store = _RemoveTrackingSharedPreferencesStore({
          'flutter.default_font_size': 22.0,
        }, removeResult: false);
        SharedPreferencesStorePlatform.instance = store;
        SharedPreferences.resetStatic();
        addTearDown(() {
          SharedPreferencesStorePlatform.instance = previousStore;
          SharedPreferences.resetStatic();
        });
        final prefs = await SharedPreferences.getInstance();
        final service = FontSizeService(prefs);

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
