import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/intent_service.dart';
import 'package:listen_sharing_intent/listen_sharing_intent.dart';

class _ThrowingResetSharingIntent extends ReceiveSharingIntent {
  int resetRequests = 0;

  @override
  Future<List<SharedMediaFile>> getInitialMedia() async => <SharedMediaFile>[];

  @override
  Stream<List<SharedMediaFile>> getMediaStream() => const Stream.empty();

  @override
  Future<dynamic> reset() async {
    resetRequests++;
    throw Exception('reset unavailable');
  }
}

class _FakeIntentService extends IntentService {
  _FakeIntentService(this._intentStream);

  final Stream<List<SharedMediaFile>> _intentStream;
  int resetRequests = 0;

  @override
  Stream<List<SharedMediaFile>> get intentStream => _intentStream;

  @override
  Future<List<SharedMediaFile>> getInitialIntent() async => <SharedMediaFile>[];

  @override
  Future<void> reset() async {
    resetRequests++;
  }
}

void main() {
  group('IntentService', () {
    test('suppresses plugin reset failures', () async {
      final sharingIntent = _ThrowingResetSharingIntent();
      final intentService = IntentService(sharingIntent: sharingIntent);

      await intentService.reset();

      expect(sharingIntent.resetRequests, 1);
    });
  });

  group('intentStreamProvider', () {
    test('emits shared article URLs and resets consumed intents', () async {
      final mediaController = StreamController<List<SharedMediaFile>>();
      final intentService = _FakeIntentService(mediaController.stream);
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
        await mediaController.close();
      });

      mediaController.add([
        SharedMediaFile(
          path: 'Read this: https://Medium.COM/example/story/',
          type: SharedMediaType.text,
        ),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(emittedUrls, ['https://medium.com/example/story']);
      expect(providerErrors, isEmpty);
      expect(intentService.resetRequests, 1);
    });

    test('keeps listening when the platform stream emits an error', () async {
      final mediaController = StreamController<List<SharedMediaFile>>();
      final intentService = _FakeIntentService(mediaController.stream);
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
        await mediaController.close();
      });

      mediaController.addError(Exception('share stream unavailable'));
      await Future<void>.delayed(Duration.zero);
      mediaController.add([
        SharedMediaFile(
          path: 'https://medium.com/example/story',
          type: SharedMediaType.text,
        ),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(providerErrors, isEmpty);
      expect(emittedUrls, ['https://medium.com/example/story']);
      expect(intentService.resetRequests, 1);
    });
  });
}
