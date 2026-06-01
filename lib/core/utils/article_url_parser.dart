String? extractArticleUrl(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  final directUrl = _validHttpUrl(trimmed);
  if (directUrl != null) return directUrl;

  final match = RegExp(
    r'''https?:\/\/[^\s<>"']+''',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (match == null) return null;

  return _validHttpUrl(match.group(0)!);
}

String? extractFirstArticleUrl(Iterable<String> inputs) {
  for (final input in inputs) {
    final url = extractArticleUrl(input);
    if (url != null) return url;
  }

  return null;
}

String? _validHttpUrl(String value) {
  final cleaned = _stripTrailingPunctuation(value);
  final uri = Uri.tryParse(cleaned);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return null;
  }

  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https') {
    return null;
  }

  return cleaned;
}

String _stripTrailingPunctuation(String value) {
  var cleaned = value.trim();
  while (cleaned.isNotEmpty &&
      '.,;:!?)>]'.contains(cleaned[cleaned.length - 1])) {
    cleaned = cleaned.substring(0, cleaned.length - 1);
  }
  return cleaned;
}
