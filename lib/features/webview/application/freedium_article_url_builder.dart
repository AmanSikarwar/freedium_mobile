import 'package:freedium_mobile/core/utils/url.dart'
    show hasSameOrigin, trimTrailingSlash;

Uri buildFreediumArticleUri({
  required String mirrorUrl,
  required String articleUrl,
}) {
  final mirrorUri = Uri.parse(mirrorUrl);
  final mirrorPath = trimTrailingSlash(mirrorUri.path);
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
