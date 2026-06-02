import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/settings/application/settings_service.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsService', () {
    test(
      'loadMirrors keeps valid mirrors when another entry is malformed',
      () async {
        const customMirror = FreediumMirror(
          name: 'Custom',
          url: 'https://custom.example',
          isCustom: true,
        );
        SharedPreferences.setMockInitialValues({
          'freedium_mirrors': ['{bad json', jsonEncode(customMirror.toJson())],
        });

        final prefs = await SharedPreferences.getInstance();
        final service = SettingsService(prefs);

        expect(service.loadMirrors(), [customMirror]);
      },
    );

    test('loadMirrors skips invalid and duplicate mirror entries', () async {
      const customMirror = FreediumMirror(
        name: 'Custom',
        url: 'https://custom.example',
        isCustom: true,
      );
      SharedPreferences.setMockInitialValues({
        'freedium_mirrors': [
          jsonEncode({'name': '', 'url': 'https://blank-name.example'}),
          jsonEncode({'name': 'Missing host', 'url': 'https://'}),
          jsonEncode({
            'name': 'Unsupported scheme',
            'url': 'ftp://example.com',
          }),
          jsonEncode(customMirror.toJson()),
          jsonEncode(customMirror.copyWith(name: 'Duplicate').toJson()),
        ],
      });

      final prefs = await SharedPreferences.getInstance();
      final service = SettingsService(prefs);

      expect(service.loadMirrors(), [customMirror]);
    });

    test('loadMirrors normalizes mirror names and URL origins', () async {
      SharedPreferences.setMockInitialValues({
        'freedium_mirrors': [
          jsonEncode({
            'name': ' Custom ',
            'url': ' HTTPS://Custom.Example/ ',
            'isCustom': true,
          }),
        ],
      });

      final prefs = await SharedPreferences.getInstance();
      final service = SettingsService(prefs);

      expect(service.loadMirrors(), [
        const FreediumMirror(
          name: 'Custom',
          url: 'https://custom.example',
          isCustom: true,
        ),
      ]);
    });

    test('loadAllSettings normalizes persisted selected mirror URL', () async {
      const customMirror = FreediumMirror(
        name: 'Custom',
        url: 'https://custom.example',
        isCustom: true,
      );
      SharedPreferences.setMockInitialValues({
        'freedium_mirrors': [jsonEncode(customMirror.toJson())],
        'selected_mirror_url': ' HTTPS://Custom.Example/ ',
      });

      final prefs = await SharedPreferences.getInstance();
      final service = SettingsService(prefs);

      final settings = service.loadAllSettings();

      expect(settings.mirrors, [customMirror]);
      expect(settings.selectedMirrorUrl, customMirror.url);
    });

    test(
      'loadMirrors falls back to defaults when every entry is invalid',
      () async {
        SharedPreferences.setMockInitialValues({
          'freedium_mirrors': ['{bad json'],
        });

        final prefs = await SharedPreferences.getInstance();
        final service = SettingsService(prefs);

        expect(service.loadMirrors(), SettingsState.defaultMirrors);
      },
    );

    test(
      'loadAllSettings falls back when selected mirror is missing',
      () async {
        const customMirror = FreediumMirror(
          name: 'Custom',
          url: 'https://custom.example',
          isCustom: true,
        );
        SharedPreferences.setMockInitialValues({
          'freedium_mirrors': [jsonEncode(customMirror.toJson())],
          'selected_mirror_url': 'https://missing.example',
          'auto_switch_mirror': false,
        });

        final prefs = await SharedPreferences.getInstance();
        final service = SettingsService(prefs);

        final settings = service.loadAllSettings();

        expect(settings.mirrors, [customMirror]);
        expect(settings.selectedMirrorUrl, customMirror.url);
        expect(settings.autoSwitchMirror, isFalse);
      },
    );

    test('loadAllSettings clamps persisted numeric preferences', () async {
      SharedPreferences.setMockInitialValues({
        'default_font_size': 100.0,
        'mirror_timeout': 0,
      });

      final prefs = await SharedPreferences.getInstance();
      final service = SettingsService(prefs);

      final settings = service.loadAllSettings();

      expect(settings.defaultFontSize, SettingsState.maxDefaultFontSize);
      expect(settings.mirrorTimeout, SettingsState.minMirrorTimeout);
    });

    test('save numeric preferences clamps out-of-range values', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = SettingsService(prefs);

      await service.saveDefaultFontSize(1);
      await service.saveMirrorTimeout(100);

      expect(
        prefs.getDouble('default_font_size'),
        SettingsState.minDefaultFontSize,
      );
      expect(prefs.getInt('mirror_timeout'), SettingsState.maxMirrorTimeout);
    });
  });
}
