import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';

/// Metadata extracted from the article DOM via the ArticleMeta JS channel.
/// All fields default to empty string — extraction is best-effort.
@immutable
class ArticleMeta {
  final String title;
  final String author;
  final String readTime;
  final String heroImageUrl;

  const ArticleMeta({
    this.title = '',
    this.author = '',
    this.readTime = '',
    this.heroImageUrl = '',
  });

  bool get hasContent => author.isNotEmpty || readTime.isNotEmpty;
}

/// WebView feature state.
///
/// NOTE: [controller] is mutable by design — the WebViewController is created
/// once per notifier instance and must be held here so both the notifier and
/// screen widget share the same reference without re-creating it on every state
/// rebuild. It is never replaced after initial creation.
class WebviewState {
  final double progress;
  final bool isPageLoaded;
  final bool isThemeApplied;
  final bool isInitialLoad;
  // ignore: invalid_annotation_target
  final WebViewController? controller; // intentionally mutable — see class doc
  final double fontSize;
  final String? currentUrl;
  final String activeBaseUrl;
  final bool hasError;
  final String? errorMessage;

  /// One-shot message for the UI layer to display as a SnackBar.
  /// The screen clears this after display via [WebviewNotifier.clearUserMessage].
  final String? userMessage;

  /// Article metadata extracted from the Freedium DOM (Phase 3).
  final ArticleMeta? articleMeta;

  WebviewState({
    this.progress = 0.0,
    this.isPageLoaded = false,
    this.isThemeApplied = false,
    this.isInitialLoad = true,
    this.controller,
    this.fontSize = 18.0,
    this.currentUrl,
    this.activeBaseUrl = AppConstants.freediumUrl,
    this.hasError = false,
    this.errorMessage,
    this.userMessage,
    this.articleMeta,
  });

  WebviewState copyWith({
    double? progress,
    bool? isPageLoaded,
    bool? isThemeApplied,
    bool? isInitialLoad,
    WebViewController? controller,
    double? fontSize,
    String? currentUrl,
    String? activeBaseUrl,
    bool? hasError,
    String? errorMessage,
    String? userMessage,

    /// Pass [clearUserMessage] = true to null-out [userMessage] after display.
    bool clearUserMessage = false,
    ArticleMeta? articleMeta,
    bool clearArticleMeta = false,
  }) {
    return WebviewState(
      progress: progress ?? this.progress,
      isPageLoaded: isPageLoaded ?? this.isPageLoaded,
      isThemeApplied: isThemeApplied ?? this.isThemeApplied,
      isInitialLoad: isInitialLoad ?? this.isInitialLoad,
      controller: controller ?? this.controller,
      fontSize: fontSize ?? this.fontSize,
      currentUrl: currentUrl ?? this.currentUrl,
      activeBaseUrl: activeBaseUrl ?? this.activeBaseUrl,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      userMessage: clearUserMessage ? null : (userMessage ?? this.userMessage),
      articleMeta: clearArticleMeta ? null : (articleMeta ?? this.articleMeta),
    );
  }
}
