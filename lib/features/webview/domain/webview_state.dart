import 'package:webview_flutter/webview_flutter.dart';

class WebviewState {
  final double progress;
  final bool isPageLoaded;
  final bool isThemeApplied;
  final bool isInitialLoad;
  final WebViewController? controller;
  final double fontSize;
  final String? currentUrl;

  WebviewState({
    this.progress = 0.0,
    this.isPageLoaded = false,
    this.isThemeApplied = false,
    this.isInitialLoad = true,
    this.controller,
    this.fontSize = 18.0,
    this.currentUrl,
  });

  WebviewState copyWith({
    double? progress,
    bool? isPageLoaded,
    bool? isThemeApplied,
    bool? isInitialLoad,
    WebViewController? controller,
    double? fontSize,
    String? currentUrl,
  }) {
    return WebviewState(
      progress: progress ?? this.progress,
      isPageLoaded: isPageLoaded ?? this.isPageLoaded,
      isThemeApplied: isThemeApplied ?? this.isThemeApplied,
      isInitialLoad: isInitialLoad ?? this.isInitialLoad,
      controller: controller ?? this.controller,
      fontSize: fontSize ?? this.fontSize,
      currentUrl: currentUrl ?? this.currentUrl,
    );
  }
}
