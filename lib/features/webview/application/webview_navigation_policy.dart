import 'package:freedium_mobile/core/utils/external_url_launcher.dart'
    show parseExternalHttpUrl;
import 'package:freedium_mobile/features/history/domain/reading_history.dart'
    show normalizeReadingProgress;

/// Navigation policy for WebView requests, shared by the [Webview] notifier
/// and covered directly by `webview_navigation_policy_test.dart`.
enum WebviewNavigationAction() {
  navigate,
  launchExternal,
  block,
}

WebviewNavigationAction resolveWebviewNavigationAction({
  required String requestUrl,
  required bool Function(String url) isFreediumUrl,
}) {
  final uri = parseExternalHttpUrl(requestUrl);
  if (uri == null) {
    return WebviewNavigationAction.block;
  }

  if (isFreediumUrl(uri.toString())) {
    return WebviewNavigationAction.navigate;
  }

  return WebviewNavigationAction.launchExternal;
}

String buildReadingProgressRestoreScript(double progress) {
  final normalizedProgress = normalizeReadingProgress(progress);
  return '''
    (function () {
      const progress = $normalizedProgress;
      const restore = function () {
        const root = document.documentElement;
        const height = Math.max(root.scrollHeight, document.body.scrollHeight);
        const scrollable = Math.max(0, height - window.innerHeight);
        window.scrollTo(0, Math.round(scrollable * progress));
      };
      requestAnimationFrame(restore);
      setTimeout(restore, 300);
      setTimeout(restore, 1000);
    })();
  ''';
}
