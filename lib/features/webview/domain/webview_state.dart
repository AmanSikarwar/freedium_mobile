import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewState {
  final double progress;
  final bool isPageLoaded;
  final bool isThemeApplied;
  final bool isInitialLoad;
  final InAppWebViewController? controller;
  final double fontSize;

  WebviewState({
    this.progress = 0.0,
    this.isPageLoaded = false,
    this.isThemeApplied = false,
    this.isInitialLoad = true,
    this.controller,
    this.fontSize = 18.0,
  });

  WebviewState copyWith({
    double? progress,
    bool? isPageLoaded,
    bool? isThemeApplied,
    bool? isInitialLoad,
    InAppWebViewController? controller,
    double? fontSize,
  }) {
    return WebviewState(
      progress: progress ?? this.progress,
      isPageLoaded: isPageLoaded ?? this.isPageLoaded,
      isThemeApplied: isThemeApplied ?? this.isThemeApplied,
      isInitialLoad: isInitialLoad ?? this.isInitialLoad,
      controller: controller ?? this.controller,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}
