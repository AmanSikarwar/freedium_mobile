import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/clipboard_service.dart';

import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    messenger.setMockMethodCallHandler(
      const MethodChannel('freedium/clipboard'),
      null,
    );
  });

  group('ClipboardService', () {
    test('automatic detection uses the URL-only native channel', () async {
      messenger.setMockMethodCallHandler(
        const MethodChannel('freedium/clipboard'),
        (call) async {
          expect(call.method, 'readUrl');
          return TestFixtures.storyUrl;
        },
      );
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        fail('Automatic detection must not read the raw clipboard');
      });
      expect(await ClipboardService().detectUrl(), TestFixtures.storyUrl);
    });

    test(
      'unavailable URL detection does not fall back to a raw read',
      () async {
        messenger.setMockMethodCallHandler(
          const MethodChannel('freedium/clipboard'),
          (call) async {
            throw MissingPluginException();
          },
        );
        messenger.setMockMethodCallHandler(SystemChannels.platform, (
          call,
        ) async {
          fail('Automatic detection must fail closed');
        });
        expect(await ClipboardService().detectUrl(), isNull);
      },
    );

    test('returns plain text clipboard contents', () async {
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        expect(call.method, 'Clipboard.getData');
        expect(call.arguments, Clipboard.kTextPlain);
        return {'text': TestFixtures.storyUrl};
      });

      expect(await ClipboardService().paste(), TestFixtures.storyUrl);
    });

    test('returns null when the platform clipboard call fails', () async {
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        throw PlatformException(
          code: 'clipboard_unavailable',
          message: 'Clipboard unavailable',
        );
      });

      expect(await ClipboardService().paste(), isNull);
    });
  });
}
