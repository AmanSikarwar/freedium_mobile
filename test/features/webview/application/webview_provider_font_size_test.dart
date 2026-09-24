import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../../../test_helpers.dart';

void main() {
  group('WebviewNotifier font size', () {
    test('loads persisted font size through supported bounds', () async {
      await mockPrefs({'webview_font_size': 100.0});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
        ],
      );
      addTearDown(container.dispose);

      final provider = webviewProvider(TestFixtures.storyUrl);
      container.read(provider);
      await container.read(sharedPreferencesProvider.future);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(provider).fontSize, FontSizeService.maxFontSize);
    });

    test('clamps font size updates before saving state', () async {
      await mockPrefs({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
        ],
      );
      addTearDown(container.dispose);

      final provider = webviewProvider(TestFixtures.storyUrl);
      container.read(provider);
      await container.read(sharedPreferencesProvider.future);
      await Future<void>.delayed(Duration.zero);

      await container.read(provider.notifier).updateFontSize(100);

      expect(container.read(provider).fontSize, FontSizeService.maxFontSize);
      expect(
        container.read(settingsProvider).requireValue.defaultFontSize,
        FontSizeService.maxFontSize,
      );
      expect(prefs.getDouble('webview_font_size'), FontSizeService.maxFontSize);
    });

    test('tracks font size changes made from settings', () async {
      await mockPrefs({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
        ],
      );
      addTearDown(container.dispose);

      final provider = webviewProvider(TestFixtures.storyUrl);
      container.read(provider);
      await container.read(sharedPreferencesProvider.future);
      await Future<void>.delayed(Duration.zero);

      await container.read(settingsProvider.notifier).setDefaultFontSize(22);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(provider).fontSize, 22.0);
    });

    test('keeps font size and reports message when saving fails', () async {
      final previousStore = SharedPreferencesStorePlatform.instance;
      SharedPreferencesStorePlatform.instance = FailingPrefsStore();
      SharedPreferences.resetStatic();
      addTearDown(() {
        SharedPreferences.setMockInitialValues({});
        SharedPreferencesStorePlatform.instance = previousStore;
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
        ],
      );
      addTearDown(container.dispose);

      final provider = webviewProvider(TestFixtures.storyUrl);
      container.read(provider);
      await container.read(sharedPreferencesProvider.future);
      await Future<void>.delayed(Duration.zero);

      final didSave = await container
          .read(provider.notifier)
          .updateFontSize(20);

      final state = container.read(provider);
      expect(didSave, isFalse);
      expect(state.fontSize, FontSizeService.defaultFontSize);
      expect(state.userMessage, 'Failed to save font size');
    });
  });
}
