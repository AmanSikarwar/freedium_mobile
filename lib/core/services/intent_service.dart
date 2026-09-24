import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freedium_mobile/core/utils/article_url_parser.dart';
import 'package:listen_sharing_intent/listen_sharing_intent.dart';

part 'intent_service.g.dart';

class IntentService({ReceiveSharingIntent? sharingIntent}) {
  this : _sharingIntent = sharingIntent ?? ReceiveSharingIntent.instance;

  final ReceiveSharingIntent _sharingIntent;

  Stream<List<SharedMediaFile>> get intentStream =>
      _sharingIntent.getMediaStream();

  Future<List<SharedMediaFile>> getInitialIntent() async {
    return _sharingIntent.getInitialMedia();
  }

  Future<void> reset() async {
    try {
      await _sharingIntent.reset();
    } catch (e) {
      debugPrint('Failed to reset sharing intent: $e');
    }
  }
}

@Riverpod(keepAlive: true)
IntentService intentService(Ref ref) => IntentService();

@Riverpod(keepAlive: true)
Stream<String> intentStream(Ref ref) {
  final intentService = ref.watch(intentServiceProvider);
  final controller = StreamController<String>();

  void closeController() {
    if (!controller.isClosed) {
      unawaited(controller.close());
    }
  }

  final sub = intentService.intentStream.listen(
    (value) {
      if (controller.isClosed) return;

      final url = extractFirstArticleUrl(value.map((item) => item.path));
      if (url != null) {
        controller.add(url);
        unawaited(intentService.reset());
      }
    },
    onError: (Object e, StackTrace stack) {
      debugPrint('Incoming intent stream failed: $e');
    },
    onDone: closeController,
  );

  ref.onDispose(() {
    unawaited(sub.cancel());
    closeController();
    unawaited(intentService.reset());
  });

  return controller.stream;
}
