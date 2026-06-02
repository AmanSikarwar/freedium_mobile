import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingFreediumUrlService extends FreediumUrlService {
  _RecordingFreediumUrlService(super.ref);

  int invalidateCount = 0;

  @override
  void invalidateCache() {
    invalidateCount++;
  }
}

void main() {
  group('isFreediumMirrorUrl', () {
    test('matches URLs on configured mirror hosts', () {
      expect(
        isFreediumMirrorUrl(
          'https://freedium.cfd/https://medium.com/example/story',
          SettingsState.defaultMirrors,
        ),
        isTrue,
      );
    });

    test('rejects hosts that only share a mirror URL prefix', () {
      expect(
        isFreediumMirrorUrl(
          'https://freedium.cfd.evil.example/https://medium.com/story',
          SettingsState.defaultMirrors,
        ),
        isFalse,
      );
    });

    test('rejects URLs that do not match the mirror origin', () {
      expect(
        isFreediumMirrorUrl(
          'http://freedium.cfd/https://medium.com/story',
          SettingsState.defaultMirrors,
        ),
        isFalse,
      );
      expect(
        isFreediumMirrorUrl(
          'https://freedium.cfd:8443/https://medium.com/story',
          SettingsState.defaultMirrors,
        ),
        isFalse,
      );
    });

    test('respects custom mirror path boundaries', () {
      const mirrors = [
        FreediumMirror(name: 'Path mirror', url: 'https://mirror.example/base'),
      ];

      expect(
        isFreediumMirrorUrl('https://mirror.example/base/story', mirrors),
        isTrue,
      );
      expect(
        isFreediumMirrorUrl('https://mirror.example/baseball/story', mirrors),
        isFalse,
      );
    });
  });

  group('SettingsNotifier', () {
    test('invalidates active URL cache when mirror list changes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      late _RecordingFreediumUrlService freediumUrlService;
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
          freediumUrlServiceProvider.overrideWith((ref) {
            freediumUrlService = _RecordingFreediumUrlService(ref);
            return freediumUrlService;
          }),
        ],
      );
      addTearDown(container.dispose);

      const customMirror = FreediumMirror(
        name: 'Custom',
        url: 'https://custom.example',
        isCustom: true,
      );
      const updatedMirror = FreediumMirror(
        name: 'Updated',
        url: 'https://updated.example',
        isCustom: true,
      );
      final notifier = container.read(settingsProvider.notifier);

      await notifier.addMirror(customMirror);
      expect(freediumUrlService.invalidateCount, 1);

      await notifier.updateMirror(customMirror, updatedMirror);
      expect(freediumUrlService.invalidateCount, 2);

      await notifier.removeMirror(updatedMirror);
      expect(freediumUrlService.invalidateCount, 3);

      await notifier.resetToDefaults();
      expect(freediumUrlService.invalidateCount, 4);
    });
  });
}
