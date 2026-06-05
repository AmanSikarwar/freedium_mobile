import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FontSizeService', () {
    test('loadFontSize clamps persisted values to supported bounds', () async {
      SharedPreferences.setMockInitialValues({'webview_font_size': 100.0});
      final prefs = await SharedPreferences.getInstance();
      final service = FontSizeService(prefs);

      expect(service.loadFontSize(), FontSizeService.maxFontSize);
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
  });
}
