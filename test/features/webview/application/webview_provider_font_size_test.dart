import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WebviewNotifier font size', () {
    test('loads persisted font size through supported bounds', () async {
      SharedPreferences.setMockInitialValues({'webview_font_size': 100.0});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
        ],
      );
      addTearDown(container.dispose);

      final provider = webviewProvider('https://medium.com/example/story');
      container.read(provider);
      await container.read(sharedPreferencesProvider.future);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(provider).fontSize, FontSizeService.maxFontSize);
    });

    test('clamps font size updates before saving state', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
        ],
      );
      addTearDown(container.dispose);

      final provider = webviewProvider('https://medium.com/example/story');
      container.read(provider);
      await container.read(sharedPreferencesProvider.future);
      await Future<void>.delayed(Duration.zero);

      await container.read(provider.notifier).updateFontSize(100);

      expect(container.read(provider).fontSize, FontSizeService.maxFontSize);
      expect(prefs.getDouble('webview_font_size'), FontSizeService.maxFontSize);
    });
  });
}
