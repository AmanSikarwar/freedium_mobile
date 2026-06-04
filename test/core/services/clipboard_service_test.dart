import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/clipboard_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('ClipboardService', () {
    test('returns plain text clipboard contents', () async {
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        expect(call.method, 'Clipboard.getData');
        expect(call.arguments, Clipboard.kTextPlain);
        return {'text': 'https://medium.com/example/story'};
      });

      expect(
        await ClipboardService().paste(),
        'https://medium.com/example/story',
      );
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
