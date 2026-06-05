String? normalizeHttpUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  final scheme = uri?.scheme.toLowerCase();
  if (uri == null ||
      !uri.hasScheme ||
      uri.host.isEmpty ||
      (scheme != 'http' && scheme != 'https')) {
    return null;
  }

  return uri
      .replace(
        scheme: scheme,
        host: uri.host.toLowerCase(),
        path: _trimTrailingSlash(uri.path),
      )
      .toString();
}

String _trimTrailingSlash(String value) {
  var trimmed = value;
  while (trimmed.length > 1 && trimmed.endsWith('/')) {
    trimmed = trimmed.substring(0, trimmed.length - 1);
  }

  return trimmed == '/' ? '' : trimmed;
}
