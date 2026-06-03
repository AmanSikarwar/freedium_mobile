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
  if (value == '/' || !value.endsWith('/')) {
    return value == '/' ? '' : value;
  }

  return value.substring(0, value.length - 1);
}
