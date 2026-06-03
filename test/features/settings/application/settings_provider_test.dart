import 'dart:convert';

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

    test('invalidates active URL cache when mirror policy changes', () async {
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

      final notifier = container.read(settingsProvider.notifier);

      await notifier.setAutoSwitchMirror(false);
      expect(freediumUrlService.invalidateCount, 1);

      await notifier.setMirrorTimeout(12);
      expect(freediumUrlService.invalidateCount, 2);
    });

    test('clamps numeric setting updates to supported bounds', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(settingsProvider.notifier);

      await notifier.setDefaultFontSize(100);
      await notifier.setMirrorTimeout(0);

      final settings = container.read(settingsProvider);
      expect(settings.defaultFontSize, SettingsState.maxDefaultFontSize);
      expect(settings.mirrorTimeout, SettingsState.minMirrorTimeout);
      expect(
        prefs.getDouble('default_font_size'),
        SettingsState.maxDefaultFontSize,
      );
      expect(prefs.getInt('mirror_timeout'), SettingsState.minMirrorTimeout);
    });

    test('normalizes custom mirrors before saving live state', () async {
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
      freediumUrlService =
          container.read(freediumUrlServiceProvider)
              as _RecordingFreediumUrlService;

      await container
          .read(settingsProvider.notifier)
          .addMirror(
            const FreediumMirror(
              name: ' Custom ',
              url: ' https://custom.example/// ',
              isCustom: true,
            ),
          );

      final mirror = container.read(settingsProvider).mirrors.last;
      expect(mirror.name, 'Custom');
      expect(mirror.url, 'https://custom.example');
      expect(freediumUrlService.invalidateCount, 1);

      final savedMirrors = prefs.getStringList('freedium_mirrors')!;
      final savedMirror = jsonDecode(savedMirrors.last) as Map<String, dynamic>;
      expect(savedMirror['name'], 'Custom');
      expect(savedMirror['url'], 'https://custom.example');
    });

    test('rejects invalid and duplicate custom mirrors', () async {
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
      freediumUrlService =
          container.read(freediumUrlServiceProvider)
              as _RecordingFreediumUrlService;

      final notifier = container.read(settingsProvider.notifier);
      await notifier.addMirror(
        const FreediumMirror(
          name: 'Duplicate',
          url: ' HTTPS://Freedium.CFD/ ',
          isCustom: true,
        ),
      );
      await notifier.addMirror(
        const FreediumMirror(
          name: 'Unsupported',
          url: 'ftp://custom.example',
          isCustom: true,
        ),
      );

      final settings = container.read(settingsProvider);
      expect(settings.mirrors, SettingsState.defaultMirrors);
      expect(freediumUrlService.invalidateCount, 0);
      expect(prefs.getStringList('freedium_mirrors'), isNull);
    });

    test('ignores selected mirror URLs outside current mirrors', () async {
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
      freediumUrlService =
          container.read(freediumUrlServiceProvider)
              as _RecordingFreediumUrlService;

      await container
          .read(settingsProvider.notifier)
          .setSelectedMirror('https://missing.example');

      expect(
        container.read(settingsProvider).selectedMirrorUrl,
        SettingsState.defaultMirrors.first.url,
      );
      expect(freediumUrlService.invalidateCount, 0);
      expect(prefs.getString('selected_mirror_url'), isNull);
    });

    test('ignores stale mirror remove and update requests', () async {
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
      freediumUrlService =
          container.read(freediumUrlServiceProvider)
              as _RecordingFreediumUrlService;

      const staleMirror = FreediumMirror(
        name: 'Stale',
        url: 'https://stale.example',
        isCustom: true,
      );
      final notifier = container.read(settingsProvider.notifier);

      await notifier.removeMirror(staleMirror);
      await notifier.updateMirror(
        staleMirror,
        const FreediumMirror(
          name: 'Updated',
          url: 'https://updated.example',
          isCustom: true,
        ),
      );

      expect(
        container.read(settingsProvider).mirrors,
        SettingsState.defaultMirrors,
      );
      expect(freediumUrlService.invalidateCount, 0);
      expect(prefs.getStringList('freedium_mirrors'), isNull);
    });

    test(
      'falls back to default mirrors after removing last custom mirror',
      () async {
        const customMirror = FreediumMirror(
          name: 'Custom',
          url: 'https://custom.example',
          isCustom: true,
        );
        SharedPreferences.setMockInitialValues({
          'freedium_mirrors': [jsonEncode(customMirror.toJson())],
          'selected_mirror_url': customMirror.url,
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async => prefs),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(settingsProvider.notifier)
            .removeMirror(customMirror);

        final settings = container.read(settingsProvider);
        expect(settings.mirrors, SettingsState.defaultMirrors);
        expect(
          settings.selectedMirrorUrl,
          SettingsState.defaultMirrors.first.url,
        );
      },
    );
  });
}
