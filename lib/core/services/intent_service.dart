import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:receive_intent/receive_intent.dart' as platform;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freedium_mobile/core/utils/article_url_parser.dart';

part 'intent_service.g.dart';

/// Extra key carrying shared text in SEND intents.
const String intentExtraText = 'android.intent.extra.TEXT';

/// Extracts shareable text from a raw platform intent: the data URI for
/// VIEW intents, `EXTRA_TEXT` otherwise. Returns null for null/empty or
/// textless intents. URL validation stays with [extractArticleUrl].
String? intentShareText(platform.Intent? intent) {
  if (intent == null || intent.isNull) return null;
  if (intent.action == 'android.intent.action.VIEW') {
    final data = intent.data?.trim();
    return (data == null || data.isEmpty) ? null : data;
  }
  final text = intent.extra?[intentExtraText];
  if (text is! String) return null;
  return text.trim().isEmpty ? null : text;
}

/// Thin seam over the static ReceiveIntent API for testability.
class const ReceiveIntentGateway() {
  Future<platform.Intent?> getInitialIntent() =>
      platform.ReceiveIntent.getInitialIntent();

  Stream<platform.Intent?> get intentStream =>
      platform.ReceiveIntent.receivedIntentStream;
}

class IntentService({this.gateway = const ReceiveIntentGateway()}) {
  final ReceiveIntentGateway gateway;

  Stream<platform.Intent?> get intentStream => gateway.intentStream;

  /// NOTE: the plugin replays the launching intent on every call (there is
  /// no reset API), so callers must consume the result exactly once.
  Future<platform.Intent?> getInitialIntent() => gateway.getInitialIntent();
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
    (intent) {
      if (controller.isClosed) return;

      final text = intentShareText(intent);
      final url = text == null ? null : extractArticleUrl(text);
      if (url != null) {
        controller.add(url);
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
  });

  return controller.stream;
}
