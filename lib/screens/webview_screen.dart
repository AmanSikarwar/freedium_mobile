import 'package:flutter/material.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({
    required this.url,
    super.key,
  });

  final String url;

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  late final WebViewController _controller;
  bool _pageLoaded = false;

  static const String _urlPrefix = 'https://freedium.cfd';

  @override
  void initState() {
    const params = PlatformWebViewControllerCreationParams();

    if (!Uri.parse(widget.url).isAbsolute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
      Navigator.of(context).pop();
      return;
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            setState(() => _pageLoaded = true);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Error loading page: ${error.description}');
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('Error occurred on page: ${error.response?.statusCode}');
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
          onHttpAuthRequest: (HttpAuthRequest request) {
            // openDialog(request);
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..addJavaScriptChannel(
        'Clipboard',
        onMessageReceived: (JavaScriptMessage message) {
          final clipboard = SystemClipboard.instance!;
          final item = DataWriterItem();
          item.add(Formats.plainText(message.message));
          clipboard.write([item]);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copied to clipboard!')),
          );
        },
      )
      ..loadRequest(
        Uri.parse(_urlPrefix).replace(path: widget.url),
      );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.surfaceBright;
    return Scaffold(
      backgroundColor: _pageLoaded ? backgroundColor : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _controller.reload();
          },
          child: _pageLoaded
              ? WebViewWidget(
                  controller: _controller,
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
      floatingActionButton: _pageLoaded
          ? FloatingActionButton.small(
              onPressed: () {
                Share.shareUri(Uri.parse(_urlPrefix).replace(path: widget.url));
              },
              child: const Icon(Icons.share),
            )
          : null,
    );
  }
}
