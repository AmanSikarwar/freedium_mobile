/// Maps platform WebView load failures to user-friendly messages.
///
/// Pure function over the error [description] and optional [errorTypeLabel]
/// (e.g. `WebResourceError.errorType.toString().split('.').last`) so it can
/// be unit-tested without platform channel types.
String getUserFriendlyWebviewErrorMessage({
  required String description,
  String? errorTypeLabel,
}) {
  final rawDescription = description.toLowerCase();

  // Android (Chromium) errors
  if (rawDescription.contains('err_internet_disconnected')) {
    return 'No internet connection. Please check your network and try again.';
  } else if (rawDescription.contains('err_name_not_resolved') ||
      rawDescription.contains('err_connection_refused') ||
      rawDescription.contains('err_connection_timed_out') ||
      rawDescription.contains('err_connection_reset')) {
    return 'Could not connect to the server. The current mirror might be down or blocked.';
  } else if (rawDescription.contains('err_cert_') ||
      rawDescription.contains('ssl')) {
    return 'Security certificate issue with the server. Connection might not be secure.';
  }

  // iOS (WebKit) errors
  if (rawDescription.contains('nsurlerrordomain') ||
      rawDescription.contains('webkit')) {
    if (rawDescription.contains('-1009')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (rawDescription.contains('-1001') ||
        rawDescription.contains('-1003') ||
        rawDescription.contains('-1004')) {
      return 'Could not connect to the server. The current mirror might be down or timed out.';
    } else if (rawDescription.contains('-1200') ||
        rawDescription.contains('-1202')) {
      return 'A secure connection could not be established with the server.';
    }
  }

  // Default formatting if it doesn't match known patterns
  if (errorTypeLabel != null) {
    return 'Connection failed: $errorTypeLabel\n\nPlease try another mirror.';
  }

  return 'Failed to load page.\n\nPlease try another mirror or check your connection.';
}
