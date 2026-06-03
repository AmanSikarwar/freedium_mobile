import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

@visibleForTesting
Uri? parseExternalHttpUrl(String? value) {
  final url = value?.trim();
  if (url == null || url.isEmpty) return null;

  final uri = Uri.tryParse(url);
  final scheme = uri?.scheme.toLowerCase();
  if (uri == null ||
      !uri.hasScheme ||
      uri.host.isEmpty ||
      (scheme != 'http' && scheme != 'https')) {
    return null;
  }

  return uri;
}

Future<bool> launchExternalHttpUrl(String? value) async {
  final uri = parseExternalHttpUrl(value);
  if (uri == null) return false;

  try {
    final launched = await url_launcher.launchUrl(
      uri,
      mode: url_launcher.LaunchMode.externalApplication,
    );
    if (!launched) {
      debugPrint('Could not launch URL: $uri');
    }
    return launched;
  } catch (e) {
    debugPrint('Failed to launch URL "$uri": $e');
    return false;
  }
}
