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
  });
}
