import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';

part 'webview_state.freezed.dart';

/// Metadata extracted from the article DOM via the ArticleMeta JS channel.
/// All fields default to empty string — extraction is best-effort.
@freezed
abstract class const ArticleMeta._() with _$ArticleMeta {
  const factory ArticleMeta({
    @Default('') String title,
    @Default('') String author,
    @Default('') String readTime,
    @Default('') String heroImageUrl,
  }) = _ArticleMeta;

  bool get hasContent => author.isNotEmpty || readTime.isNotEmpty;
}

/// WebView feature UI state.
///
/// NOTE: the [WebViewController] is intentionally NOT part of this state.
/// It is mutable, non-serializable platform state owned by the
/// `Webview` notifier (and mirrored to the screen via `createController`).
/// Nullable message/metadata fields are cleared by passing explicit `null`
/// to `copyWith` (freezed null-sentinel semantics).
@freezed
abstract class const WebviewState._() with _$WebviewState {
  const factory WebviewState({
    @Default(0.0) double progress,
    @Default(false) bool isPageLoaded,
    @Default(false) bool isThemeApplied,
    @Default(true) bool isInitialLoad,
    @Default(18.0) double fontSize,
    String? currentUrl,
    @Default(AppConstants.freediumUrl) String activeBaseUrl,
    @Default(false) bool hasError,
    String? errorMessage,
    // One-shot message for the UI layer to display as a SnackBar.
    // The screen clears this after display via `Webview.clearUserMessage`.
    String? userMessage,
    // Article metadata extracted from the Freedium DOM.
    ArticleMeta? articleMeta,
  }) = _WebviewState;
}
