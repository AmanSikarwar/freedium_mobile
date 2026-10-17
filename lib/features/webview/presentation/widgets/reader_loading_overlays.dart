import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';
import 'package:freedium_mobile/features/webview/presentation/widgets/article_shimmer.dart';
import 'package:material_ui/material_ui.dart';

class const ReaderProgressIndicator({super.key, required this.url})
    extends ConsumerWidget {
  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readerProgress = ref.watch(
      webviewProvider(url).select(
        (state) => (
          progress: state.progress,
          isPageLoaded: state.isPageLoaded,
          hasError: state.hasError,
        ),
      ),
    );

    if (readerProgress.isPageLoaded ||
        readerProgress.progress >= 1.0 ||
        readerProgress.hasError) {
      return const SizedBox.shrink();
    }

    return M3EProgressIndicator.linearWavy(
      value: readerProgress.progress > 0 ? readerProgress.progress : null,
    );
  }
}

class const ReaderArticleShimmer({
  super.key,
  required this.url,
  required this.hideWebView,
}) extends ConsumerWidget {
  final String url;
  final bool hideWebView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showShimmer = ref.watch(
      webviewProvider(url).select(
        (state) =>
            (!state.isPageLoaded && state.progress < 0.7 || hideWebView) &&
            !state.hasError,
      ),
    );

    return showShimmer ? const ArticleShimmer() : const SizedBox.shrink();
  }
}
