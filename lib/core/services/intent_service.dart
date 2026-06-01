import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/utils/article_url_parser.dart';
import 'package:listen_sharing_intent/listen_sharing_intent.dart';

class IntentService {
  Stream<List<SharedMediaFile>> get intentStream =>
      ReceiveSharingIntent.instance.getMediaStream();

  Future<List<SharedMediaFile>> getInitialIntent() async {
    return ReceiveSharingIntent.instance.getInitialMedia();
  }
}

final intentServiceProvider = Provider((ref) => IntentService());

final intentStreamProvider = StreamProvider<String>((ref) {
  final intentService = ref.watch(intentServiceProvider);
  final controller = StreamController<String>();

  final sub = intentService.intentStream.listen((value) {
    final url = extractFirstArticleUrl(value.map((item) => item.path));
    if (url != null) {
      controller.add(url);
      ReceiveSharingIntent.instance.reset();
    }
  });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
    ReceiveSharingIntent.instance.reset();
  });

  return controller.stream;
});
