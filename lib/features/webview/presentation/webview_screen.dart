import 'package:material_3_expressive/material_3_expressive.dart';

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';
import 'package:freedium_mobile/features/webview/presentation/widgets/font_settings_sheet.dart';
import 'package:freedium_mobile/features/webview/presentation/widgets/reader_loading_overlays.dart';
import 'package:freedium_mobile/features/webview/presentation/widgets/reader_webview.dart';
import 'package:freedium_mobile/features/home/presentation/home_screen.dart';
import 'package:freedium_mobile/features/webview/application/initial_mirror_resolver.dart';
import 'package:freedium_mobile/features/webview/domain/webview_state.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

@visibleForTesting
bool shouldRevealWebView({
  required bool isPageLoaded,
  required bool isThemeApplied,
  required bool isThemedPage,
  required bool hasError,
  bool useOriginalStyling = false,
}) {
  return isPageLoaded &&
      !hasError &&
      (!isThemedPage || isThemeApplied || useOriginalStyling);
}

typedef _WebviewPresentationState = ({
  String? currentUrl,
  bool isPageLoaded,
  bool isThemeApplied,
  bool useOriginalStyling,
  bool hasError,
  String? errorMessage,
  String activeBaseUrl,
});

class const WebviewScreen({required this.url, super.key})
    extends ConsumerStatefulWidget {
  final String url;

  @override
  ConsumerState<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState()
    extends ConsumerState<WebviewScreen>
    with WidgetsBindingObserver {
  String get _articleUrl =>
      ref.read(webviewProvider(widget.url).notifier).articleUrl();

  bool _isVisible = true;
  WebViewWidget? _webViewWidget;
  ColorScheme? _prevColorScheme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebView();
    });
  }

  Future<void> _initializeWebView() async {
    final webviewNotifier = ref.read(webviewProvider(widget.url).notifier);
    final themeInjector = ref.read(themeInjectorServiceProvider);
    final freediumUrlService = ref.read(freediumUrlServiceProvider);
    final settings = ref.read(settingsProvider).value ?? const SettingsState();
    final initialMirrorUrl = await resolveInitialMirrorUrl(
      autoSwitchMirror: settings.autoSwitchMirror,
      selectedMirrorUrl: settings.selectedMirrorUrl,
      getActiveUrl: freediumUrlService.getActiveUrl,
      timeout: Duration(seconds: settings.mirrorTimeout),
    );

    if (!mounted) return;
    webviewNotifier.setThemeInjector(themeInjector);
    final controller = webviewNotifier.createController(
      baseUrl: initialMirrorUrl,
    );
    final webViewWidget = await createReaderWebView(controller);
    if (!mounted) return;
    setState(() => _webViewWidget = webViewWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final webviewNotifier = ref.read(webviewProvider(widget.url).notifier);
    final colorScheme = Theme.of(context).colorScheme;
    if (_prevColorScheme != colorScheme) {
      unawaited(webviewNotifier.updateColorScheme(colorScheme));
      _prevColorScheme = colorScheme;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      unawaited(
        ref.read(webviewProvider(widget.url).notifier).flushReadingProgress(),
      );
    }
  }

  Future<void> _toggleBookmark(Bookmarks bookmarksNotifier) async {
    final articleUrl = _articleUrl;
    final title =
        ref.read(webviewProvider(widget.url)).articleMeta?.title ?? '';
    final wasBookmarked = bookmarksNotifier.isBookmarked(articleUrl);
    final didSave = await bookmarksNotifier.toggleBookmark(articleUrl, title);
    if (!mounted || didSave) return;

    HapticFeedback.heavyImpact();
    M3ESnackbar.show(
      context,
      message: !wasBookmarked && bookmarksNotifier.isAtCapacity()
          ? Bookmarks.limitMessage
          : 'Failed to update bookmark',
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final webviewState = ref.watch(
      webviewProvider(widget.url).select(
        (state) => (
          currentUrl: state.currentUrl,
          isPageLoaded: state.isPageLoaded,
          isThemeApplied: state.isThemeApplied,
          useOriginalStyling: state.useOriginalStyling,
          hasError: state.hasError,
          errorMessage: state.errorMessage,
          activeBaseUrl: state.activeBaseUrl,
        ),
      ),
    );
    final webviewNotifier = ref.read(webviewProvider(widget.url).notifier);

    // Listen for one-shot user messages and display them as snackbars.
    ref.listen<WebviewState>(webviewProvider(widget.url), (previous, next) {
      if (next.userMessage != null &&
          next.userMessage != previous?.userMessage) {
        M3ESnackbar.show(
          context,
          message: next.userMessage!,
          duration: const Duration(seconds: 2),
        );
        webviewNotifier.clearUserMessage();
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }

        final navigator = Navigator.of(context);
        final shouldUseAppBack = webviewNotifier
            .shouldUseAppLevelBackNavigation();

        if (!shouldUseAppBack && await webviewNotifier.canGoBack()) {
          await webviewNotifier.goBack();
          return;
        }

        await webviewNotifier.flushReadingProgress();
        if (!mounted) return;

        if (navigator.canPop()) {
          if (mounted) {
            setState(() {
              _isVisible = false;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                navigator.pop();
              }
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isVisible = false;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                navigator.pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              }
            });
          }
        }
      },
      child: _buildWebView(webviewState, webviewNotifier),
    );
  }

  Widget _buildWebView(
    _WebviewPresentationState webviewState,
    Webview webviewNotifier,
  ) {
    if (!_isVisible) {
      return Scaffold(backgroundColor: Theme.of(context).colorScheme.surface);
    }

    final backgroundColor = Theme.of(context).colorScheme.surface;
    final freediumUrlService = ref.read(freediumUrlServiceProvider);
    final bool isThemedPage = freediumUrlService.isFreediumUrl(
      webviewState.currentUrl ?? '',
    );
    final showWebView = shouldRevealWebView(
      isPageLoaded: webviewState.isPageLoaded,
      isThemeApplied: webviewState.isThemeApplied,
      isThemedPage: isThemedPage,
      hasError: webviewState.hasError,
      useOriginalStyling: webviewState.useOriginalStyling,
    );
    final hideThemedWebView = isThemedPage && !showWebView;

    return Scaffold(
      backgroundColor: showWebView ? backgroundColor : null,
      body: SafeArea(
        child: Stack(
          children: [
            if (_webViewWidget != null && !webviewState.hasError)
              Visibility(
                visible: !hideThemedWebView,
                maintainState: true,
                child: _webViewWidget!,
              ),
            ReaderProgressIndicator(url: widget.url),
            ReaderArticleShimmer(
              url: widget.url,
              hideWebView: hideThemedWebView,
            ),
            if (webviewState.hasError)
              _buildErrorWidget(webviewState, webviewNotifier),
            if (showWebView) _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(
    _WebviewPresentationState webviewState,
    Webview webviewNotifier,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const .all(24.0),
        child: Column(
          mainAxisSize: .min,
          children: [
            Icon(Icons.cloud_off, size: 80, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Article',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: .bold),
            ),
            const SizedBox(height: 8),
            Text(
              webviewState.errorMessage ?? 'An error occurred',
              textAlign: .center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Current mirror: ${webviewState.activeBaseUrl}',
              textAlign: .center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (webviewNotifier.canContinueWithoutStyling()) ...[
              const SizedBox(height: 16),
              M3EButton.filled(
                onPressed: webviewNotifier.continueWithoutStyling,
                child: const Text('Continue with original styling'),
              ),
            ],
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                M3EButton.outlined(
                  onPressed: () => webviewNotifier.reload(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                M3EButton.filled(
                  onPressed: () => webviewNotifier.retryWithNextMirror(),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Try Another Mirror'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final fontSize = ref.watch(
      webviewProvider(widget.url).select((state) => state.fontSize),
    );
    final webviewNotifier = ref.read(webviewProvider(widget.url).notifier);
    final bookmarksNotifier = ref.read(bookmarksProvider.notifier);
    final articleUrl = webviewNotifier.articleUrl();
    final isBookmarked = ref.watch(
      bookmarksProvider.select(
        (bookmarks) => (bookmarks.value ?? const <BookmarkedArticle>[]).any(
          (b) => b.url == articleUrl,
        ),
      ),
    );

    return M3EToolbar(
      alignment: Alignment.bottomCenter,
      semanticLabel: 'Reader actions',
      actions: [
        M3EToolbarAction(
          icon: Icons.text_fields,
          tooltip: 'Font size',
          onPressed: () {
            showFontSettingsSheet(
              context,
              initialFontSize: fontSize,
              onFontSizeChanged: webviewNotifier.updateFontSize,
            );
          },
        ),
        M3EToolbarAction(
          icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          tooltip: isBookmarked ? 'Remove bookmark' : 'Save bookmark',
          semanticLabel: isBookmarked ? 'Remove bookmark' : 'Save bookmark',
          onPressed: () {
            HapticFeedback.lightImpact();
            unawaited(_toggleBookmark(bookmarksNotifier));
          },
        ),
        M3EToolbarAction(
          icon: Icons.share,
          tooltip: 'Share article',
          onPressed: () => unawaited(webviewNotifier.shareArticle()),
        ),
      ],
    );
  }
}
