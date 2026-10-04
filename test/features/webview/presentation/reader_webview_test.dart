import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/webview/presentation/widgets/reader_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../webview_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late WebViewController controller;

  setUp(() {
    WebViewPlatform.instance = FakeWebviewPlatform();
    controller = WebViewController();
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(readerPlatformChannel, null);
  });

  for (final sdk in [28, 29, 33, 36]) {
    test('Android API $sdk selects the reader composition safely', () async {
      WebViewPlatform.instance = AndroidWebViewPlatform();
      messenger.setMockMethodCallHandler(readerPlatformChannel, (call) async {
        expect(call.method, 'getAndroidSdkVersion');
        return sdk;
      });
      final widget = await createReaderWebView(controller);
      final params =
          widget.platform.params as AndroidWebViewWidgetCreationParams;
      expect(params.displayWithHybridComposition, sdk >= 29);
      expect(params.controller, same(controller.platform));
      expect(params.gestureRecognizers, isEmpty);
    });
  }

  test('missing Android capability channel still opens the reader', () async {
    WebViewPlatform.instance = AndroidWebViewPlatform();
    final widget = await createReaderWebView(controller);
    expect(
      (widget.platform.params as AndroidWebViewWidgetCreationParams)
          .displayWithHybridComposition,
      isFalse,
    );
  });

  test('failed Android capability lookup retains the default mode', () async {
    WebViewPlatform.instance = AndroidWebViewPlatform();
    messenger.setMockMethodCallHandler(readerPlatformChannel, (call) async {
      throw PlatformException(code: 'unavailable');
    });
    final widget = await createReaderWebView(controller);
    expect(
      (widget.platform.params as AndroidWebViewWidgetCreationParams)
          .displayWithHybridComposition,
      isFalse,
    );
  });

  test(
    'other platforms use their normal params without a native lookup',
    () async {
      messenger.setMockMethodCallHandler(readerPlatformChannel, (call) async {
        fail('Android channel invoked for another platform');
      });
      final widget = await createReaderWebView(controller);
      expect(
        widget.platform.params,
        isNot(isA<AndroidWebViewWidgetCreationParams>()),
      );
      expect(widget.platform.params.controller, same(controller.platform));
    },
  );
}
