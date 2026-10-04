import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/utils/url.dart';
import 'package:freedium_mobile/features/settings/application/settings_service.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

import '../../../test_helpers.dart';

void main() {
  test('production mirror policy requires HTTPS including on loopback', () {
    for (final host in ['mirror.example', 'localhost', '127.0.0.1', '[::1]']) {
      expect(normalizeMirrorUrl('http://$host', allowLocalHttp: false), isNull);
    }
    expect(
      normalizeMirrorUrl(
        ' HTTPS://Mirror.Example/base///?x=1#top ',
        allowLocalHttp: false,
      ),
      'https://mirror.example/base',
    );
  });

  test('debug mirror policy permits only local HTTP fixtures', () {
    for (final host in ['localhost', '127.0.0.1', '[::1]']) {
      expect(normalizeMirrorUrl('http://$host:8787/good'), isNotNull);
    }
    for (final host in [
      'mirror.example',
      'localhost.evil.example',
      '127.0.0.1.evil.example',
    ]) {
      expect(normalizeMirrorUrl('http://$host'), isNull);
    }
  });

  test('stored public HTTP mirrors fall back to a usable default', () async {
    final prefs = await mockPrefs({
      'freedium_mirrors': [
        jsonEncode(
          const FreediumMirror(
            name: 'Insecure',
            url: 'http://mirror.example',
          ).toJson(),
        ),
      ],
      'selected_mirror_url': 'http://mirror.example',
    });
    final settings = SettingsService(prefs).loadAllSettings();
    expect(settings.mirrors, SettingsState.defaultMirrors);
    expect(settings.selectedMirrorUrl, SettingsState.defaultMirrors.first.url);
  });
}
