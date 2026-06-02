import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

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
}
