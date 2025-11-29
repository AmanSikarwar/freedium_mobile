import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/features/webview/presentation/widgets/article_shimmer.dart';
import 'package:freedium_mobile/features/webview/presentation/widgets/font_settings_sheet.dart';
import 'package:freedium_mobile/features/home/presentation/home_screen.dart';
import 'package:freedium_mobile/features/webview/application/theme_injector_service.dart';
import 'package:freedium_mobile/features/webview/domain/webview_state.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:listen_sharing_intent/listen_sharing_intent.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends ConsumerStatefulWidget {
  const WebviewScreen({required this.url, super.key});

  final String url;

  @override
  ConsumerState<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends ConsumerState<WebviewScreen> {
  bool _isVisible = true;
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebView();
    });
  }

  void _initializeWebView() {
    final webviewNotifier = ref.read(webviewProvider(widget.url).notifier);
    final themeInjector = ref.read(themeInjectorServiceProvider);
    webviewNotifier.setThemeInjector(themeInjector, context);
    _controller = webviewNotifier.createController();
    setState(() {});
  }

  @override
  void dispose() {
    ReceiveSharingIntent.instance.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webviewState = ref.watch(webviewProvider(widget.url));
    final webviewNotifier = ref.read(webviewProvider(widget.url).notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }

        final navigator = Navigator.of(context);

        if (await webviewNotifier.canGoBack()) {
          webviewNotifier.goBack();
          return;
        }

        if (navigator.canPop()) {
          if (mounted) {
            setState(() {
              _isVisible = false;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ReceiveSharingIntent.instance.reset();
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
                ReceiveSharingIntent.instance.reset();
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
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
    WebviewState webviewState,
    WebviewNotifier webviewNotifier,
  ) {
    if (!_isVisible) {
      return Scaffold(backgroundColor: Theme.of(context).colorScheme.surface);
    }

    final backgroundColor = Theme.of(context).colorScheme.surface;
    final bool isThemedPage =
        webviewState.currentUrl?.startsWith(AppConstants.freediumUrl) ?? false;
    final bool showWebView =
        webviewState.isPageLoaded &&
        (isThemedPage ? webviewState.isThemeApplied : true);

    return Scaffold(
      backgroundColor: showWebView ? backgroundColor : null,
      body: SafeArea(
        child: Stack(
          children: [
            if (_controller != null) WebViewWidget(controller: _controller!),
            if (!webviewState.isPageLoaded && webviewState.progress < 1.0)
              LinearProgressIndicator(
                value: webviewState.progress > 0 ? webviewState.progress : null,
              ),
            if (!webviewState.isPageLoaded && webviewState.progress < 0.7)
              const ArticleShimmer(),
          ],
        ),
      ),
      floatingActionButton: showWebView ? _buildActionButtons() : null,
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    final webviewState = ref.watch(webviewProvider(widget.url));
    final webviewNotifier = ref.read(webviewProvider(widget.url).notifier);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: theme.colorScheme.primaryContainer,
            type: MaterialType.circle,
            child: InkWell(
              splashColor: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.1,
              ),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(30),
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => FontSettingsSheet(
                    initialFontSize: webviewState.fontSize,
                    onFontSizeChanged: (fontSize) {
                      webviewNotifier.updateFontSize(fontSize);
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Icon(
                  Icons.text_fields,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          Material(
            color: theme.colorScheme.primaryContainer,
            type: MaterialType.circle,
            child: InkWell(
              splashColor: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.1,
              ),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(30),
              ),
              onTap: () {
                SharePlus.instance.share(
                  ShareParams(
                    subject: 'Read this article without Paywall',
                    title: 'Share Freedium link',
                    uri: Uri.parse(
                      AppConstants.freediumUrl,
                    ).replace(path: widget.url),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Icon(
                  Icons.share,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final themeInjectorServiceProvider = Provider((ref) => ThemeInjectorService());
