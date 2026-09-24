import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class CacheService() {
  /// Clears WebView cache and local storage.
  ///
  /// Pass the live [controller] when available (e.g. from an open
  /// `WebviewScreen`) so the actual view's cache is cleared. Without it,
  /// falls back to a best-effort global clear via a throwaway controller,
  /// which is a no-op for the live view on most platforms.
  Future<bool> clearWebViewCache({WebViewController? controller}) async {
    try {
      final target = controller ?? WebViewController();

      await target.clearCache();

      await target.clearLocalStorage();

      if (Platform.isAndroid) {
        if (target.platform
            case final AndroidWebViewController androidController) {
          await androidController.clearCache();
        }
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
