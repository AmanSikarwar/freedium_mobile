import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/intent_service.dart';
import 'package:receive_intent/receive_intent.dart';

import '../../test_helpers.dart';

class _ThrowingGateway() extends ReceiveIntentGateway {
  @override
  Future<Intent?> getInitialIntent() async {
    throw Exception('initial intent unavailable');
  }
}

Intent _sendIntent(String text) => Intent(
  isNull: false,
  action: 'android.intent.action.SEND',
  extra: {intentExtraText: text},
);

Intent _viewIntent(String data) =>
    Intent(isNull: false, action: 'android.intent.action.VIEW', data: data);

void main() {
  group('intentShareText', () {
    test('reads VIEW data URIs', () {
      expect(
        intentShareText(_viewIntent(' https://medium.com/example/story ')),
        'https://medium.com/example/story',
      );
    });

    test('reads SEND extra text', () {
      expect(
        intentShareText(_sendIntent('Read this: https://medium.com/x')),
        'Read this: https://medium.com/x',
      );
    });

    test('rejects null, empty and textless intents', () {
      expect(intentShareText(null), isNull);
      expect(intentShareText(const Intent()), isNull);
      expect(intentShareText(_viewIntent('   ')), isNull);
      expect(intentShareText(_sendIntent('   ')), isNull);
      expect(
        intentShareText(
          const Intent(action: 'android.intent.action.SEND', extra: {}),
        ),
        isNull,
      );
      expect(
        intentShareText(
          const Intent(
            action: 'android.intent.action.SEND',
            extra: {'other': 'https://medium.com/x'},
          ),
        ),
        isNull,
      );
    });
  });

  group('IntentService', () {
    test('delegates lookup failures to callers', () async {
      final intentService = IntentService(gateway: _ThrowingGateway());

      await expectLater(
        intentService.getInitialIntent(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('intentStreamProvider', () {
    test('emits shared article URLs without reset semantics', () async {
      final intentController = StreamController<Intent?>();
      final intentService = FakeIntentService(intentController.stream);
      final container = ProviderContainer(
        overrides: [intentServiceProvider.overrideWith((ref) => intentService)],
      );
      final emittedUrls = <String>[];
      final providerErrors = <Object>[];
      final subscription = container.listen<AsyncValue<String>>(
        intentStreamProvider,
        (_, next) {
          next.when(
            data: emittedUrls.add,
            error: (error, _) => providerErrors.add(error),
            loading: () {},
          );
        },
        fireImmediately: true,
      );
      addTearDown(() async {
        subscription.close();
        container.dispose();
        await intentController.close();
      });

      intentController.add(
        _sendIntent('Read this: https://Medium.COM/example/story/'),
      );
      await Future<void>.delayed(Duration.zero);
      intentController.add(_viewIntent('https://medium.com/example/other'));
      await Future<void>.delayed(Duration.zero);
      intentController.add(_sendIntent('no url here'));
      await Future<void>.delayed(Duration.zero);

      expect(emittedUrls, [
        TestFixtures.storyUrl,
        'https://medium.com/example/other',
      ]);
      expect(providerErrors, isEmpty);
    });

    test('keeps listening when the platform stream emits an error', () async {
      final intentController = StreamController<Intent?>();
      final intentService = FakeIntentService(intentController.stream);
      final container = ProviderContainer(
        overrides: [intentServiceProvider.overrideWith((ref) => intentService)],
      );
      final emittedUrls = <String>[];
      final providerErrors = <Object>[];
      final subscription = container.listen<AsyncValue<String>>(
        intentStreamProvider,
        (_, next) {
          next.when(
            data: emittedUrls.add,
            error: (error, _) => providerErrors.add(error),
            loading: () {},
          );
        },
        fireImmediately: true,
      );
      addTearDown(() async {
        subscription.close();
        container.dispose();
        await intentController.close();
      });

      intentController.addError(Exception('share stream unavailable'));
      await Future<void>.delayed(Duration.zero);
      intentController.add(_sendIntent(TestFixtures.storyUrl));
      await Future<void>.delayed(Duration.zero);

      expect(providerErrors, isEmpty);
      expect(emittedUrls, [TestFixtures.storyUrl]);
    });
  });
}
