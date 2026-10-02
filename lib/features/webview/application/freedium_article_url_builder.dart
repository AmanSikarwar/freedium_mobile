import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/utils/url.dart'
    show hasSameOrigin, trimTrailingSlash;

Uri buildFreediumArticleUri({
  required String mirrorUrl,
  required String articleUrl,
}) {
  final mirrorUri = Uri.parse(mirrorUrl);
  final mirrorPath = trimTrailingSlash(mirrorUri.path);
  articleUrl = canonicalArticleUrl(articleUrl, mirrorUrls: [mirrorUrl]);
  final articlePath = articleUrl.startsWith('/')
      ? articleUrl.substring(1)
      : articleUrl;
  final path = mirrorPath.isEmpty ? articlePath : '$mirrorPath/$articlePath';

  return Uri(
    scheme: mirrorUri.scheme,
    userInfo: mirrorUri.userInfo,
    host: mirrorUri.host,
    port: mirrorUri.hasPort ? mirrorUri.port : null,
    path: path,
  );
}

String? extractOriginalArticleUrlFromFreediumUri({
  required String mirrorUrl,
  required String freediumUrl,
}) {
  final mirrorUri = Uri.tryParse(mirrorUrl);
  final freediumUri = Uri.tryParse(freediumUrl);
  if (mirrorUri == null || freediumUri == null) {
    return null;
  }

  if (!hasSameOrigin(mirrorUri, freediumUri)) {
    return null;
  }

  final mirrorPath = trimTrailingSlash(mirrorUri.path);
  var articlePath = freediumUri.path;

  if (mirrorPath.isNotEmpty) {
    if (!articlePath.startsWith('$mirrorPath/')) {
      return null;
    }
    articlePath = articlePath.substring(mirrorPath.length + 1);
  } else if (articlePath.startsWith('/')) {
    articlePath = articlePath.substring(1);
  }

  if (!articlePath.startsWith('http')) {
    return null;
  }

  final originalUrl = Uri.decodeComponent(articlePath);
  final queryStr = freediumUri.hasQuery ? '?${freediumUri.query}' : '';
  final fragmentStr = freediumUri.hasFragment ? '#${freediumUri.fragment}' : '';
  return '$originalUrl$queryStr$fragmentStr';
}

/// Unwraps known mirror links, including links shared by older app versions.
String canonicalArticleUrl(
  String value, {
  Iterable<String> mirrorUrls = const [],
}) {
  final mirrors = {
    AppConstants.freediumMirrorUrl,
    'https://freedium.cfd', // Legacy shared links remain readable.
    ...mirrorUrls,
  };
  while (true) {
    String? original;
    for (final mirror in mirrors) {
      try {
        final candidate = extractOriginalArticleUrlFromFreediumUri(
          mirrorUrl: mirror,
          freediumUrl: value,
        );
        if (candidate != null &&
            candidate != value &&
            Uri.tryParse(candidate)?.host.isNotEmpty == true) {
          original = candidate;
          break;
        }
      } on FormatException {
        continue;
      }
    }
    if (original == null) return value;
    value = original;
  }
}
