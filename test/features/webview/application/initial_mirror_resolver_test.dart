import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/webview/application/initial_mirror_resolver.dart';

void main() {
  group('resolveInitialMirrorUrl', () {
    test('uses selected mirror when auto-switch is disabled', () async {
      var didResolveActiveUrl = false;

      final url = await resolveInitialMirrorUrl(
        autoSwitchMirror: false,
        selectedMirrorUrl: 'https://selected.example',
        getActiveUrl: () async {
          didResolveActiveUrl = true;
          return 'https://active.example';
        },
      );

      expect(url, 'https://selected.example');
      expect(didResolveActiveUrl, isFalse);
    });

    test('uses active mirror when auto-switch is enabled', () async {
      final url = await resolveInitialMirrorUrl(
        autoSwitchMirror: true,
        selectedMirrorUrl: 'https://selected.example',
        getActiveUrl: () async => 'https://active.example',
      );

      expect(url, 'https://active.example');
    });

    test(
      'falls back to selected mirror when active mirror lookup fails',
      () async {
        final url = await resolveInitialMirrorUrl(
          autoSwitchMirror: true,
          selectedMirrorUrl: 'https://selected.example',
          getActiveUrl: () async => throw Exception('network failed'),
        );

        expect(url, 'https://selected.example');
      },
    );
  });
}
