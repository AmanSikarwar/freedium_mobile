import 'package:flutter/foundation.dart';

typedef ActiveFreediumUrlResolver = Future<String> Function();

Future<String> resolveInitialMirrorUrl({
  required bool autoSwitchMirror,
  required String selectedMirrorUrl,
  required ActiveFreediumUrlResolver getActiveUrl,
  Duration timeout = const Duration(seconds: 5),
}) async {
  if (!autoSwitchMirror) {
    return selectedMirrorUrl;
  }

  try {
    return await getActiveUrl().timeout(timeout);
  } catch (e) {
    debugPrint('Initial mirror selection failed: $e');
    return selectedMirrorUrl;
  }
}
