/// Canonical URL helpers — single source of truth for HTTP URL validation,
/// normalization, and origin comparison.
///
/// Replaces the previously duplicated `trimTrailingSlash` / `normalize*Url`
/// implementations across `http_url_normalizer.dart`,
/// `mirror_url_normalizer.dart`, and `freedium_article_url_builder.dart`.
String trimTrailingSlash(String value) {
  var trimmed = value;
  while (trimmed.length > 1 && trimmed.endsWith('/')) {
    trimmed = trimmed.substring(0, trimmed.length - 1);
  }

  return trimmed == '/' ? '' : trimmed;
}

bool isHttpUri(Uri? uri) {
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;
  final scheme = uri.scheme.toLowerCase();
  return scheme == 'http' || scheme == 'https';
}

Uri? tryParseHttpUri(String value) {
  final uri = Uri.tryParse(value.trim());
  return isHttpUri(uri) ? uri : null;
}

/// Normalizes an article/content URL, preserving query and fragment.
String? normalizeHttpUrl(String value) {
  final uri = tryParseHttpUri(value);
  if (uri == null) return null;

  return uri
      .replace(
        scheme: uri.scheme.toLowerCase(),
        host: uri.host.toLowerCase(),
        path: trimTrailingSlash(uri.path),
      )
      .toString();
}

/// Normalizes a Freedium mirror base URL, dropping query and fragment.
String? normalizeMirrorUrl(String value) {
  final uri = tryParseHttpUri(value);
  if (uri == null) return null;

  return Uri(
    scheme: uri.scheme.toLowerCase(),
    userInfo: uri.userInfo,
    host: uri.host.toLowerCase(),
    port: uri.hasPort ? uri.port : null,
    path: trimTrailingSlash(uri.path),
  ).toString();
}

bool hasSameOrigin(Uri a, Uri b) {
  return a.scheme.toLowerCase() == b.scheme.toLowerCase() &&
      a.host.toLowerCase() == b.host.toLowerCase() &&
      a.port == b.port;
}
