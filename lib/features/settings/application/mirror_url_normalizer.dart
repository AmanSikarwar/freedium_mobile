String? normalizeMirrorUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  final scheme = uri?.scheme.toLowerCase();
  if (uri == null ||
      !uri.hasScheme ||
      uri.host.isEmpty ||
      (scheme != 'http' && scheme != 'https')) {
    return null;
  }

  return Uri(
    scheme: scheme,
    userInfo: uri.userInfo,
    host: uri.host.toLowerCase(),
    port: uri.hasPort ? uri.port : null,
    path: trimTrailingSlash(uri.path),
  ).toString();
}

String trimTrailingSlash(String value) {
  var trimmed = value;
  while (trimmed.length > 1 && trimmed.endsWith('/')) {
    trimmed = trimmed.substring(0, trimmed.length - 1);
  }

  return trimmed == '/' ? '' : trimmed;
}
