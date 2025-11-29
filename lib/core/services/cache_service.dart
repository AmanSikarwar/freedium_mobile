import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class CacheService {
  Future<bool> clearWebViewCache() async {
    try {
      final controller = WebViewController();

      await controller.clearCache();

      await controller.clearLocalStorage();

      if (controller.platform is AndroidWebViewController) {
        final androidController =
            controller.platform as AndroidWebViewController;
        await androidController.clearCache();
      }

      debugPrint('WebView cache cleared successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to clear WebView cache: $e');
      return false;
    }
  }
}

final cacheServiceProvider = Provider((ref) => CacheService());
