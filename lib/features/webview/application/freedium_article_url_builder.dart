Uri buildFreediumArticleUri({
  required String mirrorUrl,
  required String articleUrl,
}) {
  final mirrorUri = Uri.parse(mirrorUrl);
  final mirrorPath = _trimTrailingSlash(mirrorUri.path);
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

String _trimTrailingSlash(String value) {
  if (value.length <= 1 || !value.endsWith('/')) {
    return value;
  }

  return value.substring(0, value.length - 1);
}
